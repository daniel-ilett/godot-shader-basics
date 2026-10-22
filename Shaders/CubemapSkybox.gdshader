shader_type spatial;
render_mode depth_draw_never, cull_front;

uniform samplerCube skybox_texture : source_color;
uniform float rotation_radians : hint_range(0.0, 2.0f * PI) = 0.0f;

void fragment() 
{
	
}
