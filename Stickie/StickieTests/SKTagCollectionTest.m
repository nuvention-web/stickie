//
//  SKTagCollectionTest.m
//  Stickie
//
//  Created by Grant Sheldon on 1/29/14.
//  Copyright (c) 2014 Stephen Z. All rights reserved.
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
        [tagCollection.allUserTags addObject:tag];
    }

    SKTagCollection *tagCollection2 = [SKTagCollection sharedInstance];
    XCTAssertEqualObjects(tagCollection, tagCollection2, "SKTagCollection objects should be the same.");
    
    SKTagCollection *tagCollection3 = [[SKTagCollection alloc] init];
    XCTAssertNotEqual(tagCollection, tagCollection3, "SKTagCollection tags should not be equal at this point");
}

-(void)testUpdateCollectionWithTag
{
    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
    for (int i=0; i<25; i++) {
        SKImageTag *tag = [[SKImageTag alloc] init];
        NSString *str = @"cody";
        [tag setTagName:str];
        [tagCollection updateCollectionWithTag: tag];
    }
    
    SKImageTag *tag = [[SKImageTag alloc] init];
    tag.tagName = @"john";
    [tagCollection updateCollectionWithTag: tag];
    
    SKTagData *data = [tagCollection.tagDataMap objectForKey:tag];
    XCTAssertTrue(data.tagFrequencyInPhotos == 1, "john appears in collection only once.");
    
    tag.tagName = @"cody";
    data = [tagCollection.tagDataMap objectForKey:tag];
    XCTAssertTrue(data.tagFrequencyInPhotos == 25, "cody appears in collection 25 times.");
}

@end
