//
//  SKTagData.h
//  Stickie
//
//  Created by Grant Sheldon on 1/23/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKTagData : NSObject

@property (nonatomic) NSInteger tagFrequencyInPhotos;
@property (nonatomic) UIColor *tagColor;
@property (nonatomic) NSMutableArray *imageURLs;

- (id) init;

@end
