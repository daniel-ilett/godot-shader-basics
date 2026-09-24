shader_type spatial;

const float EPSILON = 1e-5;

group_uniforms TilingAndOffset;
/** How many times to tile the texture samples over the 0-1 UV range. */
uniform vec2 uv_tiling = vec2(1.0f);
/** Offset applied to UVs before sampling. */
uniform vec2 uv_offset = vec2(0.0f);
group_uniforms;

group_uniforms AlbedoColor;
/** Used for the albedo tint of the object. */
uniform vec3 base_color : source_color = vec3(1.0f);
/** Used for the albedo tint of the object. */
uniform sampler2D base_texture : source_color;
group_uniforms;

group_uniforms NormalVector;
/** Used to offset the surface normals for lighting. Default is flat. */
uniform sampler2D normal_texture : hint_normal;
/** Strength of the normal vector offset. */
uniform float normal_strength : hint_range(0.0f, 4.0f) = 1.0f;
group_uniforms;

group_uniforms Metallic;
/** How metallic the surface is. Default is white.
  * Reads from the red channel of the texture. */
uniform sampler2D metallic_texture : hint_default_white;
/** How metallic the surface is (global multiplier). */
uniform float metallic : hint_range(0.0f, 1.0f) = 0.0f;
group_uniforms;

group_uniforms AmbientOcclusion;
/** How much light can reach into cracks on the surface. Default is white.
  * Reads from the green channel of the texture. */
uniform sampler2D occlusion_texture : hint_default_white;
/** How much light can reach into cracks on the surface (global multiplier). */
uniform float occlusion : hint_range(0.0f, 1.0f) = 1.0f;
group_uniforms;

group_uniforms HeightMap;
/** Height-based offset for UVs. Default is white.
  * Reads from the blue channel of the texture. */
uniform sampler2D heightmap_texture : hint_default_white;
/** How strongly to apply height offset (global multiplier). */
uniform float height : hint_range(0.0f, 0.1f) = 0.0f;
group_uniforms;

group_uniforms Roughness;
/** How rough the surface is for lighting calculations. Default is white.
  * Reads from the alpha channel of the texture. */
uniform sampler2D roughness_texture : hint_default_white;
/** How rough the surface is for lighting calculations (global multiplier). */
uniform float roughness : hint_range(0.0f, 1.0f) = 1.0f;
group_uniforms;

group_uniforms EmissionColor;
/** Color to emit from the surface, unaffected by being in shadow. Default is white. */
uniform sampler2D emission_texture : hint_default_white;
/** Color to emit from the surface, unaffected by being in shadow (gloabl multiplier). */
uniform vec3 emission_color : source_color = vec3(0.0f);
group_uniforms;

group_uniforms ClearCoat;
/** Should the shader apply a thin transparent layer to the surface? */
uniform bool use_clear_coat = false;

/** Which parts of the surface have a clear coat applied. Default is white. */
uniform sampler2D clearcoat_texture : hint_default_white;
/** Which parts of the surface have a clear coat applied (global multiplier). */
uniform float clearcoat : hint_range(0.0f, 1.0f) = 0.0f;

/** Roughness of portions of the surface with a clear coat. Default is white. */
uniform sampler2D clearcoat_roughness_texture : hint_default_white;
/** Roughness of portions of the surface with a clear coat (global multiplier). */
uniform float clearcoat_roughness : hint_range(0.0f, 1.0f) = 1.0f;
group_uniforms;

void vertex()
{
	// Called for every vertex the material is visible on.
}

// Adapted from: https://godotshaders.com/shader/parallax-mapping-2/
vec2 parallax(float height_amount, vec3 n, vec3 t, vec3 b, vec3 v)
{
	vec3 view_tangent = vec3(dot(v, t), dot(v, b), dot(v, n));
	vec2 offset = (view_tangent.xy / max(view_tangent.z, EPSILON)) * (1.0f - height_amount);
	
	return vec2(-offset.x, offset.y);
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
	vec2 uv = UV * uv_tiling + uv_offset;
	float height_offset = texture(heightmap_texture, uv).b;
	
	uv += parallax(height_offset, NORMAL, TANGENT, BINORMAL, VIEW) * height;
	
	vec4 col = texture(base_texture, uv);
	ALBEDO = base_color * col.rgb;
	
	NORMAL_MAP = normalMapStrength(texture(normal_texture, uv).xyz, normal_strength);
	
	METALLIC = texture(metallic_texture, uv).r * metallic;
	
	ROUGHNESS = texture(roughness_texture, uv).a * roughness;
	
	AO = texture(occlusion_texture, uv).g * occlusion;
	
	EMISSION = texture(emission_texture, uv).rgb * emission_color;
	
	if(use_clear_coat)
	{
		CLEARCOAT = texture(clearcoat_texture, uv).r * clearcoat;
		CLEARCOAT_ROUGHNESS = texture(clearcoat_roughness_texture, uv).g * clearcoat_roughness;
	}
}
