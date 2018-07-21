//@author: vux
//@help: template for standard shaders
//@tags: template
//@credits: 

Texture2D texture2d <string uiname="Texture";>;

SamplerState linearSampler : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};
 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : LAYERVIEWPROJECTION;	
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
};

struct VS_IN
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;

};

struct vs2ps
{
    float4 Pos: SV_Position;
    float4 TexCd: TEXCOORD0;
	float4 Color: Color0;
};

vs2ps VS(VS_IN input)
{
    vs2ps output;
    output.Pos  = input.PosO;//mul(input.PosO,mul(tW,tVP));
    output.TexCd = input.TexCd;
	output.Color = 0;
    return output;
}

StructuredBuffer<float4x4> sbRotation;
float Explode;

[maxvertexcount(3)]
void GS( triangle vs2ps input[3], inout TriangleStream<vs2ps> TriStream , uint pid : SV_PrimitiveID){
	//
    // Calculate the face normal
    //
    float3 faceEdgeA = input[1].Pos.xyz - input[0].Pos.xyz;
    float3 faceEdgeB = input[2].Pos.xyz - input[0].Pos.xyz;
    float3 faceNormal = normalize( cross(faceEdgeA, faceEdgeB) );
	
	vs2ps output;
	
	for( int v=0; v<3; v++ )
    {
        output.Pos = mul(input[v].Pos, sbRotation[pid]) + float4(faceNormal*Explode,0);
        output.Pos = mul( output.Pos, tVP);
        
        //output.Norm = input[v].Norm;
        
        output.TexCd = input[v].TexCd;
        output.Color = 1;
        TriStream.Append( output );
    }
	TriStream.RestartStrip();
}


float4 PS(vs2ps In): SV_Target
{
    float4 col = texture2d.Sample(linearSampler,In.TexCd.xy) * cAmb;
    return In.Color;//col;
}

technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetGeometryShader( CompileShader( gs_4_0, GS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}




