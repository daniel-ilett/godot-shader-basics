shader_type spatial;

group_uniforms NormalVector;
/** Used to offset the surface normals for lighting. Default is flat. */
uniform sampler2D normal_texture : hint_normal;
/** Strength of the normal vector offset. */
uniform float normal_strength : hint_range(0.0f, 4.0f) = 1.0f;
uniform vec2 normal_tiling = vec2(1.0f);
group_uniforms;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable;

uniform float refractive_index : hint_range(1.0f, 25.0f) = 1.0f;

void vertex()
{
	
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
	vec3 offset = refract(VIEW, NORMAL, -1.0f / refractive_index);
	
	ALBEDO = texture(screen_texture, SCREEN_UV + (offset.xy / offset.z) * 0.05f).rgb;
	ALPHA = 1.0f;
	ROUGHNESS = 0.0f;
	METALLIC = 0.0f;
	
	NORMAL_MAP = normalMapStrength(texture(normal_texture, UV * normal_tiling).xyz, normal_strength);
	
	/*
	vec3 normal = normalize(normalWS);
	vec3 tangent = normalize(tangentWS);
	vec3 bitangent = normalize(bitangentWS);
	mat3 world_to_tangent = mat3(tangent, bitangent, normal);
	
	vec3 offset_world = refract(normalize(viewWS), normal, -1.0f / refractive_index);
	
	vec3 offset_tangent = world_to_tangent * offset_world;
	
	ALBEDO = texture(screen_texture, SCREEN_UV + offset_tangent.xy * 0.1f).rgb;
	ALBEDO = vec3(offset_tangent.xy * 0.1f, 0.0f);
	ALPHA = 1.0f;
	*/
}
