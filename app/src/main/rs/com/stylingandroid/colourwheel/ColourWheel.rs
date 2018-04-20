#pragma version(1)
#pragma rs_fp_relaxed
#pragma rs java_package_name(com.stylingandroid.colourwheel)

#include "hsv.rsh"

const static uchar4 transparent = {0, 0, 0, 0};

float centreX;
float centreY;
float radius;
float brightness = 1.0f;

void colourWheel(rs_script script, rs_allocation allocation, float brightness_value) {
    centreX = rsAllocationGetDimX(allocation) / 2.0f;
    centreY = rsAllocationGetDimY(allocation) / 2.0f;
    radius = min(centreX, centreY);
    brightness = brightness_value;
    rsForEach(script, allocation, allocation);
}

void root(const uchar4 *v_in, uchar4 *v_out, const void *usrData, uint32_t x, uint32_t y) {
    float xOffset = x - centreX;
    float yOffset = y - centreY;
    float centreOffset = sqrt((xOffset * xOffset) + (yOffset * yOffset));
    float s = step(centreOffset, radius);

    float4 hsva = (float4) {
        atan2pi(yOffset, xOffset) * 0.5f + 1.0f,
        centreOffset / radius,
        s * brightness,
        s * 255.0f
    };

    *v_out = rsPackColorTo8888(hsva2Rgba_smooth(hsva));
}
