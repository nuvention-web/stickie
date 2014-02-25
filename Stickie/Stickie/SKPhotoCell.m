//
//  SKPhotoCell.m
//  Stickie
//
//  Created by Stephen Z on 1/22/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKPhotoCell.h"

@interface SKPhotoCell ()

@property(nonatomic, weak) IBOutlet UIImageView *photoImageView;

@end

@implementation SKPhotoCell
- (void) setAsset:(ALAsset *)asset
{
    _asset = asset;
    self.photoImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
}

@end
