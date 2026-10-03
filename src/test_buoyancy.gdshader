shader_type spatial;
//render_mode skip_vertex_transform;
//render_mode diffuse_toon, specular_toon;

//varying flat vec3 flat_vertex;

float get_height_offset(float x_coord, float z_coord) {
	float x_wave_value = 0.1 * sin(x_coord + TIME);
	float z_wave_value = 0.15 * sin(z_coord + TIME);
	float diagonal_wave_value = 0.2 * sin(x_coord + z_coord + TIME);
	return x_wave_value + z_wave_value + diagonal_wave_value;
}

void vertex() {
	VERTEX.y = get_height_offset(VERTEX.x, VERTEX.z);
	//flat_vertex = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	//LIGHT_VERTEX = flat_vertex;
	//VERTEX = flat_vertex;
	ALBEDO = COLOR.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
