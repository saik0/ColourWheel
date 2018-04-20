#ifndef __RS_HSL_RSH__
#define __RS_HSL_RSH__

/*
 * This function was adapted from those at
 * http://dystopiancode.blogspot.co.uk/2012/06/hsv-rgb-conversion-algorithms-in-c.html
 *
 */

static float4 hsv2Argb(float3 hsv, float alpha) {
    float c = hsv[2] * hsv[1];
    float x = c * (1.0f - fabs(fmod(hsv[0] / 60.0f, 2) - 1.0f));
    float m = hsv[2] - hsv[1];
    int32_t s = (int32_t)(fabs(hsv[0] / 60.0f));

   	float4 argb;

    switch(s) {
        case 0:
            argb.r = c + m;
            argb.g = x + m;
            argb.b = m;
            break;
        case 1:
            argb.r = x + m;
            argb.g = c + m;
            argb.b = m;
            break;
        case 2:
            argb.r = m;
            argb.g = c + m;
            argb.b = x + m;
            break;
        case 3:
            argb.r = m;
            argb.g = x + m;
            argb.b = c + m;
            break;
        case 4:
            argb.r = x + m;
            argb.g = m;
            argb.b = c + m;
            break;
        case 5:
            argb.r = c + m;
            argb.g = m;
            argb.b = x + m;
            break;
        default:
            argb.r = m;
            argb.g = m;
            argb.b = m;
   	}
    argb.a = alpha;
    return argb;
}

#endif // #ifndef __RS_HSL_RSH__
