//
//  SKButtonScrollView.m
//  Stickie
//
//  Created by Grant on 5/15/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKButtonScrollView.h"

@implementation SKButtonScrollView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    NSLog(@"touchesShouldCancelInContentView");
    return YES;
}

@end
