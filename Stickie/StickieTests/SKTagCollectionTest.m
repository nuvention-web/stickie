//
//  SKTagCollectionTest.m
//  Stickie
//
//  Created by Grant Sheldon on 1/29/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SKTagCollection.h"

@interface SKTagCollectionTest : XCTestCase

@end

@implementation SKTagCollectionTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

-(void)testSharedInstance
{
    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
    XCTAssertNotNil(tagCollection, "Singleton should not be nil at this point.");
    
    for (int i=0; i<25; i++) {
        SKImageTag *tag = [[SKImageTag alloc] init];
        NSString *str = [NSString stringWithFormat:@"%d",i];
        [tag setTagName:str];
        [tagCollection addTagToCollection:tag];
    }

    SKTagCollection *tagCollection2 = [SKTagCollection sharedInstance];
    XCTAssertEqualObjects(tagCollection, tagCollection2, "SKTagCollection objects should be the same.");
    
    SKTagCollection *tagCollection3 = [[SKTagCollection alloc] init];
    XCTAssertNotEqual(tagCollection, tagCollection3, "SKTagCollection tags should not be equal at this point");
    [tagCollection removeAllTags];
}

-(void)testRemoveAllTagsAndIsInCollection
{
    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
    [tagCollection removeAllTags];
    for (int i=0; i<25; i++) {
        SKImageTag *tag = [[SKImageTag alloc] init];
        NSString *str = @"cody";
        [tag setTagName:str];
        NSString *urlStr = [[NSString alloc] initWithFormat:@"www.google%d.com",i];
        NSURL *url = [[NSURL alloc] initFileURLWithPath:urlStr];
        if (![tagCollection isTagInCollection:tag]) {
            [tagCollection addTagToCollection:tag];
        }
        else {
            if (![tagCollection isURL:url associatedWithTag:tag]) {
                [tagCollection updateCollectionWithTag:tag forImageURL:url];
            }
        }
    }
    
    SKImageTag *tag = [[SKImageTag alloc] init];
    tag.tagName = @"john";
    [tagCollection addTagToCollection: tag];
    
    XCTAssertTrue([tagCollection isTagInCollection:tag], "John should be in the tag collection.");
    
    SKImageTag *tag2 = [[SKImageTag alloc] init];
    tag2.tagName = @"bill";
    XCTAssertFalse([tagCollection isTagInCollection:tag2], "Bill should not be in the tag collection.");
    
    SKImageTag *tag3 = [[SKImageTag alloc] init];
    tag3.tagName = @"cody";
    XCTAssertTrue([tagCollection isTagInCollection:tag3], "Cody should be in the tag collection.");
    
    [tagCollection removeAllTags];
    XCTAssertFalse([tagCollection isTagInCollection:tag3], "Cody should not be in the tag collection.");
}

-(void)testUpdateAndGetTag
{
    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
    [tagCollection removeAllTags];
    for (int i=0; i<25; i++) {
        SKImageTag *tag = [[SKImageTag alloc] init];
        NSString *str = @"cody";
        [tag setTagName:str];
        NSString *urlStr = [[NSString alloc] initWithFormat:@"www.google%d.com",i];
        NSURL *url = [[NSURL alloc] initFileURLWithPath:urlStr];
        if (![tagCollection isTagInCollection:tag]) {
            [tagCollection addTagToCollection:tag];
        }
        else {
            if (![tagCollection isURL:url associatedWithTag:tag]) {
                [tagCollection updateCollectionWithTag:tag forImageURL:url];
            }
        }
    }
    
    SKImageTag *tag = [[SKImageTag alloc] init];
    tag.tagName = @"john";
    NSURL *url = [[NSURL alloc] initWithString:@"www.yahoo.com"];
    [tagCollection addTagToCollection:tag];
    [tagCollection updateCollectionWithTag: tag forImageURL:url];
    
    SKTagData *data = [tagCollection getTagInfo:tag];
    XCTAssertTrue(data.tagFrequencyInPhotos == 1, "john is associated with only one image.");
    
    tag.tagName = @"cody";
    data = [tagCollection getTagInfo:tag];
    XCTAssertTrue(data.tagFrequencyInPhotos == 24, "cody is associcated with 24 images.");
    [tagCollection removeAllTags];
}

//-(void)testChangeTagToFreqOneHigherOrLower
//{
//    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
//    [tagCollection removeAllTags];
//    
//    SKImageTag *tag = [[SKImageTag alloc] init];
//    tag.tagName = @"john";
//    [tagCollection updateCollectionWithTag: tag];
//    SKTagData *data = [tagCollection getTagInfo:tag];
//    XCTAssertTrue(data.tagFrequencyInPhotos == 1, "john appears in collection only once.");
//    
//    [tagCollection changeTag:tag toFreqOneHigherOrLower:HIGHER];
//    data = [tagCollection getTagInfo:tag];
//    XCTAssertTrue(data.tagFrequencyInPhotos == 2, "john has a frequency of 2.");
//    
//    [tagCollection changeTag:tag toFreqOneHigherOrLower:LOWER];
//    data = [tagCollection getTagInfo:tag];
//    XCTAssertTrue(data.tagFrequencyInPhotos == 1, "john has a frequency of 1.");
//    [tagCollection removeAllTags];
//}


@end
