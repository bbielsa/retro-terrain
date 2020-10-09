shader_type spatial;

uniform sampler2D texture_atlas;

void fragment() {
	NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	ALBEDO = texture(texture_atlas, UV).rgb;

	if(UV2.x < 0.04)
		ALBEDO *= 0.8;
}
