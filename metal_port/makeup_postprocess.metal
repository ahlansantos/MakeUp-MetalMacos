// MakeUp Ultra Fast - Native Metal Port (Post-Processing)
// Translated from GLSL by Prisma Team

#include <metal_stdlib>
using namespace metal;

// ---------------------------------------------------------
// TONE MAPPING (Ported from tone_maps.glsl)
// ---------------------------------------------------------

// MakeUp's Custom Sigmoid Tonemap
// Very lightweight and fast compared to ACES
inline float3 makeupTonemap(float3 color) {
    color = 1.4f * color;
    float3 powerBase = pow(color, float3(2.5f)) + 1.0f;
    color = color / pow(powerBase, float3(0.4f));
    return pow(color, float3(1.15f));
}

// ---------------------------------------------------------
// POST-PROCESSING PIPELINE (The final pass equivalent)
// ---------------------------------------------------------

// In Prisma, this would be called in the postprocess_fs function
inline float3 applyMakeUpPostProcessing(float3 color, float3 bloomColor, float bloomStrength) {
    // 1. Add Bloom
    color += bloomColor * bloomStrength;
    
    // 2. Tonemap
    color = makeupTonemap(color);
    
    // 3. Gamma Correction (MakeUp usually relies on OpenGL sRGB, but if explicit:)
    // color = pow(max(color, float3(0.0f)), float3(1.0f / 2.2f));
    
    return color;
}
