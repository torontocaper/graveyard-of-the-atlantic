shader_type spatial;
//render_mode specular_toon;

uniform float elapsed_time = 0.0;
uniform vec4 water_color : source_color; 

float get_height_offset(float x_coord, float z_coord) {
	float x_wave_value = 0.1 * sin(x_coord + elapsed_time);
	float z_wave_value = 0.15 * sin(z_coord + elapsed_time);
	float diagonal_wave_value = 0.2 * sin(x_coord + z_coord + elapsed_time);
	return x_wave_value + z_wave_value + diagonal_wave_value;
}

void vertex() {
	VERTEX.y = get_height_offset(VERTEX.x, VERTEX.z);
}

void fragment() {
	ALBEDO = water_color.rgb;
	ALPHA = 0.99;
	ROUGHNESS = 0.15;
	SPECULAR = 1.0;
	NORMAL = normalize(cross(dFdy(VERTEX), dFdx(VERTEX)));
}