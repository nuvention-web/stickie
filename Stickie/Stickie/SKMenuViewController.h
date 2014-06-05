//
//  SKMenuViewController.h
//  Stickie
//
//  Created by Grant on 5/20/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifndef STICKIE_ABOUT_URL
#define STICKIE_ABOUT_URL @"http://www.stickiepic.com/blog/about/"
#endif

#ifndef STICKIE_FAQ_URL
#define STICKIE_FAQ_URL @"http://www.stickiepic.com/blog/faqs/"
#endif

@class  SKMenuViewController;

@protocol SKMenuViewControllerDelegate <NSObject>
- (void)loadExtTutorial:(SKMenuViewController*)controller;
@end

@interface SKMenuViewController : UITableViewController
@property (nonatomic, weak) id <SKMenuViewControllerDelegate> delegate;

@end
