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
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>
#import "SKAssetURLTagsMap.h"
#import "SKImageTag.h"
#import "SKIGShareViewController.h"

@interface SKDetailViewController () <UIScrollViewDelegate, UIDocumentInteractionControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate> {
    UIImageView *imageView;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *shareScrollView;

@end

@implementation SKDetailViewController

- (NSArray *)loadButtons
{
    UIButton *INSTAGRAM_BUTTON = [[UIButton alloc] init];
    [INSTAGRAM_BUTTON setBackgroundImage:[UIImage imageNamed:@"sminstagram.png"] forState:UIControlStateNormal];
    [INSTAGRAM_BUTTON addTarget:self action:@selector(shareToInsta:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *FACEBOOK_BUTTON = [[UIButton alloc] init];
    [FACEBOOK_BUTTON setBackgroundImage:[UIImage imageNamed:@"smfacebook.png"] forState:UIControlStateNormal];
    [FACEBOOK_BUTTON addTarget:self action:@selector(shareToFacebook:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *MESSAGE_BUTTON = [[UIButton alloc] init];
    [MESSAGE_BUTTON setBackgroundImage:[UIImage imageNamed:@"smtext.png"] forState:UIControlStateNormal];
    [MESSAGE_BUTTON addTarget:self action:@selector(shareToMessage:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *MAIL_BUTTON = [[UIButton alloc] init];
    [MAIL_BUTTON setBackgroundImage:[UIImage imageNamed:@"smmail.png"] forState:UIControlStateNormal];
    [MAIL_BUTTON addTarget:self action:@selector(shareToMail:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *WHATSAPP_BUTTON = [[UIButton alloc] init];
    [WHATSAPP_BUTTON setBackgroundImage:[UIImage imageNamed:@"smwhatsapp.png"] forState:UIControlStateNormal];
    [WHATSAPP_BUTTON addTarget:self action:@selector(shareToWhatsapp:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *TWITTER_BUTTON = [[UIButton alloc] init];
    [TWITTER_BUTTON setBackgroundImage:[UIImage imageNamed:@"smtwitter.png"] forState:UIControlStateNormal];
    [TWITTER_BUTTON addTarget:self action:@selector(shareToTwitter:) forControlEvents:UIControlEventTouchUpInside];

    return @[INSTAGRAM_BUTTON, FACEBOOK_BUTTON, MESSAGE_BUTTON, MAIL_BUTTON, WHATSAPP_BUTTON, TWITTER_BUTTON];
}

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
    
    [self setupScrollMenuWithButtons:[self loadButtons]];
    
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

- (void)setupScrollMenuWithButtons:(NSArray *)buttons
{
    int x = 10;
    for (UIButton* button in buttons) {
        button.frame = CGRectMake(x, 9.5, 65, 65);
        [_shareScrollView addSubview:button];
        x += button.frame.size.width + 10;
        button.showsTouchWhenHighlighted = YES;
    }
    
    _shareScrollView.contentSize = CGSizeMake(x, _shareScrollView.frame.size.height);
    _shareScrollView.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1.0];
    [_shareScrollView setShowsHorizontalScrollIndicator:NO];
    
    CALayer *BottomBorder = [CALayer layer];
    BottomBorder.frame = CGRectMake(0.0f, 484.0f, self.view.frame.size.width, 0.5f);
    BottomBorder.backgroundColor = [UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:179.0/255.0 alpha:1.0].CGColor;
    [self.view.layer addSublayer:BottomBorder];
    
    [self.view addSubview:_scrollView];
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
    _imageURL = asset.defaultRepresentation.url; // Update imageURL property
    _image = image;
    
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

- (void)shareToFacebook:(id)sender {
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
                              message: @"Please install Facebook for iOS to share your photos!"
                              delegate: self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:@"Download", nil];
        
        [alert show];
    }
}

- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger) index {
    if(index == 1) {
        if ([alertView.title isEqualToString:@"Facebook Not Installed"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/facebook/id284882215?mt=8"]];
        }
        else if ([alertView.title isEqualToString:@"Instagram Not Installed"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/instagram/id389801252?mt=8"]];
        }
        else if ([alertView.title isEqualToString:@"WhatsApp Not Installed"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/whatsapp-messenger/id310633997?mt=8"]];
        }
    }
}


- (void)shareToInsta:(id)sender
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [self performSegueWithIdentifier:@"instaShare" sender:self];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Instagram Not Installed"
                              message: @"Please install Instagram for iOS to share your photos!"
                              delegate: self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:@"Download", nil];
        
        [alert show];
    }
}

-(UIImage*)thumbnailFromView:(UIView*)_myView{
	return [self thumbnailFromView:_myView withSize:_myView.frame.size];
}

-(UIImage*)thumbnailFromView:(UIView*)_myView withSize:(CGSize)viewsize{
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) {
        // Retina display
        CGSize newSize = viewsize;
        newSize.height=newSize.height*2;
        newSize.width=newSize.width*2;
        viewsize=newSize;
    }
    
    UIGraphicsBeginImageContext(_myView.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetShouldAntialias(context, YES);
	[_myView.layer renderInContext: context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    
	CGSize size = _myView.frame.size;
	CGFloat scale = MAX(viewsize.width / size.width, viewsize.height / size.height);
	
	UIGraphicsBeginImageContext(viewsize);
	CGFloat width = size.width * scale;
	CGFloat height = size.height * scale;
	float dwidth = ((viewsize.width - width) / 2.0f);
	float dheight = ((viewsize.height - height) / 2.0f);
	CGRect rect = CGRectMake(dwidth, dheight, size.width * scale, size.height * scale);
	[image drawInRect:rect];
	UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newimg;
}

- (void)shareToWhatsapp:(id)sender {
    NSURL *whatsURL = [NSURL URLWithString:@"whatsapp://"];
    if ([[UIApplication sharedApplication] canOpenURL:whatsURL]) {
        //    UIImage* instaImage = [self thumbnailFromView:imageView]; //Full Image Low Resolution
        UIImage* instaImage = imageView.image; //Top half of image Full Resolution.
        
        NSString* imagePath = [NSString stringWithFormat:@"%@/image.wai", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        [UIImagePNGRepresentation(instaImage) writeToFile:imagePath atomically:YES];
        //    NSLog(@"image size: %@", NSStringFromCGSize(instaImage.size));
        _docFile = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath]];
        _docFile.delegate=self;
        _docFile.UTI = @"net.whatsapp.image";
        [_docFile presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"WhatsApp Not Installed"
                              message: @"Please install WhatsApp for iOS to share your photos!"
                              delegate: self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:@"Download", nil];
        
        [alert show];
    }
}

- (void)shareToMail:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        NSString *messageBody = @"<br><br>Sent via <a href=\"https://itunes.apple.com/gb/app/stickie/id853858851?mt=8\">Stickie</a>." ;
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setMessageBody:messageBody isHTML:YES];
        
        UIImage* instaImage = imageView.image; //Top half of image Full Resolution.
        NSString* imagePath = [NSString stringWithFormat:@"%@/image.png", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        [UIImagePNGRepresentation(instaImage) writeToFile:imagePath atomically:YES];
        
        
        NSData *fileData = [NSData dataWithContentsOfFile:imagePath];
        NSString *mimeType = @"image/png";
        
        [mc addAttachmentData:fileData mimeType:mimeType fileName:@"image"];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Mail Not Setup"
                              message: @"Set up mail on your device to continue."
                              delegate: self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        
        [alert show];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)shareToMessage:(id)sender
{
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController* composeVC = [[MFMessageComposeViewController alloc] init];
        composeVC.messageComposeDelegate = self;
        UIImage* instaImage = imageView.image; //Top half of image Full Resolution.
        NSString *type = @"image/png";

        [composeVC addAttachmentData:UIImagePNGRepresentation(instaImage) typeIdentifier:type filename:@"image.png"];
        [self presentViewController:composeVC animated:YES completion:NULL];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Messaging Not Setup"
                              message: @"Set up messaging on your device to continue."
                              delegate: self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        
        [alert show];
    }

}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:NULL];

}

- (void)shareToTwitter:(id)sender
{
    SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    NSMutableString *hashtags = [NSMutableString stringWithString:@"Get @stickiepics (#stickie):"];
    NSArray *tags = [[NSArray alloc] initWithArray:[[SKAssetURLTagsMap sharedInstance] getTagsForAssetURL:[_assets[imageIndex] valueForProperty:ALAssetPropertyAssetURL]]];
    for (int i = 0; i < [tags count]; i++) {
        [hashtags appendString:@" #"];
        [hashtags appendString:[((SKImageTag*)tags[i]) tagName]];
    }
    
    [composeController setInitialText:hashtags];
    [composeController addImage:imageView.image];
    [composeController addURL: [NSURL URLWithString:
                                @"https://itunes.apple.com/gb/app/stickie/id853858851"]];
    
    [self presentViewController:composeController
                       animated:YES completion:nil];
    
    SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
        if (result == SLComposeViewControllerResultCancelled) {
            
            NSLog(@"delete");
            
        } else
            
        {
            NSLog(@"post");
        }
        
        [composeController dismissViewControllerAnimated:YES completion:Nil];
    };
    composeController.completionHandler =myBlock;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /* Enlarge Image. */
    if ([[segue identifier] isEqualToString:@"instaShare"])
    {
       SKIGShareViewController *instaController = [segue destinationViewController];
        instaController.imageView = imageView;
        instaController.url = _imageURL;
    }
}

@end
