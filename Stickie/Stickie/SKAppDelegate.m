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

@implementation SKAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    /* Sets background color of navigation bar */
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:255.0/255.0 green:116.0/255.0 blue:208.0/255.0 alpha:1.0]];
    
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    /* Sets style of navigation bar title */
    [[UINavigationBar appearance] setTitleTextAttributes:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0],
            NSForegroundColorAttributeName,
            [UIFont fontWithName:@"Arial Hebrew" size:21],
            NSFontAttributeName, nil
        ]
     ];
    
    /* For second prototype, these tags need to be added to the tag collection at startup 
     THIS WILL BREAK IF SERIALIZATION IS IMPLEMENTED*/
    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
    [tagCollection addTagToCollection: [[SKImageTag alloc] initWithName: @"Food" andColor: nil]];
    [tagCollection addTagToCollection: [[SKImageTag alloc] initWithName: @"Favs" andColor: nil]];
    [tagCollection addTagToCollection: [[SKImageTag alloc] initWithName: @"Trips" andColor: nil]];
    [tagCollection addTagToCollection: [[SKImageTag alloc] initWithName: @"Pets" andColor: nil]];
    
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
