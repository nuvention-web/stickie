//
//  SKTagCollection.h
//  Stickie
//
//  Created by Grant Sheldon on 1/23/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKTagData.h"
#import "SKImageTag.h"

@interface SKTagCollection : NSObject <NSCoding>

/* Initializes singleton. */
+ (SKTagCollection *) sharedInstance;

/* Returns SKTagData object associated with tag. */
- (SKTagData *) getTagInfo: (SKImageTag *) tag;

/* Returns all tags in collection. */
- (NSMutableArray *) getAllTags;

/* Adds a new tag to the collection. Throws an exception if the tag is already in the collection. */
- (void) addTagToCollection: (SKImageTag *) tag;

/* 
 * Updates data in collection with tag for a given image URL. 
 * Throws exception if tag is not in collection, or if url is already associated with that tag.
 */
- (void) updateCollectionWithTag:(SKImageTag *)tag forImageURL: (NSURL *) url;

/* Returns YES if tag is in collection; returns NO otherwise. */
- (BOOL) isTagInCollection: (SKImageTag *) tag;

/* Returns YES if tag is associated with url; returns NO otherwise. */
- (BOOL) isURL: (NSURL *) url associatedWithTag: (SKImageTag *) tag;

/* Changes color of tag to input color. Throws exception if tag is not found in collection. */
- (void) changeTag: (SKImageTag *) tag toColor: (UIColor *) color;

/* Unassociates url with tag. Throws exception if url is not already associated with tag. */
- (void) removeImageURL: (NSURL *) url forTag: (SKImageTag *) tag;

/* Deletes all mappings to url from all tags. */
- (void) removeAllInstancesOfURL: (NSURL *) url;

/* Deletes tag and all of its mappings. */
- (void) removeTag: (SKImageTag *) tag;

/* DANGER, DRAGONS LIE AHEAD: This method will nuke all tags in the collection and their mappings. */
- (void) removeAllTags;

@end
