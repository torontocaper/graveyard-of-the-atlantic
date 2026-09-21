shader_type spatial;

uniform float x;
uniform float y;

void vertex() {
	vec2 coords = VERTEX.xz;
	float random_value = x;
	float constant_value = y;
	VERTEX.y += random_value * constant_value;
}

void fragment() {
	
}