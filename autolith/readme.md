# Autolith dispatch policy

Use `dispatch-low` for clear, bounded lookups, extraction, status checks, and mechanical edits with explicit checks. Use `dispatch-medium` for implementation, debugging, unclear scope, sensitive work, and failed checks. Return evidence when you escalate. Do not repeat blind low-effort attempts.

Keep main coordinators at medium unless the user chooses another setting. Use direct tools for small exact work. Use a specialist role when you need its tool limits or output contract. Inspect its actual model and effort first.

## Files and deployment

- `agents/dispatch-low.sexp`: inherit the parent model, use low effort, allow child-safe tools, and disable nested dispatch.
- `agents/dispatch-medium.sexp`: inherit the parent model, use medium effort, allow child-safe tools and nested dispatch.
- `extensions/dispatch-policy.lisp`: add request-local instructions and provide reload and inspection functions.
- `extensions/commands/config-reload.lisp`: load `peer-discovery.lisp`, which also loads the dispatch policy, when `init.lisp` loads this extension.

Stow the `autolith` package into the home directory. On this machine, `~/.config/autolith/extensions` already points into this package. The added `~/.config/autolith/agents` link points to `../../.files/autolith/.config/autolith/agents`.

Roles are read from disk at each `task.agents` and `task.run` call. Project roles take precedence over user roles. A malformed project role blocks the same user role. Inspect `task.agents` before dispatch. Running children keep the settings chosen when they started.

## Reload

For the first policy-only load in an existing image, evaluate:

