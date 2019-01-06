shader_type spatial;

uniform sampler2D height_map;

void vertex() {
	
	
	if(VERTEX.y > 0.0) {
		float height = texture(height_map, UV).r * 256.0;
		
		VERTEX.y = height;
		
	}
}

void fragment() {	
	NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));

	ALBEDO = vec3(39.0 / 256.0, 174.0 / 256.0, 96.0 / 256.0);

	//ALBEDO = vec3(UV.x, 0, UV.y);

//	if(UV.x < 1.0){
//		ALBEDO *= 0.8;
//	}
}
