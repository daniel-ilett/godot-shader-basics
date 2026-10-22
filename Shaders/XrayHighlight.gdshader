shader_type spatial;
render_mode depth_test_inverted, depth_draw_never;

/** Used for the albedo tint of the object. */
uniform vec3 base_color : source_color = vec3(1.0f);
/** Used for the albedo tint of the object. */
uniform sampler2D base_texture : source_color;

void fragment()
{
	vec4 col = texture(base_texture, UV);
	ALBEDO = base_color * col.rgb;
}
