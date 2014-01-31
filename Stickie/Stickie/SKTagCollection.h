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

@property (nonatomic) NSMutableArray *allUserTags;
@property (nonatomic) NSMutableDictionary *tagDataMap;

typedef enum {
    HIGHER, LOWER
} SKHigherOrLower;

+ (SKTagCollection *) sharedInstance;
- (SKTagData *) getTagInfo: (SKImageTag *) tag;
- (void) updateCollectionWithTag: (SKImageTag<NSCopying> *) tag;
- (BOOL) isTagInCollection: (SKImageTag *) tag;
- (void) changeTag: (SKImageTag<NSCopying> *) tag toFreqOneHigherOrLower: (SKHigherOrLower) choice;
- (void) changeTag: (SKImageTag<NSCopying> *) tag toColor: (UIColor *) color;

@end
