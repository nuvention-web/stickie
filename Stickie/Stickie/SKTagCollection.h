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

typedef enum {
    HIGHER, LOWER
} SKHigherOrLower;

+ (SKTagCollection *) sharedInstance;
- (SKTagData *) getTagInfo: (SKImageTag *) tag;
//- (void) updateCollectionWithTag: (SKImageTag *) tag;
- (void) addTagToCollection: (SKImageTag *) tag;
- (void) updateCollectionWithTag:(SKImageTag *)tag forImageURL: (NSURL *) url;
- (BOOL) isTagInCollection: (SKImageTag *) tag;
- (void) changeTag: (SKImageTag *) tag toFreqOneHigherOrLower: (SKHigherOrLower) choice;
- (void) changeTag: (SKImageTag *) tag toColor: (UIColor *) color;
- (void) removeImageURL: (NSURL *) url forTag: (SKImageTag *) tag;
- (void) removeTag: (SKImageTag *) tag;

/* DANGER, DRAGONS LIE AHEAD: This method will nuke all tags in the collection: */
- (void) removeAllTags;

@end
