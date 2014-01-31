//
//  SKImageTag.m
//  Stickie
//
//  Created by Grant Sheldon on 1/23/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKImageTag.h"


@implementation SKImageTag

-(id)initWithName: (NSString *) name andColor: (UIColor *)color
{
    _tagName = name;
    _tagColor = color;
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    SKImageTag *tag = [[[self class] allocWithZone:zone] init];
    
    if (tag) {
        tag->_tagColor = _tagColor;
        tag->_tagName = _tagName;
    }
    return tag;
}

@end
