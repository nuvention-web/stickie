//
//  SKTagSearchViewController.h
//  Stickie
//
//  Created by Stephen Z on 2/5/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKTagSearchViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *topLeftButton;
@property (strong, nonatomic) IBOutlet UIButton *topRightButton;
@property (strong, nonatomic) IBOutlet UIButton *botLeftButton;
@property (strong, nonatomic) IBOutlet UIButton *botRightButton;

@property (strong, nonatomic) NSString *topLeftText;
@property (strong, nonatomic) NSString *topRightText;
@property (strong, nonatomic) NSString *botLeftText;
@property (strong, nonatomic) NSString *botRightText;

@end
