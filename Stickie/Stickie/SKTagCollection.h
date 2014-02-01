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

@interface SKTagCollection : NSObject 

typedef enum {
    HIGHER, LOWER
} SKHigherOrLower;

+ (SKTagCollection *) sharedInstance;
- (SKTagData *) getTagInfo: (SKImageTag *) tag;
- (void) updateCollectionWithTag: (SKImageTag *) tag;
- (BOOL) isTagInCollection: (SKImageTag *) tag;
- (void) changeTag: (SKImageTag *) tag toFreqOneHigherOrLower: (SKHigherOrLower) choice;
- (void) changeTag: (SKImageTag *) tag toColor: (UIColor *) color;
- (void) removeTag: (SKImageTag *) tag;

/* DANGER, DRAGONS LIE AHEAD: This method will nuke all tags in the collection: */
- (void) removeAllTags;

@end
