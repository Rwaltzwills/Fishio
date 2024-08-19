shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture;
uniform vec2 speed = vec2(0.5, 0.2);
uniform float distortion = 0.01;
uniform vec2 scroll_speed = vec2(0.1,0.1);

void fragment() {
	COLOR = texture(TEXTURE,UV+sin(scroll_speed)*TIME);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
