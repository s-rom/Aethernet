shader_type canvas_item;

void vertex(){
	float w = TIME;
	mat2 rot = mat2(vec2(-cos(w), -sin(w)),
	         vec2(sin(w),  -cos(w)));

	vec2 rotatedVertex = (rot * (VERTEX - vec2(0.5, 0.5))) + vec2(0.5, 0.5);

	VERTEX = rotatedVertex;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	COLOR = tex;
}
