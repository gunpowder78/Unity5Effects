﻿Shader "GBufferUtils/GBufferCopy" {
CGINCLUDE
sampler2D _CameraGBufferTexture0;   // diffuse color (rgb), occlusion (a)
sampler2D _CameraGBufferTexture1;   // spec color (rgb), smoothness (a)
sampler2D _CameraGBufferTexture2;   // normal (rgb), --unused, very low precision-- (a) 
sampler2D _CameraGBufferTexture3;   // emission (rgb), --unused-- (a)
sampler2D_float _CameraDepthTexture;

struct ia_out
{
    float4 vertex : POSITION;
};

struct vs_out
{
    float4 vertex : SV_POSITION;
    float4 screen_pos : TEXCOORD0;
};

struct ps_out_gbuffer
{
    half4 diffuse           : SV_Target0; // RT0: diffuse color (rgb), occlusion (a)
    half4 spec_smoothness   : SV_Target1; // RT1: spec color (rgb), smoothness (a)
    half4 normal            : SV_Target2; // RT2: normal (rgb), --unused, very low precision-- (a) 
    half4 emission          : SV_Target3; // RT3: emission (rgb), --unused-- (a)
};
struct ps_out_depth
{
    float depth             : SV_Target0;
};


vs_out vert(ia_out v)
{
    vs_out o;
    o.vertex = v.vertex;
    o.screen_pos = v.vertex;
    o.screen_pos.y *= _ProjectionParams.x;
    return o;
}

ps_out_gbuffer frag_gbuffer(vs_out v)
{
    float2 tc = v.screen_pos * 0.5 + 0.5;

    ps_out_gbuffer o;
    o.diffuse           = tex2D(_CameraGBufferTexture0, tc);
    o.spec_smoothness   = tex2D(_CameraGBufferTexture1, tc);
    o.normal            = tex2D(_CameraGBufferTexture2, tc);
    o.emission          = tex2D(_CameraGBufferTexture3, tc);
    return o;
}

ps_out_depth frag_depth(vs_out v)
{
    float2 tc = v.screen_pos * 0.5 + 0.5;

    ps_out_depth o;
    o.depth = tex2D(_CameraDepthTexture, tc).x;
    return o;
}
ENDCG


SubShader {
    Tags { "RenderType"="Opaque" }
    Blend Off
    ZTest Always
    ZWrite Off
    Cull Off

    Pass {
CGPROGRAM
#pragma vertex vert
#pragma fragment frag_gbuffer
ENDCG
    }

    Pass {
CGPROGRAM
#pragma vertex vert
#pragma fragment frag_depth
ENDCG
    }
}
Fallback Off
}