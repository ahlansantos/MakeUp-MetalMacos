// MakeUp Ultra Fast - Native Metal Port (Volumetric Clouds)
// Translated from GLSL by Prisma Team

#include <metal_stdlib>
using namespace metal;

// MakeUp Cloud Macros
#define CLOUD_PLANE 256.0f
#define CLOUD_PLANE_SUP 300.0f
#define CLOUD_PLANE_CENTER 278.0f

inline float getCloudNoise(float3 pos, texture2d<float> noisetex, sampler smp, float frameTimeCounter) {
    // In MakeUp, they usually sample a noise texture in 2D or 3D. 
    // We'll mock the internal noise function structure.
    float2 uv = pos.xz * 0.001f + float2(frameTimeCounter * 0.01f);
    float noise1 = noisetex.sample(smp, fract(uv)).r;
    float noise2 = noisetex.sample(smp, fract(uv * 2.0f + float2(frameTimeCounter * 0.02f))).r;
    
    return saturate(noise1 - noise2 * 0.5f);
}

// Ported MakeUp Volumetric Cloud Raymarcher
inline float3 getMakeUpClouds(float3 eyeDirection, float3 skyColor, float dither, float3 basePos, 
                              float3 cloudColor, float3 darkCloudColor, 
                              texture2d<float> noisetex, sampler smp, float time) {
    if (eyeDirection.y <= 0.01f) {
        return skyColor; // Below horizon
    }

    float view_y_inv = 1.0f / eyeDirection.y;

    float plane_dist_inf = (CLOUD_PLANE - basePos.y) * view_y_inv;
    float3 intersection_pos = (eyeDirection * plane_dist_inf) + basePos;

    float plane_dist_sup = (CLOUD_PLANE_SUP - basePos.y) * view_y_inv;
    float3 intersection_pos_sup = (eyeDirection * plane_dist_sup) + basePos;

    int samples = 12; // Typical for Ultra Fast
    float3 increment = (intersection_pos_sup - intersection_pos) / float(samples);
    float increment_dist = length(increment);

    float cloud_value = 0.0f;
    float density = 0.0f;
    float transmittance = 1.0f;
    float3 finalCloudColor = float3(0.0f);
    
    // Apply dither offset
    float3 currentPos = intersection_pos + increment * dither;

    for (int i = 0; i < samples; i++) {
        if (transmittance < 0.01f) break;

        float noiseVal = getCloudNoise(currentPos, noisetex, smp, time);
        
        // Shape based on height
        float heightGradient = 1.0f - abs(currentPos.y - CLOUD_PLANE_CENTER) / (CLOUD_PLANE_SUP - CLOUD_PLANE_CENTER);
        noiseVal *= saturate(heightGradient * 2.0f);

        if (noiseVal > 0.1f) { // threshold
            density = (noiseVal - 0.1f) * 0.5f;
            float stepAlpha = 1.0f - exp(-density * increment_dist * 0.1f);
            
            // Simple lighting: lower clouds are darker
            float3 localColor = mix(darkCloudColor, cloudColor, heightGradient);
            
            finalCloudColor += localColor * stepAlpha * transmittance;
            transmittance *= (1.0f - stepAlpha);
        }
        currentPos += increment;
    }

    return mix(finalCloudColor, skyColor, transmittance);
}
