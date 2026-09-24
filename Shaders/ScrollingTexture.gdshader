shader_type spatial;

/** Used for the albedo tint of the object. */
uniform vec3 base_color : source_color = vec3(1.0f);
/** Used for the albedo tint of the object. */
uniform sampler2D base_texture : source_color, filter_nearest, repeat_disable;
/** Speed of UV offset scrolling. */
uniform float scroll_speed : hint_range(0.0f, 5.0f) = 1.0f;

void vertex()
{
	// Called for every vertex the material is visible on.
}

void fragment()
{
	vec2 scroll_uv = UV + TIME * scroll_speed;
	vec4 col = texture(base_texture, scroll_uv);
	ALBEDO = base_color * col.rgb;
}
