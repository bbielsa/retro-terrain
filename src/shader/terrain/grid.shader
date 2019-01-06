shader_type spatial;

uniform sampler2D tile_texture_0;
uniform sampler2D tile_texture_1;
uniform sampler2D tile_texture_2;
uniform sampler2D tile_texture_3;
uniform sampler2D tile_texture_4;

void vertex() {
	VERTEX.y += sin(TIME);	
}

void fragment() {
	ALBEDO = COLOR.rgb;
	
	if(UV2.x < 0.04){
		ALBEDO *= 0.8;
	}
}