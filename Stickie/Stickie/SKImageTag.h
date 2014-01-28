//
//  SKImageTag.h
//  Stickie
//
//  Created by Grant Sheldon on 1/23/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKImageTag : NSObject

@property (nonatomic) NSString *tagName;
@property (nonatomic) UIColor *tagColor;

- (BOOL) isTagEqualTo: (SKImageTag *) tag;

@end
