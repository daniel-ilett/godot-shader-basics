const float EPSILON = 1e-5;

vec2 random_vector(vec2 seed, float timeOffset)
{
	vec2 value = vec2(dot(seed, vec2(127.1f, 311.7f)),
		dot(seed, vec2(269.5f, 183.3f)));

	vec2 a = sin(value) * 43758.5453f + timeOffset;
    return vec2(sin(a.x), cos(a.y));
}

float perlin_noise_single_octave(vec2 uv, float timeOffset)
{
    vec2 i = floor(uv);
    vec2 f = fract(uv);

    vec2 c0 = i;
    vec2 c1 = i + vec2(1.0f, 0.0f);
    vec2 c2 = i + vec2(0.0f, 1.0f);
    vec2 c3 = i + vec2(1.0f, 1.0f);

    float r0 = dot(random_vector(c0, timeOffset), f);
    float r1 = dot(random_vector(c1, timeOffset), f - vec2(1.0f, 0.0f));
    float r2 = dot(random_vector(c2, timeOffset), f - vec2(0.0f, 1.0f));
    float r3 = dot(random_vector(c3, timeOffset), f - vec2(1.0f, 1.0f));

    f = f * f * (3.0 - 2.0 * f);

    float bottomOfGrid = mix(r0, r1, f.x);
    float topOfGrid = mix(r2, r3, f.x);
    float t = mix(bottomOfGrid, topOfGrid, f.y) * 0.5f + 0.5f;
    return t;
}

float perlin_noise(vec2 uv, float scale, float timeOffset)
{
    float t = 0.0f;
    vec2 scaledUV = uv * scale;

    float freq = 4.0f;
    float amp = 0.5f;
    t += perlin_noise_single_octave(vec2(scaledUV.x / freq, scaledUV.y / freq), timeOffset) * amp;

    freq = 2.0f;
    amp = 0.25f;
    t += perlin_noise_single_octave(vec2(scaledUV.x / freq, scaledUV.y / freq), timeOffset) * amp;

    freq = 1.0f;
    amp = 0.125f;
    t += perlin_noise_single_octave(vec2(scaledUV.x / freq, scaledUV.y / freq), timeOffset) * amp;

    return t;
}

float perlinNoise(vec2 uv, float scale, int octaves, float timeOffset)
{
    float t = 0.0;
    vec2 scaledUV = uv * scale;

    if (octaves < 1)
    {
        return t;
    }

    float freq = 4.0f;
    float amp = 0.5f;

    for (int i = 0; i < octaves; ++i)
    {
        t += perlin_noise_single_octave(vec2(scaledUV.x / freq, scaledUV.y / freq), timeOffset) * amp;

        freq *= 0.5f;
        amp *= 0.5f;
    }

    return t;
}

bool vector_equal_check(vec2 a, vec2 b)
{
	return (a.x > b.x - EPSILON && a.x < b.x + EPSILON && a.y > b.y - EPSILON && a.y < b.y + EPSILON);
}

// Based on code by Inigo Quilez: https://iquilezles.org/articles/voronoilines/
void voronoi_noise(vec2 uv, float cellDensity, out float distFromCenter, out float distFromEdge, float timeOffset)
{
    // Cell position variables.
    vec2 cell = floor(uv * cellDensity);
    vec2 posInCell = fract(uv * cellDensity);

    // Initialize output values.
    distFromCenter = 8.0f;
    distFromEdge = 8.0f;

    // Stuff to remember between passes.
    vec2 cellOffsets[9];
    vec2 closestOffset;

    // Precalculate random offsets pass.
    for(int y = 0; y <= 2; ++y)
    for(int x = 0; x <= 2; ++x)
    {
        vec2 cellToCheck = vec2(float(x - 1), float(y - 1));
        vec2 rand = random_vector(cell + cellToCheck, timeOffset) * 0.5f + 0.5f;
        cellOffsets[x + y * 3] = cellToCheck - posInCell + rand;
    }

    // Distance from closest cell center pass.
    for(int y = 0; y <= 2; ++y)
    for(int x = 0; x <= 2; ++x)
    {
        vec2 cellOffset = cellOffsets[x + y * 3];
        float distToPoint = dot(cellOffset, cellOffset);

        if(distToPoint < distFromCenter)
        {
            distFromCenter = distToPoint;
            closestOffset = cellOffset;
        }
    }

    // Distance from edge between two closest cell centers pass.
    for(int y = 0; y <= 2; ++y)
    for(int x = 0; x <= 2; ++x)
    {
        vec2 cellOffset = cellOffsets[x + y * 3];

		if(vector_equal_check(cellOffset, closestOffset))
		{
			continue;
		}

        float distFromCurrentEdge = dot(0.5f * (cellOffset + closestOffset), normalize(cellOffset - closestOffset));

        distFromEdge = min(distFromEdge, distFromCurrentEdge);
    }
}
