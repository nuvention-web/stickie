//
//  SKIGShareViewController.h
//  Stickie
//
//  Created by Grant Sheldon on 5/6/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKIGShareViewController : UICollectionViewController

@property (nonatomic,retain) UIDocumentInteractionController *docFile;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSURL *url;
@end
