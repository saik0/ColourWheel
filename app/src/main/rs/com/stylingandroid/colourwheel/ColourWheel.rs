#pragma version(1)
#pragma rs_fp_relaxed
#pragma rs java_package_name(com.stylingandroid.colourwheel)

#include "hsv.rsh"

const static uchar4 transparent = {0, 0, 0, 0};

float centreX;
float centreY;
float radius;
float radiusSq;
float brightness = 1.0f;

void colourWheel(rs_script script, rs_allocation allocation, float brightness_value) {
    centreX = rsAllocationGetDimX(allocation) / 2.0f;
    centreY = rsAllocationGetDimY(allocation) / 2.0f;
    radius = min(centreX, centreY);
    radiusSq = radius * radius;
    brightness = brightness_value;
    rsForEach(script, allocation, allocation);
}

void root(const uchar4 *v_in, uchar4 *v_out, const void *usrData, uint32_t x, uint32_t y) {
    uchar4 out;
    float xOffset = x - centreX;
    float yOffset = y - centreY;
    float centreOffsetSq = (xOffset * xOffset) + (yOffset * yOffset);
    if (centreOffsetSq <= radiusSq) {
        float centreAngle = fmod(degrees(atan2(yOffset, xOffset)) + 360.0f, 360.0f);
        float3 colourHsv;
        colourHsv.x = centreAngle;
        colourHsv.y = sqrt(centreOffsetSq) / radius;
        colourHsv.z = brightness;
        out = rsPackColorTo8888(hsv2Argb(colourHsv, 255.0f));
    } else {
        out = transparent;
    }
    *v_out = out;
}
