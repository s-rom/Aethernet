shader_type canvas_item;

uniform sampler2D noiseTexture: repeat_enable;
uniform sampler2D noiseTexture2: repeat_enable;


uniform float rotationSpeed: hint_range(-5.0, 5.0);
uniform float rotationSpeed2: hint_range(-5.0, 5.0);

uniform float hdr_intensity: hint_range(0.0, 10.0);
uniform vec4 hdr_color: source_color;
uniform vec2 scroll;
uniform vec2 scroll2;

uniform sampler2D colorTexture;

uniform float radius: hint_range(0.0, 1.0);



float get_energy(sampler2D noise, vec2 uv, float rotSpeed, vec2 scrollVec)
{
	vec2 center = vec2(0.5, 0.5);
	
	float w = TIME * -rotSpeed;
	mat2 rot = mat2(vec2(-cos(w), -sin(w)),
	         vec2(sin(w),  -cos(w)));
	
	vec2 rotatedUV = uv - center;
	rotatedUV = rot * rotatedUV;
	rotatedUV += center;
	rotatedUV += TIME * scrollVec;

	return texture(noise, rotatedUV).r;
}

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	float circle = smoothstep(radius, 0.00, distance(center, UV));
	
	
	float noise = get_energy(noiseTexture, UV, rotationSpeed, scroll) * circle;
	float noise2 = get_energy(noiseTexture2, UV, rotationSpeed2, scroll2) * circle;
	float energy = noise * noise2;
	vec4 coloredNoise = texture(colorTexture, vec2(energy));

	COLOR = coloredNoise * hdr_color * hdr_intensity; // * texture(TEXTURE, UV);
}
