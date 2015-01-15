//
//  CIImageUtils.h
//  ImageMerge
//
//  Created by mpogra on 10/01/15.
//  Copyright (c) 2015 Aripra Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import "GreenScreenFilterSettings.h"


@interface CIImageGreenScreenFilters : NSObject
{
    CIFilter *colorCubeFilter;
    CIFilter *shadowHighlightFilter;
    CIFilter *sensitivityFilter;
    CIFilter *sourceOverFilter;
}
@property (strong) CIFilter *colorCubeFilter;
@property (strong) CIFilter *shadowHighlightFilter;
@property (strong) CIFilter *sensitivityFilter;
@property (strong) CIFilter *sourceOverFilter;
@property (nonatomic,strong) GreenScreenFilterSettings *settings;
/*
 Input image param is of type id to avoid reconversion of CIImage to NSImage or vice versa as we
 many time applies chain of filters and some time we are using standalone method so both are support
 and method will take care to convert into required needed type.
*/

- (CIImage *) removeBackgroundColorInImage:(id)inputImage colorToReplace:(NSColor *)colorToReplace;
- (CIImage *) adjustInImage:(id )inputImage highlight:(float) highlight shadow:(float) shadow sensitivity:(float) sensitivity;
- (CIImage *) mergeImages:(id) backgroundImage foregroundImage:(id)foregroundImage;

+ (CIImage *) nsimageToCIImage:(NSImage *)inputNSImage;
+ (NSImage *) ciImageToNSImage:(CIImage *)inputCIImage;

- (void) resetFilters;

@end
