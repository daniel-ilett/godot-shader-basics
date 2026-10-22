shader_type spatial;
stencil_mode read, 1, compare_equal;

/** Used for the albedo tint of the object. */
uniform vec3 base_color : source_color = vec3(1.0f);
/** Used for the albedo tint of the object. */
uniform sampler2D base_texture : source_color;

void vertex()
{
	// Called for every vertex the material is visible on.
}

void fragment()
{
	vec4 col = texture(base_texture, UV);
	ALBEDO = base_color * col.rgb;
	ALPHA = 1.0f;
}
