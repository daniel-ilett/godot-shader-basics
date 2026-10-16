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

group_uniforms Water;
uniform float water_opacity : hint_range(0.0f, 1.0f) = 0.5f;
uniform float refraction_strength : hint_range(0.0f, 1.0f) = 1.0f;
uniform vec2 world_height_opacity = vec2(0.0f, 0.25f);
group_uniforms;

group_uniforms Foam;
uniform float foam_thickness : hint_range(0.0f, 1.0f) = 0.1f;
uniform sampler2D foam_random_texture : hint_default_black;
uniform float foam_random_strength : hint_range(0.0f, 1.0f) = 0.1f;
uniform vec2 foam_random_tiling = vec2(1.0f);
uniform float foam_random_flow : hint_range(0.0f, 1.0f) = 0.5f;
group_uniforms;

uniform sampler2D screen_texture : hint_screen_texture;
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
	// Sample foam texture, also used for heightmap.
	float foam_texture_sample = texture(foam_random_texture, UV * foam_random_tiling + TIME * foam_random_flow).r;
	float foam_normal_strength = 0.05f;

	// Calculate normal vector from foam height map (central difference).
	// https://www.leadwerks.com/community/topic/16244-calculate-normals-from-heightmap/
	float dx = dFdx(foam_texture_sample);
    float dy = dFdy(foam_texture_sample);

	vec3 tangent = normalize(vec3(2.0f, dx, 2.0f));
	vec3 binormal = normalize(vec3(2.0f, dy, 2.0f));
	vec3 normal = cross(tangent, binormal);

	normal = normalize(vec3(2.0f * dx, 2.0f * dy, -4.0f));

	NORMAL_MAP = normal * 7.0f;
	//NORMAL = normalize(NORMAL + normal * 20.0f);

	// Original depth.
	float depth = texture(depth_texture, SCREEN_UV).r;

	// Offset depth.
	float offset_depth = texture(depth_texture, SCREEN_UV + normal.xy * refraction_strength).r;
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, offset_depth, 1.0);
    vec3 pixel_position = upos.xyz / upos.w;

	// Compare object depth with scene depth to find foam.
	float depth_offset = abs(pixel_position.z - VERTEX.z);
	depth_offset -= foam_texture_sample * foam_random_strength;
	float foam = smoothstep(foam_thickness, foam_thickness + 0.05f, depth_offset);

	// Increase water opacity based on world height.
	vec3 world_height = (INV_VIEW_MATRIX * vec4(pixel_position, 1.0f)).xyz;
	float opacity = smoothstep(world_height_opacity.x, world_height_opacity.y, world_height.y);

	// Mix between refracted screen color and water color.
	vec3 screen_color = texture(screen_texture, SCREEN_UV).rgb;
	vec3 offset_color = texture(screen_texture, SCREEN_UV + normal.xy * refraction_strength).rgb;
	vec4 water_color = texture(base_texture, UV) * base_color;
	water_color.rgb = mix(depth > offset_depth ? offset_color : screen_color, water_color.rgb, 1.0f - opacity);

	// Multiply by wave trough tint.
	float tint = (displacement / wave_height + 1.0f) * 0.5f;
	tint = mix(1.0 - wave_darkening, 1.0f, tint);
	water_color.rgb *= tint;

	ALBEDO = mix(vec3(1.0f), water_color.rgb, foam);
	ALPHA = water_color.a;
}
