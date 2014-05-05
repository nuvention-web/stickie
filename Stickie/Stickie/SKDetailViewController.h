//
//  SKDetailViewController.h
//  Stickie
//
//  Created by Stephen Z on 1/23/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface SKDetailViewController : GAITrackedViewController {
    @public
    int imageIndex;
}

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSArray *assets;
@property (nonatomic,retain) UIDocumentInteractionController *docFile;
@property (weak, nonatomic) IBOutlet UIImageView *drawingImageView;
@property (weak, nonatomic) IBOutlet UIView *drawingView;

@end
