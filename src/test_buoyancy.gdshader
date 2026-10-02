shader_type spatial;
//render_mode skip_vertex_transform;
//render_mode diffuse_toon, specular_toon;

//varying flat vec3 flat_vertex;

void vertex() {
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
