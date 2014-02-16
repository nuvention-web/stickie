//
//  SKAssetURLTagsMapTest.m
//  Stickie
//
//  Created by Grant Sheldon on 1/24/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SKAssetURLTagsMap.h"
#import "SKImageTag.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>

//#undef NSLog

@interface SKAssetURLTagsMapTest : XCTestCase

typedef void (^ALAssetsLibraryGroupsEnumerationResultsBlock)(ALAssetsGroup *group, BOOL *stop);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);

@end

@implementation SKAssetURLTagsMapTest

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
    SKAssetURLTagsMap *map = [SKAssetURLTagsMap sharedInstance];
    XCTAssertNotNil(map, "Singleton should not be nil at this point.");
    
    SKImageTag *tag = [[SKImageTag alloc] init];
    tag.tagName = @"cody";
    
    [map addTag:tag forAssetURL: [[NSURL alloc]  initFileURLWithPath: @"www.google.com"]];
    
    SKAssetURLTagsMap *map2 = [SKAssetURLTagsMap sharedInstance];
    XCTAssertEqualObjects(map, map2, "SKAssetURLTagsMap objects should be the same.");
    
    map2 = nil;
    XCTAssertNotEqualObjects(map, map2, "Objects should not be equal at this point.");
}

-(void)testGetTagsForAssetURL_And_AddTagForAssetURL
{
    SKAssetURLTagsMap *map = [SKAssetURLTagsMap sharedInstance];
    
    SKImageTag *tag = [[SKImageTag alloc] init];
    tag.tagName = @"cody";
    
    NSString *filePath = @"http://www.myschool.edu/~myuserid/test.rtf";
	NSURL *url = [[NSURL alloc]  initFileURLWithPath:filePath];
    
    [map addTag:tag forAssetURL:url];

    NSMutableArray *tags = [map getTagsForAssetURL:url];
    NSString *tagOutput = [[tags objectAtIndex:0] tagName];
    
    XCTAssertEqualObjects(tag.tagName, tagOutput, "Tags should be equal.");
    
    SKImageTag *tag2 = [[SKImageTag alloc] init];
    tag2.tagName = @"john";
    [map addTag:tag2 forAssetURL:url];
    tagOutput = [[tags objectAtIndex:1] tagName];
    
    XCTAssertEqualObjects(tag2.tagName, tagOutput, "Tags should be equal.");
}

-(void)testRemoveTagForAssetURL
{
    SKAssetURLTagsMap *map = [SKAssetURLTagsMap sharedInstance];
    
    SKImageTag *tag = [[SKImageTag alloc] init];
    tag.tagName = @"cody";
    SKImageTag *tag2 = [[SKImageTag alloc] init];
    tag2.tagName = @"john";
    
    NSString *filePath = @"http://www.myschool.edu/~myuserid/test.rtf";
	NSURL *url = [[NSURL alloc]  initFileURLWithPath:filePath];
    
    [map addTag:tag forAssetURL:url];
    [map addTag:tag2 forAssetURL:url];
    
    [map removeTag:tag forAssetURL:url];
    
    SKImageTag *tagOut = [[map getTagsForAssetURL:url] objectAtIndex:0];
    XCTAssertNotEqualObjects(tag, tagOut, "Tag and tagOut should not be equal.");
    XCTAssertEqualObjects(tag2, tagOut, "tagOut should be equal to tag john");
}

-(void)testRemoveAllTagsForAssetURL
{
    SKAssetURLTagsMap *map = [SKAssetURLTagsMap sharedInstance];
    
    SKImageTag *tag = [[SKImageTag alloc] init];
    tag.tagName = @"cody";
    SKImageTag *tag2 = [[SKImageTag alloc] init];
    tag2.tagName = @"john";
    
    NSString *filePath = @"http://www.myschool.edu/~myuserid/test.rtf";
	NSURL *url = [[NSURL alloc]  initFileURLWithPath:filePath];
    
    [map addTag:tag forAssetURL:url];
    [map addTag:tag2 forAssetURL:url];
    
    [map removeAllTagsForURL:url];
    
    XCTAssertTrue([[map getTagsForAssetURL:url] count] == 0, "There should not be any tags for this url.");
}

-(void)testRemoveAllURLs
{
    SKAssetURLTagsMap *map = [SKAssetURLTagsMap sharedInstance];
    
    SKImageTag *tag = [[SKImageTag alloc] init];
    tag.tagName = @"cody";
    
    SKImageTag *tag2 = [[SKImageTag alloc] init];
    tag.tagName = @"john";
    
    NSString *filePath = @"http://www.myschool.edu/~myuserid/test.rtf";
	NSURL *url = [[NSURL alloc]  initFileURLWithPath:filePath];
    
    filePath = @"www.google.com";
	NSURL *url2 = [[NSURL alloc]  initFileURLWithPath:filePath];
    
    [map addTag:tag forAssetURL:url];
    
    [map addTag:tag2 forAssetURL:url2];
    
    [map removeAllURLs];
    
    NSMutableArray *outputTags = [map getTagsForAssetURL:url];
    XCTAssertNil(outputTags, "outputTags should be nil here.");
}

@end
