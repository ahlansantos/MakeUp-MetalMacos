// MakeUp Ultra Fast - Native Metal Port (Core Utilities)
// Translated from GLSL by Prisma Team

#include <metal_stdlib>
using namespace metal;

// ---------------------------------------------------------
// BASIC UTILS (Ported from basic_utils.glsl)
// ---------------------------------------------------------

inline float squarePow(float x) { return x * x; }
inline float cubePow(float x) { return x * x * x; }
inline float fourthPow(float x) { float temp2 = x * x; return temp2 * temp2; }
inline float fifthPow(float x) { float temp2 = x * x; return temp2 * temp2 * x; }
inline float sixthPow(float x) { float temp2 = x * x; return temp2 * temp2 * temp2; }

inline float3 squarePow(float3 x) { return x * x; }
inline float3 cubePow(float3 x) { return x * x * x; }
inline float3 fourthPow(float3 x) { float3 temp2 = x * x; return temp2 * temp2; }
inline float3 fifthPow(float3 x) { float3 temp2 = x * x; return temp2 * temp2 * x; }
inline float3 sixthPow(float3 x) { float3 temp2 = x * x; return temp2 * temp2 * temp2; }

inline float4 squarePow(float4 x) { return x * x; }
inline float4 cubePow(float4 x) { return x * x * x; }
inline float4 fourthPow(float4 x) { return x * x * x * x; }
inline float4 fifthPow(float4 x) { float4 temp2 = x * x; return temp2 * temp2 * x; }
inline float4 sixthPow(float4 x) { float4 temp2 = x * x; return temp2 * temp2 * temp2; }

// ---------------------------------------------------------
// DAY BLEND (Ported from day_blend.glsl)
// ---------------------------------------------------------

// Note: In Metal, global uniforms like dayMixer, nightMixer, dayMoment 
// will be passed inside a Uniforms struct. For these utilities to work globally, 
// we will pass them explicitly as parameters.

inline float3 dayBlend(float3 sunset, float3 day, float3 night, float dayMixer, float nightMixer, float dayMoment) {
    float3 dayColor = mix(sunset, day, dayMixer);
    float3 nightColor = mix(sunset, night, nightMixer);
    return mix(dayColor, nightColor, step(0.5f, dayMoment));
}

inline float dayBlend(float sunset, float day, float night, float dayMixer, float nightMixer, float dayMoment) {
    float dayValue = mix(sunset, day, dayMixer);
    float nightValue = mix(sunset, night, nightMixer);
    return mix(dayValue, nightValue, step(0.5f, dayMoment));
}
