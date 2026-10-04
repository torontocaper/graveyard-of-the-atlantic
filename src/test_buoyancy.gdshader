shader_type spatial;

uniform vec4 water_color : source_color; 

float get_height_offset(float x_coord, float z_coord) {
	float x_wave_value = 0.1 * sin(x_coord + TIME);
	float z_wave_value = 0.15 * sin(z_coord + TIME);
	float diagonal_wave_value = 0.2 * sin(x_coord + z_coord + TIME);
	return x_wave_value + z_wave_value + diagonal_wave_value;
}

void vertex() {
	VERTEX.y = get_height_offset(VERTEX.x, VERTEX.z);
}

void fragment() {
	ALBEDO = water_color.rgb;
	ROUGHNESS = 0.01;
	NORMAL = normalize(cross(dFdy(VERTEX), dFdx(VERTEX)));
}