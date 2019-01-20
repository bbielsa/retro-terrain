shader_type spatial;

//uniform sampler2D height_map;
//uniform sampler2D grass_texture;

//float get_height(vec2 pos) {
//	float height = texture(height_map, pos / 10.0).r * 255.0;
//	height /= 4.0;
//
//	return height;
//}
//
//float vertex_height_clamp(float height) {
//	if(height < 0.4)
//		return 0.0;
//	else if(height >= 0.4 && height <= 0.6)
//		return 0.5;
//	else
//		return 1.0;
//}
//
//float get_middle_height(vec2 middle_vertex) {
//	vec2 north_vertex = floor(middle_vertex);
//	vec2 south_vertex = ceil(middle_vertex);
//	vec2 east_vertex = vec2(ceil(middle_vertex.x), floor(middle_vertex.y));
//	vec2 west_vertex = vec2(floor(middle_vertex.x), ceil(middle_vertex.y));
//
//	float north_height = get_height(north_vertex);
//	float south_height = get_height(south_vertex);
//	float east_height = get_height(east_vertex);
//	float west_height = get_height(west_vertex);
//
//	float sum_height = north_height + south_height + east_height + west_height;
//	float average_height = sum_height / 4.0;
//
//	return vertex_height_clamp(average_height);
//
//	if(average_height > 0.25 && average_height != 1.0)
//		return 1.0;
//	else
//		return 0.0;
//}

//void vertex() {
//	float height = get_height(VERTEX.xz);
//	bool middle_vertex = VERTEX.x - floor(VERTEX.x) > 0.0;
//
//	if(middle_vertex)
//		VERTEX.y = height + get_middle_height(VERTEX.xz);
//	else
//		VERTEX.y = height;	
//}



void fragment() {
	NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	ALBEDO = vec3(39.0 / 256.0, 174.0 / 256.0, 96.0 / 256.0);

//	ALBEDO = vec3(UV.x / 10.0, 0.0, UV.y / 10.0);

//	ALBEDO = vec3(modf(SCREEN_UV.x, 10.0), 0.0, modf(SCREEN_UV.y, 10.0));
	

//	ALBEDO = vec3(UV.x * 2.0, 0.0, UV.y * 2.0);
}


//	vec2 texture_pos = vec2(mod(VERTEX.x, 32.0), mod(VERTEX.z, 32.0));
//	vec2 texture_pos = vec2(0);
//	ALBEDO = texture(grass_texture, UV).rgb;

