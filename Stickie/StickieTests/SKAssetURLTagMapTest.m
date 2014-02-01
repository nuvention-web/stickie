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
    
    [map setTag:tag forAssetURL:url];

    NSString *tagOutput = [map getTagForAssetURL: url].tagName ;
    
    XCTAssertEqualObjects(tag.tagName, tagOutput, "Tags should be equal.");
}

-(void)testSetTagForAssetURL
{
    SKAssetURLTagMap *map = [SKAssetURLTagMap sharedInstance];
    
    SKImageTag *tag = [[SKImageTag alloc] init];
    
    tag.tagName = @"cody";

    NSString *filePath = @"http://www.myschool.edu/~myuserid/test.rtf";
	NSURL *url = [[NSURL alloc]  initFileURLWithPath:filePath];
    
    [map setTag:tag forAssetURL:url];
    
    SKImageTag *tag2 = [map getTagForAssetURL:url];
    SKImageTag *tag3 = [[SKImageTag alloc] init];
    
    XCTAssertEqualObjects(tag, tag2, "Tag and Tag2 should be equal");
    XCTAssertNotEqualObjects(tag, tag3, "Tag and Tag3 should not be equal");
}

-(void)testRemoveTagForAssetURL
{
    SKAssetURLTagMap *map = [SKAssetURLTagMap sharedInstance];
    
    SKImageTag *tag = [[SKImageTag alloc] init];
    
    tag.tagName = @"cody";
    
    NSString *filePath = @"http://www.myschool.edu/~myuserid/test.rtf";
	NSURL *url = [[NSURL alloc]  initFileURLWithPath:filePath];
    
    [map setTag:tag forAssetURL:url];
    
    [map removeTagForAssetURL:url];
    
    SKImageTag *tagOut = [map getTagForAssetURL:url];
    XCTAssertNotEqualObjects(tag, tagOut, "Tag and tagOut should not be equal.");
}

-(void)testRemoveAllTags
{
    SKAssetURLTagMap *map = [SKAssetURLTagMap sharedInstance];
    
    SKImageTag *tag = [[SKImageTag alloc] init];
    tag.tagName = @"cody";
    
    SKImageTag *tag2 = [[SKImageTag alloc] init];
    tag.tagName = @"john";
    
    NSString *filePath = @"http://www.myschool.edu/~myuserid/test.rtf";
	NSURL *url = [[NSURL alloc]  initFileURLWithPath:filePath];
    
    filePath = @"www.google.com";
	NSURL *url2 = [[NSURL alloc]  initFileURLWithPath:filePath];
    
    [map setTag:tag forAssetURL:url];
    
    [map setTag:tag2 forAssetURL:url2];
    
    [map removeAllTags];
    
    SKImageTag *tagOut = [map getTagForAssetURL:url];
    XCTAssertNotEqualObjects(tag, tagOut, "Tag and tagOut should not be equal.");
    
    tagOut = [map getTagForAssetURL:url2];
    XCTAssertNotEqualObjects(tag2, tagOut, "Tag2 and tagOut should not be equal.");
}

@end
