shader_type spatial;

uniform float x_amplitude;
uniform float x_frequency;
uniform float x_speed;

uniform float z_amplitude;
uniform float z_frequency;
uniform float z_speed;

uniform float diagonal_amplitude;
uniform float diagonal_frequency;
uniform float diagonal_speed;

varying flat vec3 my_vertex;

float random_x(vec2 xz_coords) {
	return fract(
		sin(dot(xz_coords, vec2(12.9898, 78.233)))
		* 43758.5453
	);
}

float random_z(vec2 xz_coords) {
	return fract(
		sin(dot(xz_coords, vec2(39.3468, 11.135)))
		* 24634.6345
	);
}

float get_height_offset(float x_coord, float z_coord) {
	float x_wave_value = x_amplitude * sin( (2.0 * PI * x_frequency) * ( x_coord + TIME * x_speed  ));
	float z_wave_value = z_amplitude * sin( (2.0 * PI * z_frequency) * ( z_coord + TIME * z_speed  ));
	float diagonal_wave_value = diagonal_amplitude * sin( (2.0 * PI * diagonal_frequency) * ( x_coord + z_coord +  TIME * diagonal_speed ));
	return x_wave_value + z_wave_value + diagonal_wave_value;
}

void vertex() {
	float x_jitter = random_x(VERTEX.xz) - 0.5;
	float z_jitter = random_z(VERTEX.xz) - 0.5;
	VERTEX.x += x_jitter;
	VERTEX.z += z_jitter;
	VERTEX.y = get_height_offset(VERTEX.x, VERTEX.z);
}

void fragment() {
	ALBEDO = vec3(0.01, 0.05, 0.08);
	ROUGHNESS = 0.01;
	METALLIC = 0.0;
	NORMAL = normalize(cross(dFdy(VERTEX), dFdx(VERTEX)));
}