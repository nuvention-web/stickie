//
//  SKTagCollection.m
//  Stickie
//
//  Created by Grant Sheldon on 1/23/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKTagCollection.h"

@interface SKTagCollection () {
    
    NSMutableArray *allUserTags;
    NSMutableDictionary *tagDataMap;
    
}

@end

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

- (id) init
{
    allUserTags = [[NSMutableArray alloc] init];
    tagDataMap = [[NSMutableDictionary alloc] init];
    return self;
}

- (id) initWithCoder:(NSCoder *) decoder
{
    // Unarchive the singleton instance.
    SKTagCollection *instance = [SKTagCollection sharedInstance];
    
    instance->allUserTags = [decoder decodeObjectForKey:@"allUserTags"];
    instance->tagDataMap = [decoder decodeObjectForKey:@"tagDataMap"];
    
    return instance;
}

- (void) encodeWithCoder: (NSCoder *) encoder
{
    // Archive the singleton instance.
    SKTagCollection *instance = [SKTagCollection sharedInstance];
    
    [encoder encodeObject:instance->allUserTags forKey:@"allUserTags"];
    [encoder encodeObject:instance->tagDataMap forKey:@"tagDataMap"];
}

- (SKTagData *) getTagInfo: (SKImageTag *) tag
{
    return (SKTagData *) [tagDataMap objectForKey: tag];
}

- (void) addTagToCollection: (SKImageTag *) tag
{
    if (![allUserTags containsObject: tag]) {
        [allUserTags addObject: tag];
        SKTagData *data = [[SKTagData alloc] init];
        data.tagColor = tag.tagColor;
        [tagDataMap setObject:data forKey:tag];
    }
    else {
        [NSException raise:@"Repeated tag." format:@"Tag %@ is already in collection", tag.tagName];
    }
}

-(void) updateCollectionWithTag:(SKImageTag *)tag forImageURL: (NSURL *) url
{
    if ([allUserTags containsObject:tag]) {
        SKTagData *currentData = [tagDataMap objectForKey:tag];
        if (![currentData.imageURLs containsObject:url]) {
            currentData.tagFrequencyInPhotos++;
            [currentData.imageURLs addObject:url];
        }
        else {
            [NSException raise:@"Repeated asset URL" format:@"URL %@ is already associated with tag %@.",
                [url absoluteString], tag.tagName];
        }
    }
    else {
        [NSException raise:@"Missing tag." format:@"Tag %@ is not yet in collection.", tag.tagName];
    }
}

- (BOOL) isTagInCollection: (SKImageTag *) tag
{
    return [allUserTags containsObject: tag];
}

-(BOOL) isURL: (NSURL *) url associatedWithTag: (SKImageTag *) tag
{
    SKTagData *tagData = [tagDataMap objectForKey:tag];
    return [tagData.imageURLs containsObject:url];
}

- (void) changeTag: (SKImageTag *) tag toColor: (UIColor *) color
{
    if (![allUserTags containsObject: tag]) {
        @throw [NSException exceptionWithName: @"TagNotFoundException" reason: @"The specified tag was not found." userInfo:nil];
    }
    
    SKTagData *data = [tagDataMap objectForKey: tag];
    data.tagColor = color;
    [tagDataMap setObject: data forKey: tag];
}

- (void) removeImageURL: (NSURL *) url forTag: (SKImageTag *) tag
{
    SKTagData *tagData = [tagDataMap objectForKey:tag];
    if ([tagData.imageURLs containsObject:url]) {
        [tagData.imageURLs removeObject:url];
        tagData.tagFrequencyInPhotos--;
        [tagDataMap setObject:tagData forKey:tag];
    }
    else {
        [NSException raise:@"URL Not Found." format:@"URL %@ is not associated with tag %@.", [url absoluteString], tag.tagName];
    }
}

- (void) removeTag: (SKImageTag *) tag;
{
    [allUserTags removeObject:tag];
    [tagDataMap removeObjectForKey:tag];
}

- (void) removeAllTags
{
    [allUserTags removeAllObjects];
    [tagDataMap removeAllObjects];
}

@end
