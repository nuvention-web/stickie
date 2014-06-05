//
//  SKTagSearchViewController.h
//  Stickie
//
//  Created by Stephen Z on 2/5/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "SKSimpleButton.h"

@interface SKTagSearchViewController : GAITrackedViewController

@property (strong, nonatomic) IBOutlet SKSimpleButton *topLeftButton;
@property (strong, nonatomic) IBOutlet SKSimpleButton *topRightButton;
@property (strong, nonatomic) IBOutlet SKSimpleButton *botLeftButton;
@property (strong, nonatomic) IBOutlet SKSimpleButton *botRightButton;

@property (strong, nonatomic) NSString *topLeftText;
@property (strong, nonatomic) NSString *topRightText;
@property (strong, nonatomic) NSString *botLeftText;
@property (strong, nonatomic) NSString *botRightText;
@property (strong, nonatomic) NSString *callButtonOnLoad;

-(IBAction) colorButton:(id)sender;

@end
