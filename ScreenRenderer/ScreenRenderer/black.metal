//
//  black.metal
//  ScreenCaptureApp
//
//  Created by Shanmuganathan on 29/06/21.
//

#include <metal_stdlib>
using namespace metal;

kernel void transparent (
texture2d<float, access::write> outTexture [[texture(0)]],
texture2d<float, access::read> inTexture [[texture(1)]],
uint2 id [[thread_position_in_grid]]) {
float3 val = inTexture.read(id).rgb;
float4 out = float4(val.r, val.g, val.b, 1.0);
outTexture.write(out.rgba, id);
}
