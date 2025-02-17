﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


// 纹理动画
Shader "Unity Shaders Book/Chapter 11/Image Sequence Animation"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Image Sequence", 2D) = "white" {}
        _HorizontalAmount ("Horizontal Amount", Float) = 4 // 水平方向 图像个数
        _VerticalAmount ("Vertical Amount", Float) = 4 // 重置方向 图象个数
        _Speed ("Speed", Range(1, 100)) = 30 // 速度
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"
        }

        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _HorizontalAmount;
            float _VerticalAmount;
            float _Speed;

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float time = floor(_Time.y * _Speed); // 得到模拟的时间 向下取整

                // 使用time除以_HorizontalAmount 的商作为行索引, 余数为列索引
                float row = floor(time / _HorizontalAmount); // 行索引  
                float column = time - row * _HorizontalAmount; // 列索引

                half2 uv = float2(i.uv.x /_HorizontalAmount, i.uv.y / _VerticalAmount);
                uv.x += column / _HorizontalAmount;
                uv.y -= row / _VerticalAmount;
                // half2 uv = i.uv + half2(column, -row); // 竖直方向使用 负数
                // uv.x /= _HorizontalAmount;
                // uv.y /= _VerticalAmount;

                fixed4 c = tex2D(_MainTex, uv);
                c.rgb *= _Color;

                return c;
            }
            ENDCG
        }
    }
    FallBack "Transparent/VertexLit"
}