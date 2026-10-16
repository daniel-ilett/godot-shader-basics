shader_type spatial;

/** Used for the albedo tint of the object. */
uniform vec3 base_color : source_color = vec3(1.0f);
/** Used for the albedo tint of the object. */
uniform sampler2D base_texture : source_color;

varying vec4 color;

void vertex()
{
	// Called for every vertex the material is visible on.
	color = COLOR;
}

void fragment()
{
	vec4 col = texture(base_texture, UV);
	ALBEDO = base_color * col.rgb * color.rgb;
}

void light()
{
	DIFFUSE_LIGHT += step(0.0f, dot(NORMAL, LIGHT));
	SPECULAR_LIGHT += step(0.1f, pow(max(0.0f, dot(reflect(-LIGHT, NORMAL), VIEW)), 50.0f));
}
