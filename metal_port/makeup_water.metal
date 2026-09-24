// MakeUp Ultra Fast - Native Metal Port (Water Utilities)
// Translated from GLSL by Prisma Team

#include <metal_stdlib>
using namespace metal;

// In MakeUp, they read from 'noisetex'. In Metal, we pass a noise texture and sampler.
// `WATER_TURBULENCE` in MakeUp is usually defined in config. Let's assume 1.5.

inline float3 getMakeUpWaterNormals(float3 pos, float time, float rainStrength, float visibleSky, texture2d<float> noisetex, sampler smp) {
    float speed = time * 0.05f; // Adjust based on frameTimeCounter
    
    // MakeUp reads RG from noisetex
    float2 uv1 = ((pos.xy - pos.z * 0.2f) * 0.05f) + float2(speed, speed);
    float2 wave_1 = noisetex.sample(smp, fract(uv1)).rg - 0.5f;
    
    float2 uv2 = ((pos.xy - pos.z * 0.2f) * 0.03125f) - speed;
    float2 wave_2 = noisetex.sample(smp, fract(uv2)).rg - 0.5f;
    
    float2 uv3 = ((pos.xy - pos.z * 0.2f) * 0.125f) + float2(speed, -speed);
    float2 wave_3 = (noisetex.sample(smp, fract(uv3)).rg - 0.5f) * 0.66f;
    
    float2 partialWave = wave_1 + wave_2 + wave_3;
    
    float turbulence = 1.5f; // WATER_TURBULENCE macro
    float zWave = turbulence - (rainStrength * 0.6f * turbulence * visibleSky);
    
    return normalize(float3(partialWave, zWave));
}
