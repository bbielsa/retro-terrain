shader_type spatial;

void vertex() {
	if(VERTEX.y > 0.0) {
		VERTEX.y = max(0, sin(TIME + VERTEX.x + VERTEX.z));	
	}
}

void fragment() {	
	NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	// green color
	ALBEDO = vec3(39.0 / 256.0, 174.0 / 256.0, 96.0 / 256.0);
}
