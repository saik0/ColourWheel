/*
 * The MIT License
 * Copyright © 2014 Inigo Quilez
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in the
 * Software without restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
 * Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions: The above copyright notice and this
 * permission notice shall be included in all copies or substantial portions of the
 * Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * Converting from HSV to RGB leads to C1 discontinuities, for the RGB components
 * are driven by picewise linear segments. Using a cubic smoother (smoothstep) makes
 * the color transitions in RGB C1 continuous when linearly interpolating the hue H.
 *
 * C2 continuity can be achieved as well by replacing smoothstep with a quintic
 * polynomial. Of course all these cubic, quintic and trigonometric variations break
 * the standard (http: *en.wikipedia.org/wiki/HSL_and_HSV), but they look better.
 */

/*
 * Source: https://www.shadertoy.com/view/MsS3Wc
 * Discussion: https://twitter.com/iquilezles/status/442154332914323457
 */
#ifndef __RS_HSL_RSH__
#define __RS_HSL_RSH__



const float3 M = (float3) { 0.0f, 4.0f, 2.0f };
const float3 UNIT3 = (float3) { 1.0f, 1.0f, 1.0f };

// Official HSV to RGB conversion
static float4 hsv2rgb(float4 c) {
    float3 rgb = clamp(fabs(fmod(c.x * 6.0f + M, 6.0f) -3.0f) - 1.0f, 0.0f, 1.0f);
	rgb = c.z * mix( UNIT3, rgb, c.y);
	return (float4) { rgb.x, rgb.y, rgb.z, c.w };
}

// Smooth HSV to RGB conversion
static float4 hsva2Rgba_smooth(float4 c) {
    float3 rgb = clamp(fabs(fmod(c.x * 6.0f + M, 6.0f) -3.0f) - 1.0f, 0.0f, 1.0f);
    rgb = rgb*rgb*(3.0f - 2.0f *rgb); // cubic smoothing
    rgb = c.z * mix(UNIT3, rgb, c.y);
    return (float4) { rgb.x, rgb.y, rgb.z, c.w };
}

#endif // #ifndef __RS_HSL_RSH__
