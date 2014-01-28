//
//  SKDetailViewController.m
//  Stickie
//
//  Created by Stephen Z on 1/23/14.
//  Copyright (c) 2014 Stephen Z. All rights reserved.
//

#import "SKDetailViewController.h"

@interface SKDetailViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation SKDetailViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.imageView.image = self.image;
}

@end