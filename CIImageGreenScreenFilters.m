//
//  CIImageUtils.m
//  ImageMerge
//
//  Created by mpogra on 10/01/15.
//  Copyright (c) 2015 Aripra Infotech. All rights reserved.
//

#import "CIImageGreenScreenFilters.h"

@implementation CIImageGreenScreenFilters


@synthesize shadowHighlightFilter;
@synthesize sensitivityFilter;
@synthesize sourceOverFilter;
@synthesize colorCubeFilter;

- (id)init{
    self = [super init];
    
    colorCubeFilter         = [CIFilter filterWithName:@"CIColorCube"];
    [colorCubeFilter setDefaults];
    
    shadowHighlightFilter   = [CIFilter filterWithName:@"CIHighlightShadowAdjust"];
    [shadowHighlightFilter setDefaults];
    
    sensitivityFilter       = [CIFilter filterWithName:@"CIColorMatrix"];
    [sensitivityFilter setDefaults];
    
    sourceOverFilter        = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [sourceOverFilter setDefaults];
    return self;
}

- (void) resetFilters{
    
    [colorCubeFilter setDefaults];
    [shadowHighlightFilter setDefaults];
    [sensitivityFilter setDefaults];
    [sourceOverFilter setDefaults];
    
}
//right now only green color is rpelaced
- (CIImage *) removeBackgroundColorInImage:(id)inputImageAsid colorToReplace:(NSColor *)colorToReplace{
    CIImage *inputImage  = nil;
    
    if([inputImageAsid isKindOfClass:[NSImage class]])
        inputImage = [CIImageGreenScreenFilters nsimageToCIImage:inputImageAsid];
    else inputImage = inputImageAsid;

    float hue  = 0.45;//default max hue angle for green
    if(colorToReplace){
        NSColor *base = [ colorToReplace  colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
        hue = base.hueComponent;
    }
    //NSLog(@"%f %f %f and hue = %f",[base redComponent],[base greenComponent],[base blueComponent],hue);
    
    // Allocate memory
    const unsigned int size = 64;
    float *cubeData = (float *)malloc (size * size * size * sizeof (float) * 4);
    size_t cubeDataSize = size * size * size * sizeof ( float ) * 4;
    float rgb[3], hsv[3];
    float minHueAngle = 0.25;
    float maxHueAngle = hue;
    
    
    // Populate cube with a simple gradient going from 0 to 1
    size_t offset = 0;
    for (int z = 0; z < size; z++){
        rgb[2] = ((double)z)/(size); // Blue value
        for (int y = 0; y < size; y++){
            rgb[1] = ((double)y)/(size); // Green value
            for (int x = 0; x < size; x ++){
                rgb[0] = ((double)x)/(size); // Red value
                // Convert RGB to HSV
                rgbToHSV(rgb, hsv);
                // Use the hue value to determine which to make transparent
                // The minimum and maximum hue angle depends on
                // the color we want to remove
                float alpha = 0.0;
                if((hsv[0] > minHueAngle && hsv[0] < maxHueAngle)){
                    if(!self.settings) alpha = 0.0;
                    else alpha = 1-self.settings.sensitivity;//on UI slider indicates less meaning more green to remove
                    
                }else  alpha =  1.0f;
               
                // Calculate premultiplied alpha values for the cube
                cubeData[offset]   = rgb[0] *alpha;
                cubeData[offset+1] = rgb[1] *alpha;
                cubeData[offset+2] = rgb[2] *alpha;
                cubeData[offset+3] = alpha;
                offset += 4; // advance our pointer into memory for the next color value
            }
        }
    }
    
    // Create memory with the cube data
    NSData *data = [NSData dataWithBytesNoCopy:cubeData length:cubeDataSize  freeWhenDone:YES];
    [colorCubeFilter setValue:[NSNumber numberWithInt:size] forKey:@"inputCubeDimension"];
    // Set data for cube
    [colorCubeFilter setValue:data forKey:@"inputCubeData"];
    [colorCubeFilter setValue:inputImage forKey:kCIInputImageKey];
    CIImage *result = [colorCubeFilter valueForKey:kCIOutputImageKey];
    
    return result;
}


- (CIImage *) adjustInImage:(id)inputImageAsid highlight:(float) highlight shadow:(float) shadow sensitivity:(float) sensitivity{
    
    CIImage *inputImage  = nil;
    
    if([inputImageAsid isKindOfClass:[NSImage class]])
        inputImage = [CIImageGreenScreenFilters nsimageToCIImage:inputImageAsid];
    else inputImage = inputImageAsid;
    
    [shadowHighlightFilter setValue:inputImage forKey:kCIInputImageKey];
    [shadowHighlightFilter setValue:[NSNumber numberWithDouble:shadow] forKey:@"inputShadowAmount"];
    [shadowHighlightFilter setValue:[NSNumber numberWithDouble:highlight] forKey:@"inputHighlightAmount"];
    CIImage *outputImage = [shadowHighlightFilter valueForKey: kCIOutputImageKey];
    
    
    CIVector *alphaVector = [CIVector vectorWithX:0 Y:0 Z:0 W:sensitivity];
    [sensitivityFilter setValue:outputImage forKey:kCIInputImageKey];
    [sensitivityFilter setValue:alphaVector forKey:@"inputAVector"];
   // outputImage = [sensitivityFilter valueForKey: kCIOutputImageKey];

    
    return outputImage;
}


- (CIImage *) mergeImages:(id) bkImage foregroundImage:(id)fgImage{
    
    CIImage *backgroundImage = nil, *foregroundImage = nil;
    if([bkImage isKindOfClass:[NSImage class]])
        backgroundImage = [CIImageGreenScreenFilters nsimageToCIImage:bkImage];
    else backgroundImage = bkImage;
    
    if([fgImage isKindOfClass:[NSImage class]])
        foregroundImage = [CIImageGreenScreenFilters nsimageToCIImage:fgImage];
    else foregroundImage = fgImage;
    
    [sourceOverFilter setValue:foregroundImage forKey:kCIInputImageKey];
    [sourceOverFilter setValue:backgroundImage forKey:kCIInputBackgroundImageKey];
    CIImage *result      =    sourceOverFilter.outputImage;
    
    return result;
}


+ (CIImage *)nsimageToCIImage:(NSImage *)inputNSImage {
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)[inputNSImage TIFFRepresentation], NULL);
    CGImageRef maskRef              = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    return [CIImage imageWithCGImage:maskRef];

}

