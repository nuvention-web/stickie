//
//  SKAssetURLTagMap.m
//  Stickie
//
//  Created by Grant Sheldon on 1/24/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKAssetURLTagMap.h"



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

-(SKAssetURLTagMap *) init
{
    _assetURLToTagMap = [[NSMutableDictionary alloc] init] ;
    return self;
}

- (SKImageTag *) getTagForAssetURL: (NSURL *) imageURL
{
    return [_assetURLToTagMap objectForKey: imageURL];
}

- (void) setTag: (SKImageTag *) tag forAssetURL: (NSURL<NSCopying> *) imageURL
{
    [_assetURLToTagMap setObject: tag forKey: imageURL];
}

- (void) removeTagForAssetURL: (NSURL *) imageURL;
{
    [_assetURLToTagMap removeObjectForKey: imageURL];
}

-(void) removeAllTags
{
    [_assetURLToTagMap removeAllObjects];
}
@end
