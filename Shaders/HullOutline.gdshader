shader_type spatial;
render_mode cull_front, unshaded;

/** Thickness of the outline in meters. */
uniform float outline_width : hint_range(0.0f, 0.2f) = 0.02f;
/** Color of the outline (unshaded). */
uniform vec4 outline_color : source_color = vec4(vec3(0.0f), 1.0f);

void vertex() 
{
	VERTEX += NORMAL * outline_width;
}

void fragment() 
{
	ALBEDO = outline_color.rgb;	
}
