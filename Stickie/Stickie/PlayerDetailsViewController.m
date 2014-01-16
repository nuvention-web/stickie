//
//  PlayersDetailViewController.m
//  Stickie
//
//  Created by Stephen Z on 1/15/14.
//  Copyright (c) 2014 Stephen Z. All rights reserved.
//

#import "PlayerDetailsViewController.h"

@implementation PlayerDetailsViewController
- (IBAction)cancel:(id)sender
{
    [self.delegate playerDetailsViewControllerDidCancel:self];
}
- (IBAction)done:(id)sender
{
    [self.delegate playerDetailsViewControllerDidSave:self];
}
@end
