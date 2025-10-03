shader_type spatial;

uniform float amplitude = 2.0;
uniform float wavelength = 12.0;
uniform float speed = 1.5;
uniform float time;

varying flat vec3 flat_normal; // one per triangle, not interpolated

// Wave function
float wave_height(float x, float z) {
    float k = 6.28318 / wavelength;
    float wave1 = amplitude * sin(k * x + speed * time);
    float wave2 = amplitude * 0.5 * sin(k * z * 0.7 + speed * 0.8 * time);
    return wave1 + wave2;
}

void vertex() {
    // Apply wave displacement
    float h = wave_height(VERTEX.x, VERTEX.z);
    VERTEX.y += h;

    // Estimate slope by sampling nearby positions
    float eps = 0.5;
    float h_x = wave_height(VERTEX.x + eps, VERTEX.z) - h;
    float h_z = wave_height(VERTEX.x, VERTEX.z + eps) - h;

    // Construct normal from slope
    vec3 n = normalize(vec3(-h_x, 1.0, -h_z));

    // Store as flat varying (triangle will use one normal)
    flat_normal = n;
}

void fragment() {
    // Base color only from height
    float h = VERTEX.y * 0.05;
    ALBEDO = mix(vec3(0.0, 0.25, 0.5), vec3(0.2, 0.6, 0.9), clamp(h, 0.0, 1.0));

    // Don’t touch lighting yourself — just set NORMAL
    NORMAL = flat_normal;
}
