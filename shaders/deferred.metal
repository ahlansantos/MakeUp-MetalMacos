#include <metal_stdlib>
using namespace metal;

struct DeferredVertexOut {
    float4 position [[position]];
    float2 uv;
};

struct DeferredUniforms {
    float aspect; float fovScale; float sunAngle; float cameraPitch; float cameraYaw;
    float sunShadowsEnabled; float gameTime; float waterWaveStrength; float waterWaveSpeed;
    float waterAbsorption; float skyR; float skyG; float skyB; float sunriseAlpha;
    float sunriseR; float sunriseG; float sunriseB; float starBrightness; float maxPointLights;
    float reflectionPtShadows; float reflectionDirShadows; float vxaoInReflections; float cloudsEnabled;
};

// ---------------------------------------------------------
// MAKEUP LIGHTING INTEGRATION
// ---------------------------------------------------------
// For simplicity in this Proof of Concept, we define a basic MakeUp Light formula here.
// In a full implementation, this would #include the metal_port headers.

inline float3 calculateMakeUpLighting(float3 albedo, float3 normal, float3 lightDir, float3 skyColor, float3 sunColor) {
    float nDotL = max(dot(normal, lightDir), 0.0f);
    float wrapLight = max(dot(normal, lightDir) * 0.5f + 0.5f, 0.0f);
    float3 directDiffuse = sunColor * nDotL; // Assume unshadowed for PoC
    float3 ambientDiffuse = float3(0.05f) + (skyColor * wrapLight * 0.3f);
    return albedo * (directDiffuse + ambientDiffuse);
}

fragment float4 prisma_deferred_fs(
    DeferredVertexOut in [[stage_in]],
    texture2d<float> albedoTex [[texture(0)]],
    texture2d<float> normalTex [[texture(1)]],
    texture2d<float> lightDataTex [[texture(2)]],
    depth2d<float> worldDepthTex [[texture(3)]],
    depth2d<float> handDepthTex [[texture(4)]],
    texture2d<float> blockAtlasTex [[texture(5)]],
    texture2d<float> playerSkinTex [[texture(6)]],
    sampler smp [[sampler(0)]],
    constant DeferredUniforms& u [[buffer(0)]],
    device const uint2* voxelGrid [[buffer(1)]],
    constant VoxelUniforms& uVoxel [[buffer(2)]],
    constant float4* blockUvTable [[buffer(3)]],
    constant ulong* bitmaskTable [[buffer(4)]]
) {
    float4 albedo = albedoTex.sample(smp, in.uv);
    if (albedo.a < 0.1f) discard_fragment();

    float4 normalData = normalTex.sample(smp, in.uv);
    float3 normal = normalData.xyz * 2.0f - 1.0f;
    float4 lightData = lightDataTex.sample(smp, in.uv);

    // MakeUp Light direction (Sun/Moon)
    float sunRad = u.sunAngle;
    float3 lightDir = normalize(float3(sin(sunRad), cos(sunRad), 0.5f));

    // MakeUp Colors
    float3 skyColor = float3(u.skyR, u.skyG, u.skyB);
    float3 sunColor = float3(1.0f, 0.9f, 0.8f);

    float3 finalColor = calculateMakeUpLighting(albedo.rgb, normal, lightDir, skyColor, sunColor);

    // Add Block Light (Torch)
    float blockLight = lightData.y;
    finalColor += albedo.rgb * float3(1.0f, 0.6f, 0.3f) * blockLight * blockLight * 2.0f;

    return float4(finalColor, 1.0f);
}
