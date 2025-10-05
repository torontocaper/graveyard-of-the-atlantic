shader_type spatial;
render_mode unshaded, cull_disabled;

uniform float wavelength = 12.0;
uniform float time = 0.0;
uniform vec4 waves[8];

// flat varyings to carry non-interpolated values
varying flat float v_flat_height;

// --- helper: compute vertical displacement ---
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

// --- vertex stage ---
void vertex() {
    float h = wave_height(VERTEX.xz);
    VERTEX.y += h;
    v_flat_height = VERTEX.y;   // capture world height per triangle
}

// --- fragment stage ---
void fragment() {
    // use flat-carried height (no interpolation)
	// assume waves[i].z stores amplitude; we can estimate a total amplitude range
	float height_scale = 1.0 / (max(0.01, waves[0].z * 4.0)); // dynamic scaling
	float h = clamp(v_flat_height * height_scale + 0.5, 0.0, 1.0);
    vec3 deep_color = vec3(0.0, 0.25, 0.5);
    vec3 shallow_color = vec3(0.2, 0.6, 0.9);
    ALBEDO = mix(deep_color, shallow_color, h);
}
