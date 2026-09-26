shader_type spatial;
render_mode cull_disabled, world_vertex_coords;

group_uniforms Albedo;
/** Used for the albedo tint of the object. */
uniform vec4 base_color : source_color = vec4(1.0f);
/** Used for the albedo tint of the object. */
uniform sampler2D base_texture : source_color;
group_uniforms;

group_uniforms Normals;
/** Used to offset the surface normals for lighting. Default is flat. */
uniform sampler2D normal_texture : hint_normal;
/** Strength of the normal vector offset. */
uniform float normal_strength : hint_range(0.0f, 4.0f) = 1.0f;
uniform float normal_scroll : hint_range(0.0f, 1.0f) = 0.5f;
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
uniform float foam_thickness : hint_range(0.0f, 1.0f) = 0.1f;
uniform sampler2D foam_random_texture : hint_default_black;
uniform float foam_random_strength : hint_range(0.0f, 1.0f) = 0.1f;
uniform vec2 foam_random_tiling = vec2(1.0f);
uniform float foam_random_flow : hint_range(0.0f, 1.0f) = 0.5f;
group_uniforms;

uniform sampler2D depth_texture : hint_depth_texture;

varying float displacement;

void vertex()
{
	vec3 pos = VERTEX;
	displacement = sin((pos.x + pos.z) * wave_scale + TIME * 2.0f * PI * wave_speed) * wave_height;
	pos.y += displacement;

	VERTEX = pos;
}

vec3 normalMapStrength(vec3 normal, float strength)
{
	vec3 newNormal;
	newNormal = normal - 0.5f;
    newNormal.xy *= strength;

    return newNormal + 0.5f;
}

void fragment()
{
	vec4 col = texture(base_texture, UV) * base_color;

	float tint = (displacement / wave_height + 1.0f) * 0.5f;
	tint = mix(1.0 - wave_darkening, 1.0f, tint);

	float raw_depth = texture(depth_texture, SCREEN_UV).r;
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, raw_depth, 1.0);
    vec3 pixel_position = upos.xyz / upos.w;

	float depth_offset = abs(pixel_position.z - VERTEX.z);
	depth_offset -= texture(foam_random_texture, UV * foam_random_tiling + TIME * foam_random_flow).r * foam_random_strength;
	float foam = step(foam_thickness, depth_offset);

	ALBEDO = mix(vec3(1.0f), col.rgb * tint, foam);
	ALPHA = col.a;

	NORMAL_MAP = normalMapStrength(texture(normal_texture, UV + (TIME * normal_scroll) * vec2(-1, 1)).xyz, normal_strength);
}
