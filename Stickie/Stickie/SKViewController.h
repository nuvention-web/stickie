//
//  SKViewController.h
//  Stickie
//
//  Created by Stephen Z on 1/22/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKTagAssignViewController.h"
#import "GAITrackedViewController.h"
#import "SKLongPressButton.h"
#import "SKTutorialViewController.h"
#import "SKMenuViewController.h"

@interface SKViewController : GAITrackedViewController <UIPageViewControllerDataSource, SKTagAssignViewControllerDelegate, SKMenuViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageImages;

@property (strong, nonatomic) IBOutlet UILabel *topLeftLabel;
@property (strong, nonatomic) IBOutlet UILabel *topRightLabel;
@property (strong, nonatomic) IBOutlet UILabel *botLeftLabel;
@property (strong, nonatomic) IBOutlet UILabel *botRightLabel;

@property (strong, nonatomic) IBOutlet SKLongPressButton *topLeftCorner;
@property (strong, nonatomic) IBOutlet SKLongPressButton *topRightCorner;
@property (strong, nonatomic) IBOutlet SKLongPressButton *botLeftCorner;
@property (strong, nonatomic) IBOutlet SKLongPressButton *botRightCorner;

@property BOOL showTutorial;
@property BOOL shouldReloadCollectionView;

-(void)longPressCornerRecognized:(UILongPressGestureRecognizer *) gestureRecognizer;

@end
