#include <metal_stdlib>
using namespace metal;

struct PostVertexOut {
    float4 position [[position]];
    float2 uv;
};

struct PostUniforms {
    float aspect;
    float time;
};

// MakeUp's Custom Sigmoid Tonemap
inline float3 makeupTonemap(float3 color) {
    color = 1.4f * color;
    float3 powerBase = pow(color, float3(2.5f)) + 1.0f;
    color = color / pow(powerBase, float3(0.4f));
    return pow(color, float3(1.15f));
}

fragment float4 prisma_postprocess_fs(
    PostVertexOut in [[stage_in]],
    texture2d<float> hdrTex [[texture(0)]],
    depth2d<float> depthTex [[texture(1)]],
    sampler smp [[sampler(0)]],
    constant PostUniforms& u [[buffer(0)]]
) {
    float4 hdrColor = hdrTex.sample(smp, in.uv);
    
    // Apply MakeUp Tonemapping
    float3 ldrColor = makeupTonemap(hdrColor.rgb);
    
    // Simple Vignette
    float2 d = in.uv - 0.5f;
    float dist = length(d);
    ldrColor *= smoothstep(0.8f, 0.3f, dist);

    return float4(ldrColor, 1.0f);
}
