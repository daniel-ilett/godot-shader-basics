shader_type spatial;
render_mode unshaded, skip_vertex_transform;

uniform vec3 base_color : source_color = vec3(1.0f, 1.0f, 1.0f);

void vertex()
{
	POSITION = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	//VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0f)).xyz;
	//VERTEX = (VIEW_MATRIX * (MODEL_MATRIX * vec4(VERTEX, 1.0f))).xyz;
	
	NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
    BINORMAL = normalize((MODELVIEW_MATRIX * vec4(BINORMAL, 0.0)).xyz);
    TANGENT = normalize((MODELVIEW_MATRIX * vec4(TANGENT, 0.0)).xyz);
}

void fragment()
{
	ALBEDO = base_color;
}
