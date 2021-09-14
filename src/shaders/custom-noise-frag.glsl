#version 300 es

precision highp float;

int N_OCTAVES = 4;

uniform vec4 u_Color; // The color with which to render this instance of geometry.

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

float noise3d1(float x, float y, float z)
{
    float n = x + y * 61 + z * 23;
    n = (n << 13)^n;
    return (1.0 - ((n * (n * n * 68491 + 265313) + 7244183) & 7fffffff) / 1824921321.0);
}

float sampleNoise(float x, float y, float z)
{
    // can be expanded
    return nouseFun1(x, y, z);
}

float fbm(float x, float y, float z)
{
    float total = 0;
    float persistence = 1 / 2.0f;

    // loop over number of octaves
    for (int i = 0; i < N_OCTAVES)
    {
        float frequency = pow(2, i);
        float amplitude = pow(persistence, i);

        total += sampleNoise(x * frequency, y * frequency, z * frequency) * amplitude;
    }
    return total;
}

void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = u_Color;

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0, 1);

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        float noise = fbm(fs_Pos.xyz);
        // Compute final shaded color
        out_Col = vec4(diffuseColor.rgb * lightIntensity * noise, diffuseColor.a);
}
