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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
