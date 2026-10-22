shader_type spatial;

group_uniforms Albedo;
/** Used for the albedo tint of the object. */
uniform vec3 base_color : source_color = vec3(1.0f);
/** Used for the albedo tint of the object. */
uniform sampler2D base_texture : source_color;
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

group_uniforms Foam;
uniform vec3 foam_color : source_color = vec3(1.0f);
uniform float foam_thickness : hint_range(0.0f, 1.0f) = 0.1f;
uniform sampler2D foam_random_texture : hint_default_black;
uniform float foam_random_strength : hint_range(0.0f, 1.0f) = 0.1f;
uniform vec2 foam_random_tiling = vec2(1.0f);
uniform float foam_random_flow : hint_range(0.0f, 1.0f) = 0.5f;
group_uniforms;

group_uniforms Absorption;
uniform float absorption_strength : hint_range(0.0f, 20.0f) = 1.0f;
group_uniforms;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable;

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
	vec3 col = texture(base_texture, UV).rgb * base_color;
	
	float depth = texture(depth_texture, SCREEN_UV).r;
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth, 1.0);
    vec3 view_position = upos.xyz / upos.w;
	
	float raw_depth_offset = abs(view_position.z - VERTEX.z);
	
	// Compare object depth with scene depth to find foam, using noise offset.
	float foam_texture_sample = texture(foam_random_texture, UV * foam_random_tiling + TIME * foam_random_flow).r;
	float foam_depth_offset = raw_depth_offset - foam_texture_sample * foam_random_strength;
	float foam = 1.0f - smoothstep(foam_thickness, foam_thickness + 0.01f, foam_depth_offset);
	
	// Fade color based on absorbed light at greater depths.
	vec3 screen_color = texture(screen_texture, SCREEN_UV).rgb;
	float depth_fade = clamp(raw_depth_offset * absorption_strength, 0.0f, 1.0f);
	col = mix(screen_color, col, depth_fade);
	
	// Mix in the wave trough darkening value.
	float tint = (displacement / wave_height + 1.0f) * 0.5f;
	col *= mix(1.0 - wave_darkening, 1.0f, tint);
	
	ALBEDO = mix(col, foam_color, foam);
}
