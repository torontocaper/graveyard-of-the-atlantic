shader_type spatial;
//render_mode specular_toon;
render_mode world_vertex_coords;

uniform float x_amplitude;
uniform float x_frequency;
uniform float x_speed;

uniform float z_amplitude;
uniform float z_frequency;
uniform float z_speed;

float get_height(vec2 coords) {
	float x_wave_value = x_amplitude * sin( (2.0 * PI * x_frequency) * ( ( coords.x + TIME ) * x_speed ));
	float z_wave_value = z_amplitude * sin( (2.0 * PI * z_frequency) * ( ( coords.y + TIME ) * z_speed ));
	float height_value = x_wave_value + z_wave_value;
	return height_value;
}

varying flat vec3 my_normal;

void vertex() {
	vec2 x_z_coords = VERTEX.xz;
	VERTEX.y = get_height(VERTEX.xz);
	vec2 neighbor_1 = vec2(VERTEX.x + 0.1, VERTEX.z);
	vec2 neighbor_2 = vec2(VERTEX.x, VERTEX.z + 0.1);
	float neighbor_1_y = get_height(neighbor_1);
	float neighbor_2_y = get_height(neighbor_2);
	vec3 neighbor_1_vec3 = vec3(neighbor_1.x, neighbor_1_y, neighbor_1.y) - VERTEX;
	vec3 neighbor_2_vec3 = vec3(neighbor_2.x, neighbor_2_y, neighbor_2.y) - VERTEX;
	my_normal = cross(neighbor_1_vec3, neighbor_2_vec3);
	NORMAL = my_normal;
}

void fragment() {
	ALBEDO = vec3(0.01, 0.05, 0.08);
	ROUGHNESS = 0.01;
	METALLIC = 0.0;
	NORMAL = my_normal;
}