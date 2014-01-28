//
//  SKTagCollection.m
//  Stickie
//
//  Created by Grant Sheldon on 1/23/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKTagCollection.h"

@implementation SKTagCollection

/* Implementing class as a singleton */

+ (SKTagCollection *) sharedInstance
{
    static dispatch_once_t once;
    static SKTagCollection *instance;
    
    dispatch_once(&once, ^{
        instance = [[SKTagCollection alloc] init];
    });
    
    return instance;
}

- (SKTagData *) getTagInfo: (SKImageTag *) tag
{
    return (SKTagData *) [_tagDataMap objectForKey: tag];
}

- (void) addTagToCollection: (SKImageTag<NSCopying> *) tag
{
    if (![_allUserTags containsObject: tag]) {
        [_allUserTags addObject: tag];
        [_tagDataMap setObject: [SKTagData init] forKey: tag];
    }
}

- (BOOL) isTagInCollection: (SKImageTag *) tag
{
    return [_allUserTags containsObject: tag];
}

- (void) changeTag: (SKImageTag<NSCopying> *) tag toFreqOneHigherOrLower: (SKHigherOrLower) choice
{
    if (![_allUserTags containsObject: tag]) {
        @throw [NSException exceptionWithName: @"TagNotFoundException" reason: @"The specified tag was not found." userInfo:nil];
    }
    
    SKTagData *data = [_tagDataMap objectForKey: tag];
    
    switch (choice) {
        case HIGHER:
            data.tagFrequencyInPhotos++;
            [_tagDataMap setObject: data forKey: tag];
            break;
        case LOWER:
            if (data.tagFrequencyInPhotos > 0) {
                data.tagFrequencyInPhotos--;
                [_tagDataMap setObject: data forKey: tag];
            }
            break;
    }
}

- (void) changeTag: (SKImageTag<NSCopying> *) tag toColor: (UIColor *) color
{
    if (![_allUserTags containsObject: tag]) {
        @throw [NSException exceptionWithName: @"TagNotFoundException" reason: @"The specified tag was not found." userInfo:nil];
    }
    
    SKTagData *data = [_tagDataMap objectForKey: tag];
    data.tagColor = color;
    [_tagDataMap setObject: data forKey: tag];
}

@end
