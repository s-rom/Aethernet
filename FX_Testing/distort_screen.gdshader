shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DISTORTION_TEXTURE;


void vertex() {
	// Called for every vertex the material is visible on.
}



void fragment() {
	// Called for every pixel the material is visible on.
	
	float s = sin(TIME);
	
	vec2 distortedUV = SCREEN_UV + s * texture(DISTORTION_TEXTURE, UV).a * 0.05;	
	
	vec4 screen = texture(SCREEN_TEXTURE, distortedUV);
	
	if (UV.x == UV.y)
	{
		COLOR = vec4(1.0);
	}
	else 
	{
		COLOR = screen;
	}
}
