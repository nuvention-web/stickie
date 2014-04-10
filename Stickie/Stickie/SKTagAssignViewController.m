//
//  SKTagAssignViewController.m
//  Stickie
//
//  Created by Stephen Z on 2/26/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKTagAssignViewController.h"

@interface SKTagAssignViewController ()

@end

@implementation SKTagAssignViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_createTag) {
        self.navigationItem.title = @"create tag";
    }
    else {
        self.navigationItem.title = @"edit tag";
    }
    _tagTextField.text = _preLabel;
}

- (IBAction) cancel:(id)sender
{
    [self.delegate tagAssignViewControllerDidCancel:self];
}

- (IBAction) done:(id)sender
{
    if ([_tagTextField.text isEqualToString:@""]) {
        [self.delegate tagAssignViewController:self didAddTag:_tagTextField.text for:_source andDelete:YES];
    }
    else {
        [self.delegate tagAssignViewController:self didAddTag:_tagTextField.text for:_source andDelete:NO];
    }
}

- (IBAction) deleteTag:(id)sender {
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

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.delegate tagAssignViewController:self didAddTag:@"" for:_source andDelete:YES];
    }
}
@end
