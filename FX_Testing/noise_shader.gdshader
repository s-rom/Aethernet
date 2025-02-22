shader_type canvas_item;

uniform sampler2D noiseTexture: repeat_enable;
uniform sampler2D noiseTexture2: repeat_enable;
uniform sampler2D colorTexture;

uniform vec2 scroll;
uniform vec2 scroll2;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {

	float noise1 = texture(noiseTexture, UV + scroll * TIME).r;
	float noise2 = texture(noiseTexture2, UV + scroll2  * TIME).r;
	float energy = noise1 * noise2; // - (1.0- UV.y) * 0.5;

	vec4 originalTexture = texture(TEXTURE, UV);

	//COLOR = vec4(energy, energy, energy, 1.0);
	vec4 fireTexture = texture(colorTexture, vec2(energy));



    float alpha = smoothstep(0.2, 0.8, originalTexture.b);
	COLOR = fireTexture;

	//float fade = smoothstep(0.0, 0.3, fireTexture.r);
    //alpha *= fade;
	//vec3 color = fireTexture.rgb * alpha;
	//COLOR = vec4(color, alpha);

	//if (originalTexture.b > 0.4)
	//{
		//COLOR = fireTexture;
	//}
	//else
	//{
		//COLOR = vec4(0.0);
	//}


}
