//
//  SKMenuViewController.h
//  Stickie
//
//  Created by Grant on 5/20/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  SKMenuViewController;

@protocol SKMenuViewControllerDelegate <NSObject>
- (void)loadExtTutorial:(SKMenuViewController*)controller;
@end

@interface SKMenuViewController : UITableViewController
@property (nonatomic, weak) id <SKMenuViewControllerDelegate> delegate;

@end
