shader_type spatial;

/** Used for the albedo tint of the object. */
uniform vec3 base_color : source_color = vec3(1.0f);
/** Used for the albedo tint of the object. */
uniform sampler2D base_texture : source_color, filter_nearest;

/** How much to rotate the UVs. Full rotation = 2pi. */
uniform float rotation_radians : hint_range(0.0f, 2.0f * PI) = 0.0f;
/** Center point, in UV space, to rotate around. */
uniform vec2 rotation_center = vec2(0.5f, 0.5f);

void vertex()
{
	// Called for every vertex the material is visible on.
}

void fragment()
{
	float s = sin(rotation_radians);
	float c = cos(rotation_radians);
	mat2 rotation_matrix = mat2(vec2(c, -s), vec2(s, c));
	
	vec2 uv = rotation_matrix * (UV - rotation_center) + rotation_center;
	vec4 col = texture(base_texture, uv);
	ALBEDO = base_color * col.rgb;
}
