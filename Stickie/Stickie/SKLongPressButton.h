//
//  SKLongPressButton.h
//  Stickie
//
//  Created by Grant Sheldon on 3/9/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKLongPressButton : UIButton {
    UILongPressGestureRecognizer *longPressGestureRecognizer;
}

- (void)setLongTouchAction:(SEL)newValue withTarget:(id) target;

@end
