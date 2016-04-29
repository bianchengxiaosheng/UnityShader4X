Shader "GWL/HalfLambertDiffuseGusee2" 
{
  Properties  
  {
    _EmissiveColor ("Emissive Color", Color) = (1,1,1,1)
    _AmbientColor  ("Ambient Color", Color) = (1,1,1,1)
    _MySliderValue ("This is a Slider", Range(0,128)) = 2.5

  }
  
  SubShader 
  {
    Tags { "RenderType"="Opaque" }
    LOD 200
    
  Pass {
    Name "FORWARD"
    Tags { "LightMode" = "ForwardBase" }

    CGPROGRAM
    #pragma vertex vert
    #pragma fragment frag
    #pragma multi_compile_fwdbase
    #include "UnityCG.cginc"
    #include "Lighting.cginc"
    #include "AutoLight.cginc"

    float4 _EmissiveColor;
    float4 _AmbientColor;
    float _MySliderValue;
    
    inline float4 LightingBasicDiffuse (float3 rgb,fixed3 normal, fixed3 lightDir, fixed atten)
    {
      float difLight = dot (normal, lightDir);
      float  hLambert = difLight * 0.5 + 0.5; 
      float4 col;
      col.rgb = rgb * _LightColor0.rgb * (hLambert * atten * 2);
      col.a = 1;
      return col;
    }
    struct Output{
      float4 pos:SV_POSITION;
      fixed3 worldN:TEXCOORD0;
      fixed3 vertexLight:TEXCOORD1;
      LIGHTING_COORDS(2,3)
    };
    struct Input{
      float4 vertex:POSITION;
      float3 normal:NORMAL;

    }; 
    Output vert(Input v) {
      Output o;
      o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
      o.worldN = mul((float3x3)_Object2World, SCALED_NORMAL);
      o.vertexLight = ShadeSH9 (float4(o.worldN,1.0));
      TRANSFER_VERTEX_TO_FRAGMENT(o);
      return o;
    }
    fixed4 frag (Output i) : COLOR {
      float4 powValue = pow((_EmissiveColor + _AmbientColor), _MySliderValue);
      fixed atten = LIGHT_ATTENUATION(i);
      fixed4 c = 0;
      c =  LightingBasicDiffuse(powValue.rgb,i.worldN,_WorldSpaceLightPos0.xyz,atten);
      c.rgb += powValue.rgb * i.vertexLight;
      return c;
    }

    ENDCG

}

  }
  
  //FallBack "Diffuse"
}
