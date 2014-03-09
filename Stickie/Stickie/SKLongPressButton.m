//
//  SKLongPressButton.m
//  Stickie
//
//  Created by Grant Sheldon on 3/9/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKLongPressButton.h"
#import "SKViewController.h"

@implementation SKLongPressButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setLongTouchAction:(SEL)newValue withTarget:(id) target
{
    if (newValue == NULL)
    {
        [self removeGestureRecognizer:longPressGestureRecognizer];
        longPressGestureRecognizer = nil;
    }
    else
    {
        longPressGestureRecognizer = nil;
        
        longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:newValue];
        [self addGestureRecognizer:longPressGestureRecognizer];
    }
}

@end
