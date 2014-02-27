//
//  SKTagAssignViewController.h
//  Stickie
//
//  Created by Stephen Z on 2/26/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  SKTagAssignViewController;

@protocol SKTagAssignViewControllerDelegate <NSObject>
- (void)tagAssignViewControllerDidCancel:(SKTagAssignViewController *)controller;
- (void)tagAssignViewController:(SKTagAssignViewController *)controller didAddTag: (NSString *)tag for: (NSString *)corner;
@end

@interface SKTagAssignViewController : UITableViewController

@property (nonatomic) NSString *source;

@property (nonatomic, weak) id <SKTagAssignViewControllerDelegate> delegate;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *tagTextField;

@end
