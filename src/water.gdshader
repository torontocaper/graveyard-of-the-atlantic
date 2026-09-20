shader_type spatial;

//uniform float height_scale = 0.1;
//uniform sampler2D wave_noise;
uniform float mesh_size = 10.0;

varying vec2 position_on_mesh;
varying float height_offset;

//float height(vec2 position, float time) {
  //vec2 offset = 0.01 * cos(position + time);
  //return texture(wave_noise, (position / 2.0) - offset).x;
//}

float offset_height(vec2 coords) {
		return coords.x + coords.y;
}

void vertex() {
	//vec2 pos = VERTEX.xz;
	//float k = height(pos, TIME);
	position_on_mesh = (VERTEX.xz / 2.0) + (mesh_size / 4.0);
	//float height = texture(wave_noise, tex_position).x;
	height_offset = offset_height(position_on_mesh);
	VERTEX.y = height_offset;
	//NORMAL = normalize(vec3(k - height(pos + vec2(0.1, 0.0), TIME), 0.1, k - height(pos + vec2(0.0, 0.1), TIME)));
}

void fragment() {
	//float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	//NORMAL_MAP = texture(normal_noise, tex_position).xyz;
	//METALLIC = 0.0;
	//ROUGHNESS = 0.01 * (1.0 - fresnel);
	ALBEDO = vec3(0.01 + (1.0 / height_offset), 0.03 + (1.0 / height_offset), 0.05 + (1.0 / height_offset));
	//RIM = 0.2;
}
