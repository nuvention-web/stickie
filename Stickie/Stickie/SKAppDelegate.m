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
#import <FacebookSDK/FacebookSDK.h>

@implementation SKAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /* Tracker for Google Analytics */
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-45915238-2"];
    
    // Override point for customization after application launch.
    
    /* Sets appearance of page view controller */
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:124.0/255.0 green:203.0/255.0 blue:255.0/255.0 alpha:1.0];
    pageControl.backgroundColor = [UIColor whiteColor];
    /* Sets background color of navigation bar */
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1.0]];
    
    
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    /* Sets style of navigation bar title */
    [[UINavigationBar appearance] setTitleTextAttributes:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:255.0/255.0 alpha:1.0],
            NSForegroundColorAttributeName,
            [UIFont fontWithName:@"Raleway-Medium" size:26.0],
            NSFontAttributeName, nil
        ]
     ];
    
    // Moves text slighly farther down vertically.
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:3.0 forBarMetrics:UIBarMetricsDefault];
    
    NSMutableDictionary *appState = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathForSave: @"stickie_data"]];
    SKTagCollection *tagCollection = [appState objectForKey:@"tCollect"];
    SKAssetURLTagsMap *urlToTagMap = [appState objectForKey:@"tMap"];
    
    if (!urlToTagMap)
        urlToTagMap = [SKAssetURLTagsMap sharedInstance];
    
    /* If there is nothing to unarchive. */
    if (!tagCollection) {
        tagCollection = [SKTagCollection sharedInstance];
        SKImageTag *tag = [[SKImageTag alloc] initWithName:@"" location:SKCornerLocationUndefined andColor:nil];
        [tagCollection addTagToCollection:tag];
    }
    
    [self checkAndHandleDeletedPhotos];
    
    // DEFAULT SWITCH SETTINGS
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstSwitch"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstSwitch"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"instalikesOn"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"photostreamOn"];
    }
    
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
    [self saveUserDataWithName:@"stickie_data"];
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
    [self saveUserDataWithName:@"stickie_data"];
}

- (void)saveUserDataWithName:(NSString *)name
{
    NSMutableDictionary *appState = [NSMutableDictionary dictionary];
    [appState setObject:[SKTagCollection sharedInstance] forKey:@"tCollect"];
    [appState setObject:[SKAssetURLTagsMap sharedInstance] forKey:@"tMap"];
    BOOL result = [NSKeyedArchiver archiveRootObject:appState toFile: [self filePathForSave:name]];
    if (!result) {
        NSLog(@"Failed to archive objects properly.");
    }
}

- (void)checkAndHandleDeletedPhotos
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

- (NSString *)filePathForSave: (NSString *) nameOfFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *file = [documentsDirectory stringByAppendingString:@"/"];
    file = [file stringByAppendingString:nameOfFile];
    return file;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                                sourceApplication:sourceApplication
                                  fallbackHandler:^(FBAppCall *call) {
                                      NSLog(@"Unhandled deep link: %@", url);
                                      // Here goes the code to handle the links
                                      // Use the links to show a relevant view of your app to the user
                                  }];
    
    return urlWasHandled;
}

@end
