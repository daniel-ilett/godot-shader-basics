shader_type spatial;

/** Used for the albedo tint of the object. */
uniform vec3 base_color : source_color = vec3(1.0f);
/** Used for the albedo tint of the object. */
uniform sampler2D base_texture : source_color, filter_nearest;

void vertex()
{
	// Called for every vertex the material is visible on.
}

void fragment()
{
	vec4 col = texture(base_texture, UV);
	ALBEDO = base_color * col.rgb;
}
