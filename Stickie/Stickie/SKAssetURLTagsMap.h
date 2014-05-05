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

/* Initialize singleton. */
+ (SKAssetURLTagsMap *) sharedInstance;

/* Returns an array of all tag objects associated for a given asset URL. */
- (NSMutableArray *) getTagsForAssetURL: (NSURL *) imageURL;

/* Associates a tag with a given asset URL. Throws an exception if the tag is already associated with URL. */
- (void) addTag: (SKImageTag *) tag forAssetURL: (NSURL *) imageURL;

/* Add multiple tags for a given asset URL. No exceptions thrown. */
- (void) addTags: (SKImageTag *) tag forMultipleAssetURLs: (NSArray *) imageURLs;

/* Associates all assetURLs from one tag object with another tag object; removes old mapping. */
- (void) transferURLSFrom: (SKImageTag *) oldTag to: (SKImageTag *) newTag;

/* Returns YES if url is associated with tag; returns NO otherwise. */
- (BOOL) doesURL: (NSURL *) url haveTag: (SKImageTag *) tag;

/* Returns all URLs in SKAssetURLTagsMap. */
- (NSArray *) allURLs;

/* 
 * Removes the association of a particular tag with an assetURL.
 * Throws an exception if the URL is not found in the mapping.
 */
- (void) removeTag: (SKImageTag *) tag forAssetURL: (NSURL *) imageURL;

/* Removes the association of a tag with multiple asset URLs. No exceptions thrown. */
- (void) removeTag: (SKImageTag *) tag forMultipleAssetURLs: (NSArray *) imageURLs;

/* For every assetURL in collection, removes mappings to tag. */
- (void) removeAllMappingsToTag: (SKImageTag *) tag;

/* Deletes URL and all of its mappings from SKAssetURLTagsMap. */
- (void) removeURL: (NSURL *) imageURL;

/* Clears URL of all mappings. Throws exception if URL is not found. */
- (void) removeAllTagsForURL: (NSURL *) imageURL;

/* Clears collection of all URLs and mappings. */
- (void) removeAllURLs;

@end
