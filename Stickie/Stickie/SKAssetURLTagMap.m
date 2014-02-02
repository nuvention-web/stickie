//
//  SKAssetURLTagMap.m
//  Stickie
//
//  Created by Grant Sheldon on 1/24/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKAssetURLTagMap.h"

@interface SKAssetURLTagMap () {
    
    NSMutableDictionary *assetURLToTagMap;
    
}

@end


@implementation SKAssetURLTagMap

/* Implementing class as a singleton */
+ (SKAssetURLTagMap *) sharedInstance
{
    static dispatch_once_t once;
    static SKAssetURLTagMap *instance;
    
    dispatch_once(&once, ^{
        instance = [[SKAssetURLTagMap alloc] init];
    });
    
    return instance;
}

- (id) init
{
    assetURLToTagMap = [[NSMutableDictionary alloc] init] ;
    return self;
}

- (id) initWithCoder:(NSCoder *) decoder
{
    // Unarchive the singleton instance.
    SKAssetURLTagMap *instance = [SKAssetURLTagMap sharedInstance];
    
    instance->assetURLToTagMap = [decoder decodeObjectForKey:@"assetURLToTagMap"];
    
    return instance;
}

- (void) encodeWithCoder: (NSCoder *) encoder
{
    // Archive the singleton instance.
    SKAssetURLTagMap *instance = [SKAssetURLTagMap sharedInstance];
    
    [encoder encodeObject:instance->assetURLToTagMap forKey:@"assetURLToTagMap"];
}

- (SKImageTag *) getTagForAssetURL: (NSURL *) imageURL
{
    return [assetURLToTagMap objectForKey: imageURL];
}

- (void) setTag: (SKImageTag *) tag forAssetURL: (NSURL<NSCopying> *) imageURL
{
    [assetURLToTagMap setObject: tag forKey: imageURL];
}

- (void) removeTagForAssetURL: (NSURL *) imageURL;
{
    [assetURLToTagMap removeObjectForKey: imageURL];
}

-(void) removeAllTags
{
    [assetURLToTagMap removeAllObjects];
}
@end
