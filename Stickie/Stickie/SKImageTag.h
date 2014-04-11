//
//  SKImageTag.h
//  Stickie
//
//  Created by Grant Sheldon on 1/23/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKImageTag : NSObject <NSCopying, NSCoding>

/* Useful for characterizing location of tags, corner buttons. */
typedef enum {
    SKCornerLocationUndefined,
    SKCornerLocationTopLeft,
    SKCornerLocationTopRight,
    SKCornerLocationBottomLeft,
    SKCornerLocationBottomRight,
} SKCornerLocation;

@property (nonatomic) NSString *tagName;
@property (nonatomic) UIColor *tagColor;
@property (nonatomic) SKCornerLocation tagLocation;

/* DEPRECATED. */
- (id) initWithName: (NSString *) name andColor: (UIColor *) color __attribute__((deprecated));

- (id) initWithName: (NSString *) name location: (SKCornerLocation) location andColor: (UIColor *) color;
- (BOOL) isEqualToTag:(SKImageTag *) tag;

@end