\```lisp
(let ((*extension-registration-source* :user))
  (load (merge-pathnames "extensions/dispatch-policy.lisp"
                        (config :config-root))
        :verbose nil :print nil))
(dispatch-policy-status)
\```

For later policy-only reloads, evaluate:

\```lisp
(dispatch-policy-reload)
\```

This reload replaces the same contributor registration and reports effective role routes. It does not set the main model or effort. Inspect `(context-status)` after the next provider request to check that `dispatch-policy-v1` was included.

`/reval` runs `user-init-load`. It reloads site initialization, trusted directory initialization, and user initialization. It removes and rebuilds site/user context, command, MCP, and provider registrations. This package's initialization loads the command extension, which loads the dispatch policy. The next provider request can receive the policy. Context advice uses the normal advice budget and can be omitted when that budget is full.

`/reval` also executes all other initialization code. The current `init.lisp` sets the main model and effort. Use the policy-only load above if you must preserve a different session choice. `/reval` does not restart sessions or children, reload tracked source or private commits, or rebuild the cached base system-prompt template. Role files do not need `/reval`.

## Model and RLM routing

The two roles use `@parent`, not a fixed provider or model. At verification time, this session resolved `gpt-6.1-sol` to provider `chatgpt`; the role routes were that model with low and medium effort. Other parent models need their own effort-support check.

In the checked Autolith releases, `@task`, `@parent`, and `@auto` select the parent model. `@smol` selects `gpt-5.6-luna`; `@slow` and `@designer` select `gpt-6.1-terra`. These aliases do not mean low or medium effort.

The checked RLM implementation supports explicit top-level `model` and `effort` fields. Use them only when the exposed tool schema includes them. Use exact supported model IDs, not task-role aliases. Nested RLM calls inherit the enclosing model and effort. This policy does not change RLM defaults.

The instructions guide task selection. They do not enforce task classification. The native role settings enforce the selected child's effort. The policy does not change existing specialist roles, switch main models, or dispatch work by itself.

## Checks

Load the extension and `tests/autolith-dispatch-policy.lisp` from the repository root in an Autolith Lisp worker. Call `check-dispatch-policy` with a configuration whose config root includes these user roles and whose workspace has no same-name project override. The checks cover role discovery, model inheritance, explicit child effort independent of parent effort, spawn limits, reload deduplication, and unchanged main settings. They make no model requests.

## Rollback

Revert the policy commit. In each image that loaded the policy, evaluate:

\```lisp
(unregister-context-contributor "dispatch-policy-context")
\```

Remove the added `~/.config/autolith/agents` link if you created it for this policy. Do not remove other user roles. Existing children continue with their original settings. The inspection functions can remain defined until the image next starts; they do not register advice or change settings when idle.


# Live peer discovery

Use the Lisp helpers in `extensions/peer-discovery.lisp` for discovery. Use the CLI only if the helpers are unavailable or broken. Use the existing CLI for messages; these helpers do not send messages or change sessions.

For the first load in a live image, evaluate:

\```lisp
(let ((*extension-registration-source* :user))
  (load (merge-pathnames "extensions/peer-discovery.lisp"
                        (config :config-root))
        :verbose nil :print nil))
\```

For later reloads, evaluate `(peer-discovery-reload)`. Both loads also refresh the existing dispatch contributor. They do not run `init.lisp` or set model, effort, or permissions. Startup loads both extensions through the existing command extension. Do not use `/reval` for this narrow refresh.

\```lisp
(peers)                         ; fresh list of tagged status records
(peer "proud panda")            ; exact match first, then friendly alias
(peer "proud_panda_e446a1")      ; full alias
(self-peer)                     ; actual application conversation and process
(let* ((rows (peers))
       (row (peer "proud panda" rows)))
  (getf (rest row) :session-id)) ; fields follow :LOCALGROUP-STATUS
\```

Resolve exact aliases, session IDs, conversation IDs, and display IDs before matching friendly names. IDs are case-sensitive. For friendly names, case and runs of spaces, underscores, tabs, or hyphens are equivalent. You can omit a generated six-hex-digit alias suffix if the result is unique. Partial IDs and name prefixes do not match.

A missing match signals `peer-not-found`. Multiple matches signal `peer-ambiguous`. Both extend `peer-lookup-error`; inspect `peer-lookup-query` and `peer-lookup-candidates`. Use the `retry` restart to refresh discovery. For `peer`, use the `use-value` restart to resolve another name against the same snapshot. No restart silently chooses a candidate.

`self-peer` matches the actual application's conversation ID and process ID. It identifies the application session, not a child job actor. It signals a lookup error if no live row matches. A worker without an active application cannot identify itself as a live session.

Records include session and conversation IDs, alias, process, workspace, state, model, effort, and task/terminal state. The public field allowlist excludes endpoint credentials. Use `REST` before `GETF`. A snapshot is point-in-time evidence, not a permission grant or proof of task completion. Native `localgroup-statuses` can prune unreachable registry entries; the helpers do not alter sessions.

Missing aliases are returned as `NIL`. Exact IDs and self lookup still work. The installed .20 and .24 native status implementations do not supply aliases. The selected private alias definitions add them to snapshots or client results. During verification, Bright Gecko's raw endpoint returned `NIL` while Tiger's decorated client results included its alias. This explains why different clients can show different alias fields; the exact binding in Gecko's image was not inspected. This extension does not derive aliases or load private replay state.

The existing `dispatch-policy-v1` contributor now includes discovery advice. Inspect `(context-status)` after the next normal provider request. There is no second contributor. Advice can be omitted when its budget is full.

## Discovery checks and rollback

Load `tests/autolith-peer-discovery.lisp` in an Autolith worker. Run `(check-peer-discovery)` and `(check-peer-discovery-reload configuration)`. These checks cover exact IDs, normalization, missing aliases, ambiguity, recovery, self matching, credential-field exclusion, repeated reload, contributor deduplication, and unchanged main settings. They do not request model inference.

Verification compared the installed .20/.24 native client and runtime sources. The only client difference is CLI configuration initialization; the discovery function is identical. Live read-only lookup and self matching passed in Tiger's .24 image against both .20 and .24 endpoints. Each peer must verify its own loaded definitions.

To roll back, revert the discovery-helper commit. Reload the reverted `dispatch-policy.lisp` in each loaded image to remove the new advice. Restart later to remove the idle helper definitions, or explicitly unbind only the helper functions if needed. No running session needs an immediate restart. Preserve the earlier dispatch policy and its roles.
