/* Keep automatic screen locking inactive on AC with the lid open.
 * Use native notifications so unplugging or closing the lid releases the
 * assertion. Renew a bounded assertion so a stuck process cannot hold it forever.
 */
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/ps/IOPowerSources.h>
#include <IOKit/ps/IOPSKeys.h>
#include <IOKit/pwr_mgt/IOPM.h>
#include <IOKit/pwr_mgt/IOPMLib.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static io_service_t root_domain;
static IOPMAssertionID activity = kIOPMNullAssertionID;
static CFAbsoluteTime renewed_at;
static bool enabled;

static bool on_ac(void)
{
    CFTypeRef info = IOPSCopyPowerSourcesInfo();
    if (!info) return false;
    CFStringRef source = IOPSGetProvidingPowerSourceType(info);
    bool ac = source && CFEqual(source, CFSTR(kIOPSACPowerValue));
    CFRelease(info);
    return ac;
}

static bool lid_open(void)
{
    CFTypeRef closed = IORegistryEntryCreateCFProperty(
        root_domain, CFSTR("AppleClamshellState"), kCFAllocatorDefault, 0);
    bool open = closed && CFEqual(closed, kCFBooleanFalse);
    if (closed) CFRelease(closed);
    return open;
}

static void release_activity(void)
{
    if (activity != kIOPMNullAssertionID) {
        IOPMAssertionRelease(activity);
        activity = kIOPMNullAssertionID;
    }
}

static void apply_policy(bool ac, bool open)
{
    bool wanted = ac && open;
    if (!wanted) {
        release_activity();
    } else if (activity == kIOPMNullAssertionID ||
               CFAbsoluteTimeGetCurrent() - renewed_at >= 30) {
        release_activity();
        IOReturn result = IOPMAssertionCreateWithDescription(
            CFSTR("UserIsActive"), CFSTR("Keep unlocked: AC and lid open"),
            NULL, NULL, NULL, 60, kIOPMAssertionTimeoutActionRelease, &activity);
        if (result != kIOReturnSuccess) {
            fprintf(stderr, "Cannot declare user activity: 0x%x\n", result);
            exit(EXIT_FAILURE);
        }
        renewed_at = CFAbsoluteTimeGetCurrent();
    }
    if (wanted != enabled) {
        fprintf(stderr, "Automatic-lock prevention %s\n", wanted ? "on" : "off");
        enabled = wanted;
    }
}

static void refresh(void *context)
{
    (void)context;
    apply_policy(on_ac(), lid_open());
}

static void lid_changed(void *context, io_service_t service,
                        natural_t message, void *argument)
{
    (void)context;
    (void)service;
    (void)argument;
    if (message == kIOPMMessageClamshellStateChange) refresh(NULL);
}

static void timer_fired(CFRunLoopTimerRef timer, void *context)
{
    (void)timer;
    refresh(context);
}

/* Exercise the actual assertion create/release paths without changing settings.
 * These inputs test policy transitions, not physical power or lid transitions.
 */
static int exercise(void)
{
    const bool states[][2] = {{true, true}, {true, false},
                              {true, true}, {false, true}, {false, false}};
    for (size_t i = 0; i < sizeof(states) / sizeof(states[0]); ++i) {
        apply_policy(states[i][0], states[i][1]);
        bool held = activity != kIOPMNullAssertionID;
        if (held != (states[i][0] && states[i][1])) return EXIT_FAILURE;
    }
    puts("Assertion policy transitions passed");
    return EXIT_SUCCESS;
}

int main(int argc, char **argv)
{
    atexit(release_activity);
    if (argc == 2 && strcmp(argv[1], "--exercise") == 0) return exercise();
    root_domain = IOServiceGetMatchingService(
        kIOMainPortDefault, IOServiceMatching("IOPMrootDomain"));
    if (!root_domain) {
        fputs("Cannot find IOPMrootDomain\n", stderr);
        return EXIT_FAILURE;
    }
    if (argc == 2 && strcmp(argv[1], "--status") == 0) {
        bool ac = on_ac(), open = lid_open();
        printf("AC=%s lid=%s prevent-auto-lock=%s\n",
               ac ? "yes" : "no", open ? "open" : "closed",
               ac && open ? "yes" : "no");
        return EXIT_SUCCESS;
    }
    if (argc != 1) {
        fprintf(stderr, "Usage: %s [--status | --exercise]\n", argv[0]);
        return EXIT_FAILURE;
    }
    IONotificationPortRef port = IONotificationPortCreate(kIOMainPortDefault);
    io_object_t notification = IO_OBJECT_NULL;
    CFRunLoopSourceRef power = IOPSNotificationCreateRunLoopSource(refresh, NULL);
    if (!port || !power || IOServiceAddInterestNotification(
            port, root_domain, kIOGeneralInterest, lid_changed, NULL,
            &notification) != KERN_SUCCESS) {
        fputs("Cannot register power/lid notifications\n", stderr);
        return EXIT_FAILURE;
    }
    CFRunLoopRef loop = CFRunLoopGetCurrent();
    CFRunLoopAddSource(loop, power, kCFRunLoopCommonModes);
    CFRunLoopAddSource(loop, IONotificationPortGetRunLoopSource(port),
                       kCFRunLoopCommonModes);
    /* Recheck hardware as a fallback and renew the 60-second assertion. */
    CFRunLoopTimerRef timer = CFRunLoopTimerCreate(
        NULL, CFAbsoluteTimeGetCurrent() + 5, 5, 0, 0, timer_fired, NULL);
    if (!timer) return EXIT_FAILURE;
    CFRunLoopAddTimer(loop, timer, kCFRunLoopCommonModes);
    refresh(NULL);
    CFRunLoopRun();
    return EXIT_SUCCESS;
}
