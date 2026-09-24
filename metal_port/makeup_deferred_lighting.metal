// MakeUp Ultra Fast - Native Metal Port (Lighting & Shadows)
// Translated from GLSL by Prisma Team
// Designed for Prisma Shader Loader - Option B (VXR Integration)

#include <metal_stdlib>
using namespace metal;

// Imagine these are defined elsewhere from Prisma API
struct VoxelGridManager { /* ... */ };
inline float traceVoxelShadow(VoxelGridManager voxelManager, float3 worldPos, float3 lightDir) { return 1.0f; } // Stub

// ---------------------------------------------------------
// MAKEUP DIRECTIONAL LIGHTING WITH PRISMA VOXELS
// ---------------------------------------------------------

inline float3 calculateMakeUpLighting(
    float3 albedo, 
    float3 normal, 
    float3 worldPos, 
    float3 lightDir, 
    float3 skyLightColor, 
    float3 sunLightColor, 
    float3 ambientColor,
    VoxelGridManager voxelManager
) {
    // 1. N dot L (Lambertian)
    float nDotL = max(dot(normal, lightDir), 0.0f);
    
    // 2. MakeUp Shadow softening trick (Translucency/Wrap)
    float wrapLight = max(dot(normal, lightDir) * 0.5f + 0.5f, 0.0f);
    
    // 3. PRISMA NATIVE VOXEL SHADOW (Replacing OptiFine Shadow Maps!)
    // We trace a ray through the Voxel Grid towards the sun.
    // 1.0 = Fully Lit, 0.0 = In Shadow
    float voxelShadow = traceVoxelShadow(voxelManager, worldPos, lightDir);
    
    // MakeUp uses a specific shadow mixing technique where ambient light is 
    // heavily tinted by the sky color when in shadow.
    
    // Direct Sun Contribution (only if not in shadow)
    float3 directDiffuse = sunLightColor * nDotL * voxelShadow;
    
    // Ambient / Sky Contribution (MakeUp uses a lot of wrap light for ambient)
    float3 ambientDiffuse = ambientColor + (skyLightColor * wrapLight * 0.3f);
    
    // Combine
    float3 finalLighting = directDiffuse + ambientDiffuse;
    
    return albedo * finalLighting;
}

// ---------------------------------------------------------
// MAKEUP PBR & WETNESS (Entities & Terrain)
// ---------------------------------------------------------

inline float3 applyMakeUpWetness(float3 color, float3 normal, float rainStrength, float skyVisibility, float3 viewDir) {
    if (rainStrength <= 0.01f || skyVisibility <= 0.01f) return color;
    
    // MakeUp makes upward facing surfaces darker and more reflective during rain
    float upFactor = max(dot(normal, float3(0.0f, 1.0f, 0.0f)), 0.0f);
    float wetness = rainStrength * skyVisibility * upFactor;
    
    // Darken albedo slightly when wet
    color *= mix(1.0f, 0.7f, wetness);
    
    // Fresnel for wet reflections (simplified MakeUp logic)
    float f0 = 0.02f;
    float nDotV = max(dot(normal, viewDir), 0.0f);
    float fresnel = f0 + (1.0f - f0) * pow(1.0f - nDotV, 5.0f);
    
    // Add specular highlight from sky/clouds
    float3 wetHighlight = float3(0.8f, 0.8f, 0.9f) * fresnel * wetness;
    color += wetHighlight;
    
    return color;
}
