shader_type canvas_item;
render_mode unshaded;

uniform float Shift_Hue;

// Source: https://gist.github.com/McSpider/c8c693f1065fdb5ec44c64cb9fdac340
/*
Duplicate the shader so that changing its param doesn't change it on any other sprites that also use the shader.
Generally done once in _ready()
$TheSprite.set_material($TheSprite.get_material().duplicate(true))

Offset sprite hue by a random value within specified limits.
var rand_hue = float(randi() % 3)/2.0/3.2
$TheSprite.material.set_shader_parameter("Shift_Hue", rand_hue)
*/

void fragment() {
// Input:3
	vec3 input_color;
	vec4 texture_color = texture(TEXTURE, UV);
	input_color = texture_color.rgb;

// VectorFunc:2
	vec3 color_hsv;
	{
		vec3 c = input_color;
		vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
		vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
		vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
		float d = q.x - min(q.w, q.y);
		float e = 1.0e-10;
		color_hsv=vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	}

	color_hsv.x = mod((color_hsv.x + Shift_Hue), 1.0f);

// VectorFunc:5
	vec3 color_rgb;
	{
		vec3 c = color_hsv;
		vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
		vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
		color_rgb=c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
	}

// Output:0
	texture_color = vec4(color_rgb.rgb,texture_color.a);
	COLOR.rgba = texture_color;

}