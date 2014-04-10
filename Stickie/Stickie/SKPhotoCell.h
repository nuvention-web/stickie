//
//  SKPhotoCell.h
//  Stickie
//
//  Created by Stephen Z on 1/22/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface SKPhotoCell : UICollectionViewCell

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic) BOOL topLeftCorner;
@property (nonatomic) BOOL topRightCorner;
@property (nonatomic) BOOL botLeftCorner;
@property (nonatomic) BOOL botRightCorner;


@end
