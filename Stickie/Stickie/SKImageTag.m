//
//  SKImageTag.m
//  Stickie
//
//  Created by Grant Sheldon on 1/23/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKImageTag.h"


@implementation SKImageTag

/* MARKED FOR DEPRECATION. */
- (id) initWithName: (NSString *) name andColor: (UIColor *)color
{
    _tagName = name;
    _tagColor = color;
    _tagLocation = SKCornerLocationUndefined;
    return self;
}

- (id) initWithName: (NSString *) name location: (SKCornerLocation) location andColor: (UIColor *) color
{
    _tagName = name;
    _tagColor = color;
    _tagLocation = location;
    return self;
}

- (id) initWithCoder:(NSCoder *) decoder
{
    _tagName = [decoder decodeObjectForKey:@"tagName"];
    _tagColor = [decoder decodeObjectForKey:@"tagColor"];
    _tagLocation = [decoder decodeIntForKey:@"tagLocation"];
    return self;
}

- (void) encodeWithCoder: (NSCoder *) encoder
{
    [encoder encodeObject:_tagName forKey:@"tagName"];
    [encoder encodeObject:_tagColor forKey:@"tagColor"];
    [encoder encodeInt:_tagLocation forKey:@"tagLocation"];
}

- (BOOL) isEqualToTag:(SKImageTag *) tag
{
    /* Objective-C is weird with equality (i.e. [nil isEqual:nil] evaluates to NO) */
    if (([tag.tagName isEqualToString:_tagName] || (!tag.tagName && !_tagName)) &&
        ([tag.tagColor isEqual:_tagColor] || (!tag.tagColor && !_tagColor))) {
        if (tag.tagLocation == _tagLocation || tag.tagLocation == SKCornerLocationUndefined || _tagLocation == SKCornerLocationUndefined) {
            return YES;
        }
    }
    return NO;
}

/* Careful with this (especially for hashing). It checks for IDENTITY first */
- (BOOL) isEqual:(id) object
{
    if (object == self) {
        return YES;
    }
    if (!object || ![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self isEqualToTag:(SKImageTag *) object];
}

- (NSUInteger) hash
{
    return [self.tagName hash] ^ [self.tagColor hash] ^ [[NSNumber numberWithInt:self.tagLocation+1] hash];
}

- (id) copyWithZone: (NSZone *)zone
{
    SKImageTag *tag = [[[self class] allocWithZone:zone] init];
    
    if (tag) {
        tag.tagColor = _tagColor;
        tag.tagName = _tagName;
        tag.tagLocation = _tagLocation;
    }
    return tag;
}

@end
