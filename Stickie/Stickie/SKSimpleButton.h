//
//  SKSimpleButton.h
//  Stickie
//
//  Created by Grant on 6/3/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SKSimpleButtonBlue, SKSimpleButtonGreen, SKSimpleButtonRed, SKSimpleButtonOrange
} SKSimpleButtonColor;

@interface SKSimpleButton : UIButton

@property SKSimpleButtonColor color;

@end
