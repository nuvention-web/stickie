//
//  SKAssetURLTagMap.h
//  Stickie
//
//  Created by Grant Sheldon on 1/24/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SKImageTag.h"

@interface SKAssetURLTagMap : NSObject <NSCoding>

+ (SKAssetURLTagMap *) sharedInstance;
- (SKImageTag *) getTagForAssetURL: (NSURL *) imageURL;
- (void) setTag: (SKImageTag *) tag forAssetURL: (NSURL *) imageURL;
- (void) removeTagForAssetURL: (NSURL *) imageURL;
- (void) removeAllTags;

@end
