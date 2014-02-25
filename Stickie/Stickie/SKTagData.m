//
//  SKTagData.m
//  Stickie
//
//  Created by Grant Sheldon on 1/23/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKTagData.h"

/* Encapsulates the information about a given tag */

@implementation SKTagData

- (id) init
{
    self = [super init];
    if (self) {
        _tagFrequencyInPhotos = 0;
        _tagColor = [[UIColor alloc] init];
        _imageURLs = [[NSMutableArray alloc] init];
    }
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

@end
