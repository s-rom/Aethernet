shader_type canvas_item;


uniform sampler2D noise: repeat_enable;
uniform sampler2D noise2: repeat_enable;
uniform sampler2D color_texture;

uniform vec4 hdr_color: source_color;
uniform float hdr_intensity;

uniform float width: hint_range(0.0, 1.0);
uniform float height: hint_range(0.0, 1.0);

uniform vec2 noise_movement = vec2(0.1, 0.1);
uniform vec2 noise2_movement = vec2(0.1, 0.1);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	float noise_value = texture(noise, UV  +  TIME * noise_movement).r;
	float noise_value2 = texture(noise2, UV  +  TIME * noise2_movement).r;
	vec4 color = COLOR;
	float energy = noise_value * noise_value2; 
	vec4 colored_noise = texture(color_texture, vec2(energy));
	
	float alpha = smoothstep(1.0 - width, 0.0, UV.y);
	alpha += smoothstep(1.0 - width, 0.0, 1.0 - UV.y);
	
	alpha += smoothstep(1.0 - height, 0.0, 1.0 - UV.x);
	alpha += smoothstep(1.0 - height, 0.0, UV.x);
	
	alpha = clamp(alpha, 0.0, 1.0);

	
	colored_noise *= 1.0 - alpha;
	
	COLOR = colored_noise * hdr_color * hdr_intensity;
	//COLOR.a *= 1.0 - alpha;
}

