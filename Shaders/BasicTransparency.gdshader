shader_type spatial;
render_mode blend_mix;

/** Used for the albedo tint of the object. */
uniform vec4 base_color : source_color = vec4(1.0f);
/** Used for the albedo tint of the object. */
uniform sampler2D base_texture : source_color;

void vertex()
{
	// Called for every vertex the material is visible on.
}

void fragment()
{
	vec4 col = texture(base_texture, UV) * base_color;
	ALBEDO = col.rgb;
	ALPHA = col.a;
	//ALPHA_SCISSOR_THRESHOLD = 0.5f;
}
