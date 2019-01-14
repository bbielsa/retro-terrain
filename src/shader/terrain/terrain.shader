shader_type spatial;

uniform sampler2D height_map;
uniform sampler2D grass_texture;

void vertex() {
		float height = texture(height_map, VERTEX.xz / 10.0).r;

//		VERTEX.y = height;

//	if(VERTEX.x == 4.0 && VERTEX.z == 4.0)
//		VERTEX.y = 1.0;

	VERTEX.y += height * 255.0;
}

void fragment() {	
	NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));

//	ALBEDO = texture(height_map, VERTEX.xz).rgb;
	ALBEDO = vec3(1.0);
//	ALBEDO = vec3(39.0 / 256.0, 174.0 / 256.0, 96.0 / 256.0);
//	ALBEDO = vec3(UV.x, 1.0, UV.y);
//	if (UV.x > 0.9)
//		ALBEDO = vec3(0.0);	
	if (UV2.x < 0.04) {
		ALBEDO *= 0.8;
	}
}


//	vec2 texture_pos = vec2(mod(VERTEX.x, 32.0), mod(VERTEX.z, 32.0));
//	vec2 texture_pos = vec2(0);
//	ALBEDO = texture(grass_texture, UV).rgb;

