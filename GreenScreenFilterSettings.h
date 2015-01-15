//
//  GreenScreenFilterSettings.h
//  ImageMerge
//
//  Created by mpogra on 13/01/15.
//  Copyright (c) 2015 Aripra Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface GreenScreenFilterSettings : NSObject
{
    
}
@property (nonatomic, retain) NSColor *spotColor;
@property (nonatomic) float sensitivity;
@property (nonatomic) float highlight;
@property (nonatomic) float shadow;

+ (GreenScreenFilterSettings *) initWithSensitivity:(float)sensitivity highlight:(float)highlight shadow:(float)shadow spotColor:(NSColor *)spotColor;
@end
