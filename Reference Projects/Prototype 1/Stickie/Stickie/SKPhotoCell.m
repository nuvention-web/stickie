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
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
