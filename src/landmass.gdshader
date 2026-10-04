shader_type spatial;

uniform float max_height;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = vec3(VERTEX.y/max_height, VERTEX.y/max_height, VERTEX.y/max_height);
	NORMAL = normalize(cross(dFdy(VERTEX), dFdx(VERTEX)));
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
