shader_type spatial;
//render_mode world_vertex_coords;
//render_mode skip_vertex_transform;
//render_mode vertex_lighting;

uniform float max_height;

varying vec3 world_vertex;
varying vec3 custom_light_vertex;
varying vec3 custom_normal;
varying vec3 custom_world_normal;

void vertex() {
	//world_vertex = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	//custom_light_vertex = (MAIN_CAM_INV_VIEW_MATRIX * vec4(world_vertex, 1.0)).xyz;
}

void fragment() {
	world_vertex = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 world_vertex_normalized = normalize(world_vertex);
	float y_value = world_vertex.y;
	float y_value_normalized = world_vertex_normalized.y;
	float y_value_positive = (y_value_normalized + 1.0) / 2.0;
	ALBEDO = vec3(
		y_value_positive,
		y_value_positive,
		y_value_positive
	);
	custom_normal = normalize(cross(dFdy(VERTEX), dFdx(VERTEX)));
	//custom_world_normal = normalize(cross(dFdy(world_vertex), dFdx(world_vertex)));
	NORMAL = custom_normal;
	//LIGHT_VERTEX = custom_light_vertex;
	}

//void light() {
    //DIFFUSE_LIGHT += clamp(dot(custom_world_normal, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR / PI;
//}
