//
//  SKPhotoCell.m
//  Stickie
//
//  Created by Stephen Z on 1/22/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKPhotoCell.h"
#import "SKAssetURLTagsMap.h"

@interface SKPhotoCell ()

@property(nonatomic, weak) IBOutlet UIImageView *photoImageView;

@end

@implementation SKPhotoCell

- (void) setAsset:(ALAsset *) asset
{
    _asset = asset;
    
    SKAssetURLTagsMap *urlTagsMap = [SKAssetURLTagsMap sharedInstance];
    SKImageTag *topLeftTag = [[SKImageTag alloc] initWithName:_topLeftCorner location:SKCornerLocationTopLeft andColor:nil];
    SKImageTag *topRightTag = [[SKImageTag alloc] initWithName:_topRightCorner location:SKCornerLocationTopRight andColor:nil];
    SKImageTag *botLeftTag = [[SKImageTag alloc] initWithName:_botLeftCorner location:SKCornerLocationBottomLeft andColor:nil];
    SKImageTag *botRightTag = [[SKImageTag alloc] initWithName:_botRightCorner location:SKCornerLocationBottomRight andColor:nil];
    
    NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
    
    UIImage *backgroundImage = [UIImage imageWithCGImage:[asset thumbnail]];
    UIImage *topLeftWatermarkImage = [UIImage imageNamed:@"CornerBlue.png"];
    UIImage *topRightWatermarkImage = [UIImage imageNamed:@"CornerGreen.png"];
    UIImage *botLeftWatermarkImage = [UIImage imageNamed:@"CornerRed.png"];
    UIImage *botRightWatermarkImage = [UIImage imageNamed:@"CornerOrange.png"];
    UIImage *selectedWatermarkImage = [UIImage imageNamed:@"SearchStickie_222x222.png"];
    
    UIGraphicsBeginImageContext(backgroundImage.size);
    if ([_selectedAsset containsObject:asset]) {
        [selectedWatermarkImage drawInRect:CGRectMake(backgroundImage.size.width/4, backgroundImage.size.width/4, backgroundImage.size.width/2, backgroundImage.size.width/2)];
        [backgroundImage drawInRect:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)blendMode:kCGBlendModeNormal alpha:0.5];
    }
    else {
        [backgroundImage drawInRect:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
    }
    if ([urlTagsMap doesURL:url haveTag:topLeftTag]) {
        [topLeftWatermarkImage drawInRect:CGRectMake(0, 0, backgroundImage.size.width/4, backgroundImage.size.width/4)];
    }
    if ([urlTagsMap doesURL:url haveTag:topRightTag]) {
        [topRightWatermarkImage drawInRect:CGRectMake(3*backgroundImage.size.width/4, 0, backgroundImage.size.width/4, backgroundImage.size.width/4)];
    }
    if ([urlTagsMap doesURL:url haveTag:botLeftTag]) {
        [botLeftWatermarkImage drawInRect:CGRectMake(0, 3*backgroundImage.size.width/4, backgroundImage.size.width/4, backgroundImage.size.width/4)];
    }
    if ([urlTagsMap doesURL:url haveTag:botRightTag]) {
        [botRightWatermarkImage drawInRect:CGRectMake(3*backgroundImage.size.width/4, 3*backgroundImage.size.width/4, backgroundImage.size.width/4, backgroundImage.size.width/4)];
    }
    if ([_selectedAsset containsObject:asset]) {
        [selectedWatermarkImage drawInRect:CGRectMake(backgroundImage.size.width/4, backgroundImage.size.width/4, backgroundImage.size.width/2, backgroundImage.size.width/2)];
    }
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    self.photoImageView.image = result;
    
}

@end
