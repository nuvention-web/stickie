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

typedef enum {
    RIGHT, LEFT
} Direction;

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
    
//    /* Necessary for swiping between images */
//    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * [_assets count], self.scrollView.frame.size.height);
//    
//    for (int i = 0; i < [_assets count]; i++) {
//        CGRect frame;
//        frame.origin.x = self.scrollView.frame.size.width * i;
//        frame.origin.y = 0;
//        frame.size = self.scrollView.frame.size;
//        
//        ALAsset *asset = _assets[i];
//        ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
//        UIImage *image = [UIImage imageWithCGImage:[defaultRep fullScreenImage] scale:[defaultRep scale] orientation:0];
//        
//        UIImageView* imgView = [[UIImageView alloc] init];
//        imgView.image = image;
//        imgView.frame = frame;
//        [self.scrollView addSubview:imgView];
//    }
    
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
    switch (recognizer.direction) {
        case UISwipeGestureRecognizerDirectionRight:
            if (imageIndex != 0) {
                imageIndex--;
            }
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            if (imageIndex != [_assets count] -1) {
                imageIndex++;
            }
            break;
        default:
            break;
    }
    
    /* Select new image to be displayed from gesture. */
    ALAsset *asset = _assets[imageIndex];
    ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
    UIImage *image = [UIImage imageWithCGImage:[defaultRep fullScreenImage] scale:[defaultRep scale] orientation:0];
    
    /* Prepare new image to be displayed in view. */
    UIImageView *newImageView = [[UIImageView alloc] init];
    [self.scrollView addSubview:newImageView];
    newImageView.image = image;
    [newImageView setFrame:imageView.frame];
    newImageView.contentMode =  UIViewContentModeScaleAspectFit;
    
    /* Animate swipe. */
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

- (IBAction)backMain:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
