//
//  GreenScreenFilterSettings.m
//  ImageMerge
//
//  Created by mpogra on 13/01/15.
//  Copyright (c) 2015 Aripra Infotech. All rights reserved.
//

#import "GreenScreenFilterSettings.h"

@implementation GreenScreenFilterSettings

+ (GreenScreenFilterSettings *) initWithSensitivity:(float)sensitivity highlight:(float)highlight shadow:(float)shadow spotColor:(NSColor *)spotColor{
    
    GreenScreenFilterSettings *settings = [[GreenScreenFilterSettings alloc] init];
    settings.highlight  = highlight;
    settings.shadow     = shadow;
    settings.sensitivity = sensitivity;
    settings.spotColor  = spotColor;
    return settings;
    
}
@end
