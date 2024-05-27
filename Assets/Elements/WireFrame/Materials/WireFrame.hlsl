
void WireFramePosition_float(in float2 uv, in float3 camPos, in float3 position, in float3 normal, out float3 outPosition)
{
    float3 viewDir  = normalize(camPos - position);
    float3 otherDir = normal;
    float3 upDir    = normalize(cross(viewDir, otherDir));
    outPosition = position + _Radius * (upDir * uv.y) - _Radius * (otherDir * uv.x); 
}

void ComputeFog_float(in float distance, out float fogAmount)
{
    fogAmount = saturate(exp(-distance * _FogStrength));
}

void WireFrameAlpha_float(in float2 uv0, out float alpha)
{
    alpha = saturate(1.0 - length(uv0)) * _Alpha;
}

float3x3 CreateRotationMatrixZ(float angle)
{
    float c = cos(angle);
    float s = sin(angle);

    // Constructing the 3x3 rotation matrix
    float3x3 rotationMatrix = float3x3(
        c, -s, 0,
        s, c, 0,
        0, 0, 1
    );

    return rotationMatrix;
}

static const int occillatingFlag = 1;
static const int flashingFlag = 2;

void WireFrameRotate_float(in float3 position, in float3 direction, in float3 center, in float type, out float3 outPosition, out float3 outDirection)
{
    bool occillating = (((int)type | (int)_Type) & occillatingFlag) != 0;

    if (!occillating)
    {
        outPosition  = position;
        outDirection = direction;
        return;
    }

    float angle = sin(_Time.x * _WobbleSpeed) * _WobbleMaxAngle;
    float3x3 rotMat = CreateRotationMatrixZ(angle);
    outPosition  = mul(rotMat, position - center) + center;
    outDirection = mul(rotMat, direction);

}

void WireFrameColor_float(in float type, out float3 color)
{
    int mask = (int)type | (int)_Type;
    bool flashing = ((int)mask & flashingFlag) != 0;
    if (flashing)
    {
        color = lerp(_FlashingColor0.rgb, _FlashingColor1.rgb, sin(_Time * _FlashingSpeed) * 0.5 + 0.5);
    }
    else
    {
        color = _Color.rgb;
    }
}