//
//  SKDetailViewController.m
//  Stickie
//
//  Created by Stephen Z on 1/23/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKDetailViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface SKDetailViewController () <UIScrollViewDelegate> {
    UIImageView *imageView;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation SKDetailViewController

-(void) viewDidLoad
{
    /* So UIImageView is centered properly. */
    self.automaticallyAdjustsScrollViewInsets = NO;

    /* Allocates memory for and initializes new subview to house initial image */
    imageView = [[UIImageView alloc] init];
    CGRect aRect = CGRectMake(0.0, 0.0, self.scrollView.frame.size.width,self.scrollView.frame.size.height);
    [imageView setFrame: aRect];
    [self.scrollView addSubview:imageView];
    
    /* Necessary for pinch-to-zoom. */
    self.scrollView.delegate = self;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 10.0;
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale];
    
    /* Add swiping gesture recognizers to image */
    imageView.userInteractionEnabled = YES;
    UISwipeGestureRecognizer *rightSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    rightSwipe.direction=UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *leftSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    leftSwipe.direction=UISwipeGestureRecognizerDirectionLeft;
    
    [imageView addGestureRecognizer:leftSwipe];
    [imageView addGestureRecognizer:rightSwipe];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Enlarged Photo Screen";
    
    /* Sets image for imageView as well as handles scaling. */
    imageView.image = self.image;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
}

-(void)handleSwipe: (UISwipeGestureRecognizer *)recognizer
{
    CGFloat width = 0.0;
    switch (recognizer.direction) {
        case UISwipeGestureRecognizerDirectionRight:
            if (imageIndex != 0) {
                imageIndex--;
                width = self.scrollView.frame.size.width;
            }
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            if (imageIndex != [_assets count] -1) {
                imageIndex++;
                width = -self.scrollView.frame.size.width;
            }
            break;
    }
    
    /* Select next image. */
    ALAsset *asset = _assets[imageIndex];
    ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
    UIImage *image = [UIImage imageWithCGImage:[defaultRep fullScreenImage] scale:[defaultRep scale] orientation:0];
    
    /* Prepare new image to be displayed in view. */
    UIImageView *newImageView = [[UIImageView alloc] init];
    [newImageView setFrame: CGRectMake(-width, 0.0, imageView.frame.size.width, imageView.frame.size.height)];;
    [self.scrollView addSubview:newImageView];
    newImageView.image = image;
    newImageView.contentMode =  UIViewContentModeScaleAspectFit;
    
    /* Animate Swipe */
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [newImageView setFrame:imageView.frame];
                         [imageView setFrame:CGRectMake(width, 0.0, imageView.frame.size.width, imageView.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                         /* Post-animation cleanup. */
                         imageView.image = newImageView.image;
                         [imageView setFrame:newImageView.frame];
                         [newImageView removeFromSuperview];
                     }];

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (IBAction)backMain:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
