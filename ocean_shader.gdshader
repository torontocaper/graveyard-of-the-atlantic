shader_type spatial;

uniform float amplitude : hint_range(0.1, 5.0) = 2.0;
uniform float wavelength : hint_range(2.0, 50.0) = 12.0;
uniform float speed : hint_range(0.1, 5.0) = 1.5;

varying flat vec3 flat_normal;   // one normal per face
varying flat float flat_height;  // world height per face

// ---- Wave function ----
float wave_height(vec2 pos) {
    float k = 6.28318 / wavelength; // 2*PI / wavelength

    // Layered waves in different directions
    float h = 0.0;
    h += amplitude * 0.7 * sin(dot(pos, vec2(0.2, 0.0)) * k + speed * TIME);
    h += amplitude * 0.5 * sin(dot(pos, vec2(0.0, 0.25)) * k + speed * 0.8 * TIME);
    h += amplitude * 0.4 * sin(dot(pos, normalize(vec2(1.0, 1.0))) * k + speed * 1.3 * TIME);

    return h;
}

void vertex() {
    // Apply wave displacement
    float h = wave_height(VERTEX.xz);
    VERTEX.y += h;

    // Estimate slope for normals (numerical gradient)
    float eps = 0.5;
    float h_x = wave_height((VERTEX.xz + vec2(eps, 0.0))) - h;
    float h_z = wave_height((VERTEX.xz + vec2(0.0, eps))) - h;
    flat_normal = normalize(vec3(-h_x, 1.0, -h_z));

    // World-space height for gradient
    vec4 world_pos = MODEL_MATRIX * vec4(VERTEX, 1.0);
    flat_height = world_pos.y;
}

void fragment() {
    // Flat shading (one normal per face)
    NORMAL = flat_normal;

    // Height-based color (independent of camera)
    float h = clamp(flat_height * 0.05, 0.0, 1.0);
    ALBEDO = mix(vec3(0.0, 0.25, 0.5),   // trough color
                 vec3(0.2, 0.6, 0.9),    // crest color
                 h);
}
