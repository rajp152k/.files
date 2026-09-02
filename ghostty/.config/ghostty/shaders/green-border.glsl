// Square, four-pixel theme-green frame. Ghostty runs this after terminal rendering.
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 terminal = texture(iChannel0, fragCoord / iResolution.xy);
    float edgeDistance = min(
        min(fragCoord.x, fragCoord.y),
        min(iResolution.x - fragCoord.x, iResolution.y - fragCoord.y)
    );

    fragColor = edgeDistance < 1.0 ? vec4(0.0, 1.0, 0.0, 1.0) : terminal;
}
