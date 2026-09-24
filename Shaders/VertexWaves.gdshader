shader_type spatial;
render_mode cull_disabled;

group_uniforms Albedo;
/** Used for the albedo tint of the object. */
uniform vec3 base_color : source_color = vec3(1.0f);
/** Used for the albedo tint of the object. */
uniform sampler2D base_texture : source_color, filter_nearest;
group_uniforms;

group_uniforms Waves;
/** How quickly to scroll waves over time. */
uniform float wave_speed : hint_range(0.0f, 5.0f) = 0.5f;
/** Maximum height (and depth) of the waves in meters. */
uniform float wave_height : hint_range(0.0f, 0.5f) = 0.1f;
/** How close together the waves should be. */
uniform float wave_scale : hint_range(0.0f, 10.0f) = 1.0f;
/** How strongly to darken the tint of wave troughs. */
uniform float wave_darkening : hint_range(0.0f, 1.0f) = 0.5f;
group_uniforms;

varying float displacement;

void vertex()
{
	vec3 pos = VERTEX;
	displacement = sin((pos.x + pos.z) * wave_scale + TIME * 2.0f * PI * wave_speed) * wave_height;
	pos.y += displacement;
	
	VERTEX = pos;
}

void fragment()
{
	vec4 col = texture(base_texture, UV);
	
	float tint = (displacement / wave_height + 1.0f) * 0.5f;
	//tint = tint * wave_darkening + (1.0f - wave_darkening);
	tint = mix(1.0 - wave_darkening, 1.0f, tint);
	
	ALBEDO = base_color * col.rgb * tint;
	
	//NORMAL = normalize(cross(dFdy(VERTEX), dFdx(VERTEX)));
}
