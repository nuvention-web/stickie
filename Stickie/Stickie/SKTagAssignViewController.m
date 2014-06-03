//
//  SKTagAssignViewController.m
//  Stickie
//
//  Created by Stephen Z on 2/26/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKTagAssignViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"


@interface SKTagAssignViewController ()

@end

@implementation SKTagAssignViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    if (_createTag) {
        self.navigationItem.title = @"create";
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                              action:@"create_tag"  // Event action (required)
                                                               label:nil         // Event label
                                                               value:nil] build]];    // Event value
    }
    else {
        self.navigationItem.title = @"edit";
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                              action:@"edit_tag"  // Event action (required)
                                                               label:nil         // Event label
                                                               value:nil] build]];    // Event value
    }
    _tagTextField.text = _preLabel;
}





- (IBAction)cancel:(id)sender
{
    [self.delegate tagAssignViewControllerDidCancel:self];
}

- (IBAction)done:(id)sender
{
    if ([_tagTextField.text isEqualToString:@""]) {
        [self.delegate tagAssignViewController:self didAddTag:_tagTextField.text forLocation:_location andDelete:YES andDidTagImageURL:nil forAssets:nil];
    }
    else {
        [self.delegate tagAssignViewController:self didAddTag:_tagTextField.text forLocation:_location andDelete:NO andDidTagImageURL:_tagImageURL forAssets:_assets];
    }
}

- (IBAction)deleteTag:(id)sender {
    UIAlertView *alertEmpty = [[UIAlertView alloc] initWithTitle:@"No tag to delete."
                                                          message:nil
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    
    UIAlertView *alertDelete = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to delete this tag?"
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"Delete Tag",nil];
    if ([_preLabel isEqualToString:@""]) {
        [alertEmpty show];
    }
    else {
        [alertDelete show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                              action:@"delete_tag"  // Event action (required)
                                                               label:nil         // Event label
                                                               value:nil] build]];    // Event value
        [self.delegate tagAssignViewController:self didAddTag:@"" forLocation:_location andDelete:YES andDidTagImageURL:nil forAssets:nil];
    }
}
@end
