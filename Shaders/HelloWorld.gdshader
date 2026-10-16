shader_type spatial;

/** Albedo color of the object when lighting is not applied. */
uniform vec3 base_color : source_color = vec3(1.0f, 1.0f, 1.0f);

void vertex()
{

}

void fragment()
{
	ALBEDO = base_color;
}
