shader_type canvas_item;

uniform vec4 reddish = vec4(100,0,0,.25);
uniform bool on;

void fragment() {
	if(on){
    	vec4 texture_color = texture(TEXTURE, UV);
    	COLOR = COLOR = vec4(mix(texture_color.rgb, reddish.rgb, reddish.a), texture_color.a);
	}
}