// MakeUp Ultra Fast - Native Metal Port (Color Utilities)
// Translated from GLSL by Prisma Team

#include <metal_stdlib>
using namespace metal;

// In Metal, macros for schemes could be controlled via compile-time constants (function constants)
// For now, we will assume COLOR_SCHEME == 0 (Ethereal)

#define OMNI_TINT 0.4f
#define LIGHT_SUNSET_COLOR float3(0.887528f, 0.443394f, 0.301044f)
#define LIGHT_DAY_COLOR float3(0.90f, 0.84f, 0.79f)

#define ZENITH_SUNSET_COLOR float3(0.2617647f, 0.33529412f, 0.52352941f)
#define ZENITH_DAY_COLOR float3(0.0785098f, 0.24352941f, 0.54901961f)

#define HORIZON_SUNSET_COLOR float3(1.0f, 0.6f, 0.394f)
#define HORIZON_DAY_COLOR float3(0.65f, 0.91f, 1.3f)

#define WATER_COLOR float3(0.05f, 0.1f, 0.11f)

// Ethereal Night Light Calculation (Depends on Moon Phase, passed dynamically)
inline float3 getLightNightColor(float moonPhaseFactor) {
    float nightBrightPhase = 0.8f + (0.8f * (abs(4.0f - moonPhaseFactor) * 0.25f));
    return float3(0.0317353f, 0.0467353f, 0.0637353f) * nightBrightPhase;
}

inline float3 getZenithNightColor(float moonPhaseFactor) {
    float nightBrightPhase = 0.8f + (0.8f * (abs(4.0f - moonPhaseFactor) * 0.25f));
    return float3(0.0168f, 0.0228f, 0.03f) * nightBrightPhase;
}

inline float3 getHorizonNightColor(float moonPhaseFactor) {
    float nightBrightPhase = 0.8f + (0.8f * (abs(4.0f - moonPhaseFactor) * 0.25f));
    return float3(0.02556f, 0.03772f, 0.05244f) * nightBrightPhase;
}

