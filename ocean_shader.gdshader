shader_type spatial;
render_mode cull_disabled; // optional: unshaded for debugging

uniform float time = 0.0;
uniform vec4 waves[8];
uniform float wavelength = 12.0;

// Wave displacement (same as before)
float wave_height(vec2 pos) {
    float k = 6.28318 / wavelength;
    float h = 0.0;
    for (int i = 0; i < 8; i++) {
        vec4 w = waves[i];
        if (w.z == 0.0) break;
        vec2 dir = normalize(w.xy);
        h += w.z * sin(dot(pos, dir) * k + w.w * time);
    }
    return h;
}

void vertex() {
    VERTEX.y += wave_height(VERTEX.xz);
}

void fragment() {
    // This mimics "flat" color per triangle
    ALBEDO = COLOR.rgb;   // or use a constant color like vec3(0.0, 0.5, 1.0)
}