+ (NSImage *)ciImageToNSImage:(CIImage *)inputCIImage {
    
    NSCIImageRep *rep = [NSCIImageRep imageRepWithCIImage:inputCIImage];
    NSImage *nsImage = [[NSImage alloc] initWithSize:rep.size];
    [nsImage addRepresentation:rep];
    return nsImage;
}

void rgbToHSV(float rgb[3], float hsv[3])
{
    float min, max, delta;
    float r = rgb[0], g = rgb[1], b = rgb[2];
    //float *h = hsv[0], *s = hsv[1], *v = hsv[2];
    
    min = MIN( r, MIN( g, b ));
    max = MAX( r, MAX( g, b ));
    hsv[2] = max;               // v
    delta = max - min;
    if( max != 0 )
        hsv[1] = delta / max;       // s
    else {
        // r = g = b = 0        // s = 0, v is undefined
        hsv[1] = 0;
        hsv[0] = -1;
        return;
    }
    if( r == max )
        hsv[0] = ( g - b ) / delta;     // between yellow & magenta
    else if( g == max )
        hsv[0] = 2 + ( b - r ) / delta; // between cyan & yellow
    else
        hsv[0] = 4 + ( r - g ) / delta; // between magenta & cyan
    hsv[0] *= 60;               // degrees
    if( hsv[0] < 0 )
        hsv[0] += 360;
    hsv[0] /= 360.0;
}

void hsvToRGB(float hsv[3], float rgb[3])
{
    float C = hsv[2] * hsv[1];
    float HS = hsv[0] * 6.0;
    float X = C * (1.0 - fabsf(fmodf(HS, 2.0) - 1.0));
    
    if (HS >= 0 && HS < 1)
    {
        rgb[0] = C;
        rgb[1] = X;
        rgb[2] = 0;
    }
    else if (HS >= 1 && HS < 2)
    {
        rgb[0] = X;
        rgb[1] = C;
        rgb[2] = 0;
    }
    else if (HS >= 2 && HS < 3)
    {
        rgb[0] = 0;
        rgb[1] = C;
        rgb[2] = X;
    }
    else if (HS >= 3 && HS < 4)
    {
        rgb[0] = 0;
        rgb[1] = X;
        rgb[2] = C;
    }
    else if (HS >= 4 && HS < 5)
    {
        rgb[0] = X;
        rgb[1] = 0;
        rgb[2] = C;
    }
    else if (HS >= 5 && HS < 6)
    {
        rgb[0] = C;
        rgb[1] = 0;
        rgb[2] = X;
    }
    else {
        rgb[0] = 0.0;
        rgb[1] = 0.0;
        rgb[2] = 0.0;
    }
    
    
    float m = hsv[2] - C;
    rgb[0] += m;
    rgb[1] += m;
    rgb[2] += m;
}
@end
