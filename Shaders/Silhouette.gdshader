shader_type spatial;
render_mode unshaded;

uniform vec4 near_color : source_color = vec4(1.0f);
uniform vec4 far_color : source_color = vec4(0.0f);
uniform float depth_divisor = 4000.0f;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable;

void vertex()
{
	
}

void fragment()
{
	float depth = texture(depth_texture, SCREEN_UV).r;
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth, 1.0);
    vec3 view_position = upos.xyz / upos.w;
	
	float depth_distance = clamp(-view_position.z / depth_divisor, 0.0f, 1.0f);
	
	ALBEDO = mix(near_color, far_color, depth_distance).rgb;
}
