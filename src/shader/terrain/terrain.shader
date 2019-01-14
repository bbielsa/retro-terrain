shader_type spatial;

uniform sampler2D height_map;
uniform sampler2D grass_texture;

void vertex() {
	float height = texture(height_map, VERTEX.xz / 10.0).r * 255.0;
	bool middle_vertex = VERTEX.x - floor(VERTEX.x) > 0.0;
	
	height /= 4.0;
	
	if(middle_vertex)
		VERTEX.y = 0.0;
	else
		VERTEX.y = height;	
}

void fragment() {
	bool middle_vertex = VERTEX.x - floor(VERTEX.x) > 0.0;
	
	if(middle_vertex)
		NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));

	ALBEDO = vec3(39.0 / 256.0, 174.0 / 256.0, 96.0 / 256.0);

	if (UV2.x < 0.04) {
		ALBEDO *= 0.8;
	}
}


//	vec2 texture_pos = vec2(mod(VERTEX.x, 32.0), mod(VERTEX.z, 32.0));
//	vec2 texture_pos = vec2(0);
//	ALBEDO = texture(grass_texture, UV).rgb;

