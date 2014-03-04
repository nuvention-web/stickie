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

@interface SKViewController : GAITrackedViewController <SKTagAssignViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *topLeftLabel;
@property (strong, nonatomic) IBOutlet UILabel *topRightLabel;
@property (strong, nonatomic) IBOutlet UILabel *botLeftLabel;
@property (strong, nonatomic) IBOutlet UILabel *botRightLabel;

@end
