shader_type spatial;

/** Used for the albedo tint of the object. */
uniform vec4 base_color : source_color = vec4(1.0f);
/** Used for the albedo tint of the object. */
uniform sampler2D base_texture : source_color;

float dither_threshold(vec2 screen_position, vec2 screen_size)
{
    vec2 uv = screen_position * screen_size;
    
    const float DITHER_THRESHOLDS[16] =
    {
        1.0 / 17.0, 	9.0 / 17.0, 	3.0 / 17.0, 	11.0 / 17.0,
        13.0 / 17.0, 	5.0 / 17.0, 	15.0 / 17.0, 	7.0 / 17.0,
        4.0 / 17.0, 	12.0 / 17.0, 	2.0 / 17.0, 	10.0 / 17.0,
        16.0 / 17.0, 	8.0 / 17.0, 	14.0 / 17.0, 	6.0 / 17.0
    };
    
    int index = (int(uv.x) % 4) * 4 + int(uv.y) % 4;
    return DITHER_THRESHOLDS[index];
}

void vertex()
{
	// Called for every vertex the material is visible on.
}

void fragment()
{
	vec4 col = texture(base_texture, UV) * base_color;
	ALBEDO = col.rgb;
	ALPHA = col.a;
	ALPHA_SCISSOR_THRESHOLD = dither_threshold(SCREEN_UV, VIEWPORT_SIZE);
}
