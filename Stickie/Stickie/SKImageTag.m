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

- (id) initWithCoder:(NSCoder *) decoder
{
    return [decoder decodeObject];
}

- (void) encodeWithCoder: (NSCoder *) encoder
{
    [encoder encodeObject:self];
}

-(BOOL)isEqualToTag:(SKImageTag *) tag
{
    /* Objective-C is weird with equality (i.e. [nil isEqual:nil] evaluates to NO) */
    if ([tag.tagName isEqualToString:_tagName] || (!tag.tagName && !_tagName)) {
        if ([tag.tagColor isEqual:_tagColor] || (!tag.tagColor && !_tagColor)) {
            return YES;
        }
    }
    return NO;
}

/* Careful with this (especially for hashing). It checks for IDENTITY first */
-(BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    if (!object || ![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self isEqualToTag:(SKImageTag *) object];
}

-(NSUInteger)hash
{
    return [self.tagName hash] ^ [self.tagColor hash];
}

-(id)copyWithZone:(NSZone *)zone
{
    SKImageTag *tag = [[[self class] allocWithZone:zone] init];
    
    if (tag) {
        tag.tagColor = _tagColor;
        tag.tagName = _tagName;
    }
    return tag;
}

@end
