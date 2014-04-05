//
//  SKAppDelegate.m
//  Stickie
//
//  Created by Stephen Z on 1/22/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKAppDelegate.h"
#import "SKTagCollection.h"
#import "SKImageTag.h"
#import "SKAssetURLTagsMap.h"
#import "GAI.h"
#import "SKViewController.h"

@implementation SKAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    /* Sets background color of navigation bar */
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1.0]];
    
    
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    /* Sets style of navigation bar title */
    [[UINavigationBar appearance] setTitleTextAttributes:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:255.0/255.0 alpha:1.0],
            NSForegroundColorAttributeName,
            [UIFont fontWithName:@"Arial Hebrew" size:21],
            NSFontAttributeName, nil
        ]
     ];
    
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-45915238-2"];
    
    /* For second prototype, these tags need to be added to the tag collection at startup. */
    SKTagCollection *tagCollection = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"tagCollection"]];
    SKAssetURLTagsMap *urlToTagMap = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"tagsMap"]];
    
    if (!urlToTagMap)
        urlToTagMap = [SKAssetURLTagsMap sharedInstance];
    
    /* If there is nothing to unarchive. */
    if (!tagCollection) {
        tagCollection = [SKTagCollection sharedInstance];
        SKImageTag *tag = [[SKImageTag alloc] initWithName:@"" andColor:nil];
        [tagCollection addTagToCollection:tag];
    }
    
    [self checkAndHandleDeletedPhotos];
        
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [self checkAndHandleDeletedPhotos];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[SKTagCollection sharedInstance]] forKey:@"tagCollection"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[SKAssetURLTagsMap sharedInstance]] forKey:@"tagsMap"];
}

- (void) checkAndHandleDeletedPhotos
{
    /* Check to ensure no photos have been deleted while the user switched applications. */
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    SKAssetURLTagsMap *urlToTagMap = [SKAssetURLTagsMap sharedInstance];
    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
    NSArray *urlArray = [urlToTagMap allURLs];
    
    for (NSURL* url in urlArray) {
        [library assetForURL:url resultBlock:^(ALAsset *asset) {
            if (!asset) {
                [urlToTagMap removeURL:url];
                [tagCollection removeAllInstancesOfURL:url];
            }
        } failureBlock:^(NSError *error) {
            [NSException raise:@"Asset Processing Error." format: @"There was an error processing the required ALAssets."];
        }];
    }
}

@end
