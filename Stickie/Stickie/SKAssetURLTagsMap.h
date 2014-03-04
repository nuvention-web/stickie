//
//  SKAssetURLTagsMap.h
//  Stickie
//
//  Created by Grant Sheldon on 1/24/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SKImageTag.h"
#import "SKTagData.h"
#import "SKTagCollection.h"

@interface SKAssetURLTagsMap : NSObject <NSCoding>

+ (SKAssetURLTagsMap *) sharedInstance;
- (NSMutableArray *) getTagsForAssetURL: (NSURL *) imageURL;
- (void) addTag: (SKImageTag *) tag forAssetURL: (NSURL *) imageURL;
- (BOOL) doesURL: (NSURL *) url haveTag: (SKImageTag *) tag;
- (void) removeTag: (SKImageTag *) tag forAssetURL: (NSURL *) imageURL;
-(void) removeAllMappingsToTag: (SKImageTag *) tag;
- (void) removeAllTagsForURL: (NSURL *) imageURL;
- (void) removeAllURLs;

@end
