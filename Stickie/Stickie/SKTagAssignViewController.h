//
//  SKTagAssignViewController.h
//  Stickie
//
//  Created by Stephen Z on 2/26/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKImageTag.h"

@class  SKTagAssignViewController;

@protocol SKTagAssignViewControllerDelegate <NSObject>
- (void)tagAssignViewControllerDidCancel:(SKTagAssignViewController *)controller;
- (void)tagAssignViewController:(SKTagAssignViewController *)controller didAddTag: (NSString *)tag forLocation: (SKCornerLocation) cornerLocation andDelete: (BOOL) delete andDidTagImageURL:(NSURL *)assetURL forAssets:(NSArray*)assets;
@end

@interface SKTagAssignViewController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic) SKCornerLocation location;
@property (nonatomic) NSString *preLabel;
@property (nonatomic) BOOL createTag;
@property (nonatomic) NSURL *tagImageURL;
@property (nonatomic) NSArray *assets;

@property (nonatomic, weak) id <SKTagAssignViewControllerDelegate> delegate;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)deleteTag:(id)sender;
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;
@property (weak, nonatomic) IBOutlet UITextField *tagTextField;

@end
