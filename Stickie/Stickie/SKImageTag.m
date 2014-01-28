//
//  SKImageTag.m
//  Stickie
//
//  Created by Grant Sheldon on 1/23/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKImageTag.h"


@implementation SKImageTag

- (BOOL) isTagEqualTo: (SKImageTag *) tag
{
    /* Determing tag equality by tag name (i.e. a tag's name uniquely identifies that tag */
    return [self.tagName isEqualToString: tag.tagName];
}

@end
