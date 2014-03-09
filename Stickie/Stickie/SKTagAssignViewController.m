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
    _tagTextField.placeholder = _preLabel;
}
- (IBAction)cancel:(id)sender
{
    [self.delegate tagAssignViewControllerDidCancel:self];
}
- (IBAction)done:(id)sender
{
    [self.delegate tagAssignViewController:self didAddTag:_tagTextField.text for:_source];
}

@end
