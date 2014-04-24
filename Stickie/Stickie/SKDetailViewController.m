//
//  SKDetailViewController.m
//  Stickie
//
//  Created by Stephen Z on 1/23/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKDetailViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <FacebookSDK/FacebookSDK.h>


@interface SKDetailViewController () <UIScrollViewDelegate> {
    UIImageView *imageView;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation SKDetailViewController

-(void)viewDidLoad
{
    /* So UIImageView is centered properly. */
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    /* Set inital navigation bar title. */
    [self setNavBarTitleWithIndex:imageIndex+1];
    
    /* Allocates memory for and initializes new subview to house initial image. */
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
    
    /* Add swiping gesture recognizers to image. */
    imageView.userInteractionEnabled = YES;
    UISwipeGestureRecognizer *rightSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    rightSwipe.direction=UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *leftSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    leftSwipe.direction=UISwipeGestureRecognizerDirectionLeft;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [_scrollView addGestureRecognizer:doubleTap];
    
    [imageView addGestureRecognizer:leftSwipe];
    [imageView addGestureRecognizer:rightSwipe];
}

- (void)setNavBarTitleWithIndex: (int)index
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,32,32)];
    [titleLabel setText:[NSString stringWithFormat:@"%d of %lu", index, (unsigned long)[_assets count]]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
    [self.navigationItem setTitleView:titleLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Enlarged Photo Screen";
    
    /* Sets initial image for imageView as well as handles scaling. */
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
        default:
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
    [UIView animateWithDuration:0.15f
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
                         
                         /* Update nav bar title. */
                         [self setNavBarTitleWithIndex:imageIndex+1];
                     }];

}

- (IBAction)shareToFacebook:(id)sender {
    // If the Facebook app is installed and we can present the share dialog
    if([FBDialogs canPresentShareDialogWithPhotos]) {
        FBShareDialogPhotoParams *params = [[FBShareDialogPhotoParams alloc] init];
        params.photos = @[imageView.image];
        
        [FBDialogs presentShareDialogWithPhotoParams:params
                                         clientState:nil
                                             handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                 if (error) {
                                                     NSLog(@"Error: %@", error.description);
                                                 } else {
                                                     NSLog(@"Success!");
                                                 }
                                             }];
        
    } else {
        //The user doesn't have the Facebook for iOS app installed, so we can't present the Share Dialog
        /*Fallback: You have two options
         1. Share the photo as a Custom Story using a "share a photo" Open Graph action, and publish it using API calls.
         See our Custom Stories tutorial: https://developers.facebook.com/docs/ios/open-graph
         2. Upload the photo making a requestForUploadPhoto
         See the reference: https://developers.facebook.com/docs/reference/ios/current/class/FBRequest/#requestForUploadPhoto:
         */
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Facebook Not Installed"
                              message: @"Please install Facebook for iOS to share your Stickies!"
                              delegate: self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:@"Download", nil];
        
        [alert show];
    }
    
}

- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger) index {
    if(index == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.com/apps/facebook"]];
    }
}

- (IBAction)shareToInsta:(id)sender {
}

- (IBAction)shareToText:(id)sender {
}

- (IBAction)shareToMail:(id)sender {
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    
    float newScale = [_scrollView zoomScale] * 4.0;
    
    if (_scrollView.zoomScale > _scrollView.minimumZoomScale)
    {
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
    }
    else
    {
        CGRect zoomRect = [self zoomRectForScale:newScale
                                      withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
        [_scrollView zoomToRect:zoomRect animated:YES];
    }
    
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    zoomRect.size.height = [imageView frame].size.height / scale;
    zoomRect.size.width  = [imageView frame].size.width  / scale;
    
    center = [imageView convertPoint:center fromView:_scrollView];
    
    zoomRect.origin.x    = center.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y    = center.y - ((zoomRect.size.height / 2.0));
    
    return zoomRect;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (IBAction)backMain:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
