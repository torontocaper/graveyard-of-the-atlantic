shader_type spatial;

uniform float wavelength = 12.0;
uniform float time = 0.0;
uniform vec4 waves[8]; // up to 8 wave layers: (dir_x, dir_z, amp, speed)

varying flat vec3 flat_normal;
varying flat float flat_height;

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
    float h = wave_height(VERTEX.xz);
    VERTEX.y += h;

    // slope-aware normal
    float eps = 0.5;
    float h_x = wave_height(VERTEX.xz + vec2(eps, 0.0)) - h;
    float h_z = wave_height(VERTEX.xz + vec2(0.0, eps)) - h;
    flat_normal = normalize(vec3(-h_x, 1.0, -h_z));

    flat_height = (MODEL_MATRIX * vec4(VERTEX, 1.0)).y;
}

void fragment() {
    NORMAL = flat_normal;
    float h = clamp(flat_height * 0.05, 0.0, 1.0);
    ALBEDO = mix(vec3(0.0, 0.25, 0.5), vec3(0.2, 0.6, 0.9), h);
}
