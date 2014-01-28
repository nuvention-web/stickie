//
//  SKAssetURLTagMapTest.m
//  Stickie
//
//  Created by Grant Sheldon on 1/24/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SKAssetURLTagMap.h"
#import "SKImageTag.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>

//#undef NSLog

@interface SKAssetURLTagMapTest : XCTestCase

typedef void (^ALAssetsLibraryGroupsEnumerationResultsBlock)(ALAssetsGroup *group, BOOL *stop);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);

@end

@implementation SKAssetURLTagMapTest

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

- (void)testSharedInstance
{
    SKAssetURLTagMap *map = [SKAssetURLTagMap sharedInstance];
    XCTAssertNotNil(map, "Singleton should not be nil at this point.");
    
    SKImageTag *tag = [[SKImageTag alloc] init];
    tag.tagName = @"cody";
    
    [map setTag:tag forAssetURL: [[NSURL alloc]  initFileURLWithPath: @"www.google.com"]];
    
    SKAssetURLTagMap *map2 = [SKAssetURLTagMap sharedInstance];
    XCTAssertEqualObjects(map, map2, "SKAssetURLTagMap objects should be the same.");
    
    map2 = nil;
    XCTAssertNotEqualObjects(map, map2, "Objects should not be equal at this point.");
}

-(void)testGetTagForAssetURL
{
    SKAssetURLTagMap *map = [SKAssetURLTagMap sharedInstance];
    
    SKImageTag *tag = [[SKImageTag alloc] init];
    tag.tagName = @"cody";
    
    NSString *filePath = @"http://www.myschool.edu/~myuserid/test.rtf";
	NSURL *url = [[NSURL alloc]  initFileURLWithPath:filePath];
    
    [map.assetURLToTagMap setObject: tag forKey: url];
    
    NSString *tagOutput = [map getTagForAssetURL: url].tagName ;
    
    XCTAssertEqualObjects(tag.tagName, tagOutput, "Tags should be equal.");
}

@end
