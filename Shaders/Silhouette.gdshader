shader_type spatial;
render_mode unshaded;

uniform vec4 near_color : source_color = vec4(1.0f);
uniform vec4 far_color : source_color = vec4(0.0f);

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable;

void vertex()
{
	
}

void fragment()
{
	ALPHA = 1.0f;
	float depth = texture(depth_texture, SCREEN_UV).r;
	ALBEDO = mix(far_color, near_color, depth * 10.0f).rgb;
}
