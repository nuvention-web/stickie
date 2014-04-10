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
//    UIImage *overlayImage = [UIImage imageNamed:@"OrangeCorner.png"];
//    UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:overlayImage];
//    _asset = asset;
//    self.photoImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
//    [self.photoImageView addSubview:overlayImageView];
//    
//    UIImage *backgroundImage = [UIImage imageWithCGImage:[asset thumbnail]];
//    UIImage *watermarkImage = [UIImage imageNamed:@"OrangeCorner.png"];
    _asset = asset;
    UIImage *backgroundImage = [UIImage imageWithCGImage:[asset thumbnail]];
    UIImage *topLeftWatermarkImage = [UIImage imageNamed:@"BlueCorner.png"];
    UIImage *topRightWatermarkImage = [UIImage imageNamed:@"GreenCorner.png"];
    UIImage *botLeftWatermarkImage = [UIImage imageNamed:@"RedCorner.png"];
    UIImage *botRightWatermarkImage = [UIImage imageNamed:@"OrangeCorner.png"];
    UIGraphicsBeginImageContext(backgroundImage.size);
    [backgroundImage drawInRect:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
    if (_topLeftCorner) {
        [topLeftWatermarkImage drawInRect:CGRectMake(0, 0, backgroundImage.size.width/4, backgroundImage.size.width/4)];
    }
    if (_topRightCorner) {
        [topRightWatermarkImage drawInRect:CGRectMake(3*backgroundImage.size.width/4, 0, backgroundImage.size.width/4, backgroundImage.size.width/4)];
    }
    if (_botLeftCorner) {
        [botLeftWatermarkImage drawInRect:CGRectMake(0, 3*backgroundImage.size.width/4, backgroundImage.size.width/4, backgroundImage.size.width/4)];
    }
    if (_botRightCorner) {
        [botRightWatermarkImage drawInRect:CGRectMake(3*backgroundImage.size.width/4, 3*backgroundImage.size.width/4, backgroundImage.size.width/4, backgroundImage.size.width/4)];
    }
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.photoImageView.image = result;
    
}

@end
