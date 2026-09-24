shader_type spatial;
render_mode cull_disabled;

#include "res://Shaders/noise.gdshaderinc"

group_uniforms AlbedoColor;
/** Used for the albedo tint of the object. */
uniform vec3 base_color : source_color = vec3(1.0f);
/** Used for the albedo tint of the object. */
uniform sampler2D base_texture : source_color;
group_uniforms;

group_uniforms Dissolve;
uniform float noise_scale : hint_range(1.0f, 250.0f) = 100.0f;
uniform float noise_strength : hint_range(0.0f, 1.0f) = 0.5f;
uniform float cutoff_height = 0.0f;
uniform float cutoff_width : hint_range(0.0f, 0.5f) = 0.05f;
uniform float cycle_speed : hint_range(0.0f, 1.0f) = 0.25f;
uniform vec3 cutoff_emission : source_color = vec3(0.0f);
group_uniforms;

varying vec3 world_position;

void vertex()
{
	// Called for every vertex the material is visible on.
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0f)).xyz;
}

void fragment()
{
	vec4 col = texture(base_texture, UV);
	ALBEDO = base_color * col.rgb;
	
	float dist_from_center, dist_from_edge;
	voronoi_noise(UV, noise_scale, dist_from_center, dist_from_edge, TIME * cycle_speed);
	float noise = (dist_from_edge - 0.5f) * noise_strength;
	float height = world_position.y - noise;
	
	if(height > cutoff_height)
	{
		discard;
	}
	
	float edge = step(cutoff_height - cutoff_width, height);
    EMISSION += edge * cutoff_emission;
	ALBEDO = mix(ALBEDO, cutoff_emission, edge);
}
