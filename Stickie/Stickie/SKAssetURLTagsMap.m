//
//  SKAssetURLTagsMap.m
//  Stickie
//
//  Created by Grant Sheldon on 1/24/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKAssetURLTagsMap.h"

@interface SKAssetURLTagsMap () {
    NSMutableDictionary *assetURLToTagsMap;
}

@end


@implementation SKAssetURLTagsMap

/* Implementing class as a singleton */
+ (SKAssetURLTagsMap *) sharedInstance
{
    static dispatch_once_t once;
    static SKAssetURLTagsMap *instance;
    
    dispatch_once(&once, ^{
        instance = [[SKAssetURLTagsMap alloc] init];
    });
    
    return instance;
}

- (id) init
{
    assetURLToTagsMap = [[NSMutableDictionary alloc] init] ;
    return self;
}

- (id) initWithCoder:(NSCoder *) decoder
{
    // Unarchive the singleton instance.
    SKAssetURLTagsMap *instance = [SKAssetURLTagsMap sharedInstance];
    
    instance->assetURLToTagsMap = [decoder decodeObjectForKey:@"assetURLTagsMap"];
    
    return instance;
}

- (void) encodeWithCoder: (NSCoder *) encoder
{
    // Archive the singleton instance.
    SKAssetURLTagsMap *instance = [SKAssetURLTagsMap sharedInstance];
    
    [encoder encodeObject:instance->assetURLToTagsMap forKey:@"assetURLTagsMap"];
}

- (NSMutableArray *) getTagsForAssetURL: (NSURL *) imageURL
{
    return [assetURLToTagsMap objectForKey: imageURL];
}

- (void) addTag: (SKImageTag *) tag forAssetURL: (NSURL<NSCopying> *) imageURL
{
    NSMutableArray *tags = [assetURLToTagsMap objectForKey:imageURL];
    if (!tags)
        tags = [[NSMutableArray alloc] init];
    if ([tags containsObject:tag]) {
        [NSException raise:@"Repeated tag" format:@"Tag %@ has already been associated with URL %@", tag.tagName, [imageURL absoluteString]];
    }
    else {
        [tags addObject:tag];
        [assetURLToTagsMap setObject: tags forKey: imageURL];
    }
}
- (void) transferURLSFrom: (SKImageTag *) oldTag to: (SKImageTag *) newTag
{
    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
    SKTagData *tagData = [tagCollection getTagInfo: oldTag];
    for (NSURL *url in tagData.imageURLs) {
        [tagCollection updateCollectionWithTag:newTag forImageURL:url];
        [self addTag: newTag forAssetURL:url];
    }
}
- (BOOL) doesURL: (NSURL *) url haveTag: (SKImageTag *) tag
{
//    return [[self getTagsForAssetURL:url] containsObject:tag];
    
    NSMutableArray *tags = [self getTagsForAssetURL:url];
    
    if (!tags)
        return NO;
    else {
        return [tags containsObject:tag];
    }
    
}

- (NSArray *) allURLs
{
    return [assetURLToTagsMap allKeys];
}

- (void) removeAllTagsForURL: (NSURL *) imageURL
{
    if (![assetURLToTagsMap objectForKey:imageURL]) {
        [NSException raise:@"URL not found." format:@"URL %@ not found.", [imageURL absoluteString]];
    }
    else {
        NSMutableArray *emptyTagArray = [[NSMutableArray alloc] init];
        [assetURLToTagsMap setObject:emptyTagArray forKey:imageURL];
    }
}

- (void) removeTag: (SKImageTag *) tag forAssetURL: (NSURL *) imageURL
{
    NSMutableArray *tags = [assetURLToTagsMap objectForKey:imageURL];
    if (!tags) {
        [NSException raise:@"URL not found." format:@"URL %@ not found.", [imageURL absoluteString]];
    }
    else {
        [tags removeObject:tag];
        [assetURLToTagsMap setObject:tags forKey:imageURL];
    }
}

-(void) removeAllMappingsToTag: (SKImageTag *) tag
{
    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
    SKTagData *tagData = [tagCollection getTagInfo: tag];
    NSMutableArray *urls = tagData.imageURLs;
    
    for (NSURL *url in urls){
        [self removeTag:tag forAssetURL:url];
    }
}

- (void) removeAllURLs
{
    [assetURLToTagsMap removeAllObjects];
}
@end
