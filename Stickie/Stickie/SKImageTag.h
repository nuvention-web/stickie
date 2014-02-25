//
//  SKImageTag.h
//  Stickie
//
//  Created by Grant Sheldon on 1/23/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKImageTag : NSObject <NSCopying, NSCoding>

@property (nonatomic) NSString *tagName;
@property (nonatomic) UIColor *tagColor;

-(id)initWithName: (NSString *) str andColor: (UIColor *) color;
-(BOOL)isEqualToTag:(SKImageTag *) tag;

@end
