shader_type spatial;

uniform vec4 base_color : source_color;

void vertex() {
	
}

void fragment() {
	ALBEDO = base_color.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
