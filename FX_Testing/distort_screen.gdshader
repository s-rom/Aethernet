shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DISTORTION_TEXTURE;


void vertex() {
	// Called for every vertex the material is visible on.
}



void fragment() {
	// Called for every pixel the material is visible on.
	
	vec2 distortedUV = SCREEN_UV +  texture(DISTORTION_TEXTURE, UV).a * 0.05;	
	
	vec4 distortedScreen = texture(SCREEN_TEXTURE, distortedUV);
	vec4 screen = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	float circle = distance(UV, vec2(0.5, 0.5));
	float alpha = smoothstep(0.0, 0.4, circle); 

	
	COLOR = distortedScreen * (1.0 - alpha);
}
