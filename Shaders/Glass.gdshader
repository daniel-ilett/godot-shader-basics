shader_type spatial;

uniform float refractive_index : hint_range(1.0f, 15.0f) = 1.0f;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable;

void vertex()
{
	
}

void fragment()
{
	ALPHA = 1.0f;
	ROUGHNESS = 0.0f;
	
	vec3 offset = refract(-VIEW, NORMAL, 1.0f / refractive_index);
	ALBEDO = texture(screen_texture, SCREEN_UV + (offset.xy / offset.z) * 0.1f).rgb;
}
