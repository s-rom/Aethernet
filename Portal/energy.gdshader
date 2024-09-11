shader_type canvas_item;

uniform float dt = 0.1f;

void fragment(){
	float pi = 3.14;
	vec2 position = UV;
	float distance_to_center = distance(position, vec2(0.5, 0.5));
	float rotation_index = distance_to_center * 5.f + dt;
	
	position -= vec2(0.5, 0.5);
	mat2 rotation_matrix = mat2(vec2(sin(rotation_index), -cos(rotation_index)),
								vec2(cos(rotation_index), sin(rotation_index)));
	position = position*rotation_matrix;
	position += vec2(0.5, 0.5);
	
	COLOR = texture(TEXTURE, position);
	
	if (COLOR.a > 0.f) {
		COLOR.a = 0.05f;
		COLOR.a = sin(COLOR.a);
	}
	
	
	
}
