//
//  SKTagSearchViewController.m
//  Stickie
//
//  Created by Stephen Z on 2/5/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKTagSearchViewController.h"
#import "SKTagCollection.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SKPhotoCell.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "SKDetailViewController.h"
#import "SKAssetURLTagsMap.h"
#import "Social/Social.h"
#import <MessageUI/MessageUI.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SKIGShareViewController.h"

@interface SKTagSearchViewController()<UIGestureRecognizerDelegate,MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate,UIDocumentInteractionControllerDelegate>
{
    ALAssetsLibrary *library;
    BOOL topLeftClicked;
    BOOL topRightClicked;
    BOOL botLeftClicked;
    BOOL botRightClicked;
    SKPhotoCell *dCell;
    NSIndexPath *dIndexPath;
    UIImage *dImage;
    CGPoint defaultPoint;
    NSString *currentTag;
    BOOL untag;
    BOOL multi;
    NSMutableArray *selected;
    UIBarButtonItem *multitagButton;
    UIImage *multiOn;
    UIImage *multiOff;
    UIView *lineView;
    UIImage *simage;
    NSURL *imageURL;
    dispatch_queue_t loadImageToShare;
}

typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);
@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray *assets;
@property (weak, nonatomic) IBOutlet UIImageView *dNewImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *shareScrollView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) NSThread *indicatorThread;
@property (nonatomic,retain) UIDocumentInteractionController *docFile;

@end

@implementation SKTagSearchViewController
#pragma mark - Share Button
- (NSArray *)loadButtons
{
    UIButton *FACEBOOK_BUTTON_MULTI = [[UIButton alloc] init];
    [FACEBOOK_BUTTON_MULTI setBackgroundImage:[UIImage imageNamed:@"smfacebook.png"] forState:UIControlStateNormal];
    [FACEBOOK_BUTTON_MULTI addTarget:self action:@selector(shareMultipleToFacebook:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *MESSAGE_BUTTON = [[UIButton alloc] init];
    [MESSAGE_BUTTON setBackgroundImage:[UIImage imageNamed:@"smtext.png"] forState:UIControlStateNormal];
    [MESSAGE_BUTTON addTarget:self action:@selector(shareMultipleToMessage:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *MAIL_BUTTON = [[UIButton alloc] init];
    [MAIL_BUTTON setBackgroundImage:[UIImage imageNamed:@"smmail.png"] forState:UIControlStateNormal];
    [MAIL_BUTTON addTarget:self action:@selector(shareMultipleToMail:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *CLOSE_BUTTON = [[UIButton alloc] init];
    [CLOSE_BUTTON setTitle:@"x" forState:UIControlStateNormal];
    [CLOSE_BUTTON setTitleColor:[UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [CLOSE_BUTTON addTarget:self action:@selector(closeShareScrollView) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *INSTAGRAM_BUTTON = [[UIButton alloc] init];
    [INSTAGRAM_BUTTON setBackgroundImage:[UIImage imageNamed:@"sminstagram.png"] forState:UIControlStateNormal];
    [INSTAGRAM_BUTTON addTarget:self action:@selector(shareToInsta:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *FACEBOOK_BUTTON = [[UIButton alloc] init];
    [FACEBOOK_BUTTON setBackgroundImage:[UIImage imageNamed:@"smfacebook.png"] forState:UIControlStateNormal];
    [FACEBOOK_BUTTON addTarget:self action:@selector(shareToFacebook:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *WHATSAPP_BUTTON = [[UIButton alloc] init];
    [WHATSAPP_BUTTON setBackgroundImage:[UIImage imageNamed:@"smwhatsapp.png"] forState:UIControlStateNormal];
    [WHATSAPP_BUTTON addTarget:self action:@selector(shareToWhatsapp:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *TWITTER_BUTTON = [[UIButton alloc] init];
    [TWITTER_BUTTON setBackgroundImage:[UIImage imageNamed:@"smtwitter.png"] forState:UIControlStateNormal];
    [TWITTER_BUTTON addTarget:self action:@selector(shareToTwitter:) forControlEvents:UIControlEventTouchUpInside];
    
    if (multi){
        return @[FACEBOOK_BUTTON_MULTI, MESSAGE_BUTTON, MAIL_BUTTON, CLOSE_BUTTON];
    }
    else {
        return @[INSTAGRAM_BUTTON, FACEBOOK_BUTTON, MESSAGE_BUTTON, MAIL_BUTTON, WHATSAPP_BUTTON, TWITTER_BUTTON, CLOSE_BUTTON];
    }
}

- (void)setupScrollMenuWithButtons:(NSArray *)buttons
{
    for (id viewToRemove in [_shareScrollView subviews]){
        if ([viewToRemove isMemberOfClass:[UIButton class]])
            [viewToRemove removeFromSuperview];
    }
    
    int x;
    if (multi) {
        x = self.view.frame.size.width/6;
        for (UIButton* button in buttons) {
            if ([button.titleLabel.text isEqual:@"x"]) {
                button.frame = CGRectMake(x, -20, 65, 65);
            }
            else{
                button.frame = CGRectMake(x, 9.5, 65, 65);
            }
            [_shareScrollView addSubview:button];
            x += button.frame.size.width + 10;
        }
    }
    else {
        x = 15;
        for (UIButton* button in buttons) {
            if ([button.titleLabel.text isEqual:@"x"]) {
                button.frame = CGRectMake(0, -20, 15, 65);
            }
            else{
                button.frame = CGRectMake(x, 9.5, 65, 65);
            }
            [_shareScrollView addSubview:button];
            x += button.frame.size.width + 10;
            button.showsTouchWhenHighlighted = YES;
        }
    }
    
    _shareScrollView.contentSize = CGSizeMake(x, _shareScrollView.frame.size.height);
    _shareScrollView.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1.0];
    [_shareScrollView setShowsHorizontalScrollIndicator:NO];
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, (self.view.frame.size.height-84.5), self.view.frame.size.width, 0.5f)];
    lineView.backgroundColor = [UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:179.0/255.0 alpha:1.0];
    [self.view addSubview:lineView];
    [self.shareScrollView setHidden:NO];
    
    [self.view bringSubviewToFront:_shareScrollView];
    
}
#pragma mark Sharing Multiple

- (void)shareMultipleToFacebook:(id)sender
{
    if (!multi) {
        [NSException raise:@"Multi Not Selected" format:@"Cannot share photos while not in multi-select mode."];
    }
    
    SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            
            [fbController dismissViewControllerAnimated:YES completion:nil];
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    NSLog(@"Cancelled.....");
                    [self closeShareScrollView];
                    
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    NSLog(@"Posted....");
                    [self closeShareScrollView];
                }
                    break;
            }};
        
        // Add selected photos to fbController.
        for (ALAsset* asset in selected) {
            ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
            UIImage *image = [UIImage imageWithCGImage:[defaultRep fullScreenImage] scale:[defaultRep scale] orientation:0];
            [fbController addImage:image];
        }
        
        [fbController setCompletionHandler:completionHandler];
        [self presentViewController:fbController animated:YES completion:nil];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Facebook Not Setup"
                              message: @"Please setup your Facebook Account in Settings to share multiple images."
                              delegate: self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

- (void)shareMultipleToMail:(id)sender
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"share_mult_mail"  // Event action (required)
                                                           label:nil         // Event label
                                                           value:nil] build]];    // Event value
    if ([MFMailComposeViewController canSendMail]) {
        _indicatorThread = [[NSThread alloc]initWithTarget:self selector:@selector(showIndicator) object:nil];
        [_indicatorThread start];
        NSString *messageBody = @"<br><br>Sent via <a href=\"https://itunes.apple.com/gb/app/stickie/id853858851?mt=8\">Stickie</a>." ;
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setMessageBody:messageBody isHTML:YES];
        
        NSString* imagePath = [NSString stringWithFormat:@"%@/image.png", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        
        for (ALAsset *asset in selected) {
            ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
            UIImage *image = [UIImage imageWithCGImage:[defaultRep fullScreenImage] scale:[defaultRep scale] orientation:0];
            [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
            
            
            NSData *fileData = [NSData dataWithContentsOfFile:imagePath];
            NSString *mimeType = @"image/png";
            
            [mc addAttachmentData:fileData mimeType:mimeType fileName:@"image"];
        }
        
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
    self.navigationController.view.alpha = 1;
    [_activityView stopAnimating];
    [_indicatorThread cancel];
    [self closeShareScrollView];
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

- (void)shareMultipleToMessage:(id)sender
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"share_mult_message"  // Event action (required)
                                                           label:nil         // Event label
                                                           value:nil] build]];    // Event value
    if ([MFMessageComposeViewController canSendText]) {
        _indicatorThread = [[NSThread alloc]initWithTarget:self selector:@selector(showIndicator) object:nil];
        [_indicatorThread start];
        
        MFMessageComposeViewController* composeVC = [[MFMessageComposeViewController alloc] init];
        composeVC.messageComposeDelegate = self;
        NSString *type = @"image/jpg";
        
        for (ALAsset* asset in selected) {
            ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
            UIImage *image = [UIImage imageWithCGImage:[defaultRep fullScreenImage] scale:[defaultRep scale] orientation:0];
            [composeVC addAttachmentData:UIImagePNGRepresentation(image) typeIdentifier:type filename:@"image.png"];
        }
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
    self.navigationController.view.alpha = 1;
    [_activityView stopAnimating];
    [_indicatorThread cancel];
    [self closeShareScrollView];
}

// For showing the activity indicator.
- (void)showIndicator
{
    @autoreleasepool {
        self.navigationController.view.alpha = 0.5;
        _activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.center = self.view.center;
        [_activityView startAnimating];
        [self.view addSubview:_activityView];
    }
}
- (void)closeShareScrollView{
    [self.view sendSubviewToBack:self.shareScrollView];
    [self.shareScrollView setHidden:YES];
    [lineView removeFromSuperview];
}
#pragma mark - Multi Select

- (void)multiToggle:(id)sender {
    if (multi) {
        multi = NO;
        [self closeShareScrollView];
        
        [selected removeAllObjects];
        [self toggleMultiImage];
    }
    else {
        multi = YES;
        [self toggleMultiImage];
    }
    [_collectionView reloadData];
}
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ALAsset *asset = self.assets[indexPath.row];
    if (multi) {
        if ([selected containsObject:asset]) {
            [selected removeObject:asset];
        }
        else {
            [selected addObject:asset];
        }
        
        [_collectionView reloadData];
    }
}
- (void) toggleMultiImage {
    UIButton *multitagView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [multitagView addTarget:self action:@selector(multiToggle:) forControlEvents:UIControlEventTouchUpInside];
    if (multi){
        [multitagView setBackgroundImage:multiOn
                                forState:UIControlStateNormal];
    }
    else {
        [multitagView setBackgroundImage:multiOff
                                forState:UIControlStateNormal];
    }
    multitagButton = [[UIBarButtonItem alloc] initWithCustomView:multitagView];
    
    [self.navigationItem setRightBarButtonItem:multitagButton];
}
#pragma mark - Single Share
- (void)shareToFacebook:(id)sender {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"share_facebook"  // Event action (required)
                                                           label:nil         // Event label
                                                           value:nil] build]];    // Event value
    // If the Facebook app is installed and we can present the share dialog
    if([FBDialogs canPresentShareDialogWithPhotos]) {
        FBShareDialogPhotoParams *params = [[FBShareDialogPhotoParams alloc] init];
        params.photos = @[simage];
        
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
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"share_instagram"  // Event action (required)
                                                           label:nil         // Event label
                                                           value:nil] build]];    // Event value
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        // Does user want to use instalikes?
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"instalikesOn"]) {
            [self performSegueWithIdentifier:@"instaShare" sender:self];
        }
        else {
            [self shareToInstaWith:@""];
        }
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

- (void)shareToInstaWith: (NSString *)str
{
    // Setting up hashtags
    NSMutableString *hashtags = [NSMutableString stringWithString:@"Get @StickieApp | #stickiepic ••"];
    NSArray *tags = [[NSArray alloc] initWithArray:[[SKAssetURLTagsMap sharedInstance] getTagsForAssetURL:imageURL]];
    NSMutableString *customtags = [NSMutableString stringWithString:@""];
    for (int i = 0; i < [tags count]; i++) {
        [customtags appendString:@"#"];
        [customtags appendString:[((SKImageTag*)tags[i]) tagName]];
        [customtags appendString:@" "];
    }
    [customtags appendString:str];
    NSString *newString = [NSString stringWithFormat:@"%@\r%@", hashtags,customtags];
    _docFile.delegate=self;
    _docFile.UTI = @"com.instagram.exclusivegram";
    _docFile.annotation=[NSDictionary dictionaryWithObjectsAndKeys:newString,@"InstagramCaption", nil];
    dispatch_sync(loadImageToShare, ^(void){
        [_docFile presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
    });
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
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"share_whatsapp"  // Event action (required)
                                                           label:nil         // Event label
                                                           value:nil] build]];    // Event value
    NSURL *whatsURL = [NSURL URLWithString:@"whatsapp://"];
    if ([[UIApplication sharedApplication] canOpenURL:whatsURL]) {
        UIImage* instaImage = simage; //Top half of image Full Resolution.
        
        NSString* imagePath = [NSString stringWithFormat:@"%@/image.wai", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        [UIImagePNGRepresentation(instaImage) writeToFile:imagePath atomically:YES];
        //    NSLog(@"image size: %@", NSStringFromCGSize(instaImage.size));
        _docFile = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath]];
        _docFile.delegate=self;
        _docFile.UTI = @"net.whatsapp.image";
        dispatch_sync(loadImageToShare, ^(void){
            [_docFile presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
        });
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

- (void)shareToTwitter:(id)sender
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"share_twitter"  // Event action (required)
                                                           label:nil         // Event label
                                                           value:nil] build]];    // Event value
    
    SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    NSMutableString *hashtags = [NSMutableString stringWithString:@"Get @StickieApp (#stickie):"];
    NSArray *tags = [[NSArray alloc] initWithArray:[[SKAssetURLTagsMap sharedInstance] getTagsForAssetURL:imageURL]];
    for (int i = 0; i < [tags count]; i++) {
        [hashtags appendString:@" #"];
        [hashtags appendString:[((SKImageTag*)tags[i]) tagName]];
    }
    
    [composeController setInitialText:hashtags];
    [composeController addImage:simage];
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


#pragma mark - Start
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Tag Search Screen";     // Necessary for Google Analytics
    loadImageToShare = dispatch_queue_create("Load Image", NULL);

    /* Sets titles of buttons. */
    [_topLeftButton setTitle:_topLeftText forState:UIControlStateNormal];
    [_topRightButton setTitle:_topRightText forState:UIControlStateNormal];
    [_botLeftButton setTitle:_botLeftText forState:UIControlStateNormal];
    [_botRightButton setTitle:_botRightText forState:UIControlStateNormal];
    
    /* Initialization stuff. */
    topLeftClicked = NO, topRightClicked = NO, botLeftClicked = NO, botRightClicked = NO;
    _assets = [[NSMutableArray alloc] init];
    library = [[ALAssetsLibrary alloc] init];
    
    selected = [[NSMutableArray alloc] init];

    multiOn = [UIImage imageNamed:@"stickieon.png"];
    multiOff = [UIImage imageNamed:@"stickie.png"];
    
    UILongPressGestureRecognizer *longGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureRecognized:)];
    longGestureRecognizer.minimumPressDuration = 0.15;
    longGestureRecognizer.delegate = self;
    _dNewImageView.userInteractionEnabled = YES;
    [self.collectionView addGestureRecognizer:longGestureRecognizer];
    
    UIButton *multitagView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [multitagView addTarget:self action:@selector(multiToggle:) forControlEvents:UIControlEventTouchUpInside];
    [multitagView setBackgroundImage:[UIImage imageNamed:@"stickie.png"]
                            forState:UIControlStateNormal];
    multitagButton = [[UIBarButtonItem alloc] initWithCustomView:multitagView];
    [self.navigationItem setRightBarButtonItem:multitagButton];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewWillAppear: (BOOL) animation
{
    multi = NO;
    [selected removeAllObjects];
    [self toggleMultiImage];
    /* Pre-populating view according to button selected. */
    if ([_callButtonOnLoad isEqualToString:@"topLeftButton"]) {
        topLeftClicked = YES;
    }
    else if ([_callButtonOnLoad isEqualToString:@"topRightButton"]) {
        topRightClicked = YES;
    }
    else if ([_callButtonOnLoad isEqualToString:@"botLeftButton"]) {
        botLeftClicked = YES;
    }
    else if ([_callButtonOnLoad isEqualToString:@"botRightButton"]) {
        botRightClicked = YES;
    }
    
    [self loadCurrentTag];
}

- (void)loadCurrentTag
{
    if (topLeftClicked) {
        [_topLeftButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    else if (topRightClicked) {
        [_topRightButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    else if (botLeftClicked) {
        [_botLeftButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    else if (botRightClicked) {
        [_botRightButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (IBAction) backMain:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)applicationWillEnterForeground:(NSNotification *) notification
{
    library = [[ALAssetsLibrary alloc] init];
    [self loadCurrentTag];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKPhotoCell *cell = (SKPhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"searchCell" forIndexPath:indexPath];
    
    ALAsset *asset = self.assets[indexPath.row];
    cell.asset = asset;
    cell.selectedAsset = selected;
    
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

-(IBAction)colorButton:(id)sender
{
    int const  TOP_ALIGN = 85;
    /* Reset view. */
    UIImage *topLeftButtonImage = [UIImage imageNamed:@"CircleBlue.png"];
    UIImage *topRightButtonImage = [UIImage imageNamed:@"CircleGreen.png"];
    UIImage *botLeftButtonImage = [UIImage imageNamed:@"CircleRed.png"];
    UIImage *botRightButtonImage = [UIImage imageNamed:@"CircleOrange.png"];
    [_topLeftButton setBackgroundImage:topLeftButtonImage forState:UIControlStateNormal];
    [self.view addSubview:_topLeftButton];
    [_topRightButton setBackgroundImage:topRightButtonImage forState:UIControlStateNormal];
    [self.view addSubview:_topLeftButton];
    [_botLeftButton setBackgroundImage:botLeftButtonImage forState:UIControlStateNormal];
    [self.view addSubview:_topLeftButton];
    [_botRightButton setBackgroundImage:botRightButtonImage forState:UIControlStateNormal];
    [self.view addSubview:_topLeftButton];
    
    CGRect TLButtonFrame = _topLeftButton.frame;
    TLButtonFrame.size = CGSizeMake(65, 65);
    TLButtonFrame.origin = CGPointMake(12,TOP_ALIGN);
    _topLeftButton.frame = TLButtonFrame;
    CGRect  TRButtonFrame = _topRightButton.frame;
    TRButtonFrame.size = CGSizeMake(65, 65);
    TRButtonFrame.origin = CGPointMake(89,TOP_ALIGN);
    _topRightButton.frame = TRButtonFrame;
    CGRect  BLButtonFrame = _botLeftButton.frame;
    BLButtonFrame.size = CGSizeMake(65, 65);
    BLButtonFrame.origin = CGPointMake(167,TOP_ALIGN);
    _botLeftButton.frame = BLButtonFrame;
    CGRect  BRButtonFrame = _botRightButton.frame;
    BRButtonFrame.size = CGSizeMake(65, 65);
    BRButtonFrame.origin = CGPointMake(244,TOP_ALIGN);
    _botRightButton.frame = BRButtonFrame;
    
    
    topLeftClicked = NO, topRightClicked = NO, botLeftClicked = NO, botRightClicked = NO;
    [_assets removeAllObjects];
    [_collectionView reloadData];
    
    BOOL beenClickedBefore;
    
    NSString *buttonPressed = [sender currentTitle];
    currentTag = buttonPressed;
    if ([buttonPressed isEqualToString:_topLeftButton.titleLabel.text]){
        beenClickedBefore = topLeftClicked;
    }
    else if ([buttonPressed isEqualToString:_topRightButton.titleLabel.text]){
        beenClickedBefore = topRightClicked;
    }
    else if ([buttonPressed isEqualToString:_botLeftButton.titleLabel.text]){
        beenClickedBefore = botLeftClicked;
    }
    else{
        beenClickedBefore = botRightClicked;
    }
    
    if (!beenClickedBefore) {
        SKTagCollection *collection = [SKTagCollection sharedInstance];
        SKImageTag *tag = [[SKImageTag alloc] init];
        tag.tagName = buttonPressed;
        
        /* Define a location for equality comparisons (undefined not factored in). */
        tag.tagLocation = SKCornerLocationUndefined;
        
        SKTagData *tagData = [collection getTagInfo:tag];
        NSMutableArray *imageURLs = [tagData imageURLs];
        
        for (NSURL *url in imageURLs) {
            [library assetForURL:url resultBlock:^(ALAsset *myasset) {
                /* Check if asset is still valid */
                if (myasset) {
                    [_assets addObject:myasset];
                    [_collectionView reloadData];
                }
                /* If not valid, update imageURLs - this may not be necessary. */
                else {
                    [imageURLs removeObject:url];
                }
            } failureBlock:^(NSError *myerror) {
                NSLog(@"Cannot access Library Assets");
            }];
        }
        
        if ([buttonPressed isEqualToString:_topLeftButton.titleLabel.text]){
            topLeftButtonImage = [UIImage imageNamed:@"RetrievalBlue.png"];
            TLButtonFrame.size = CGSizeMake(69, 69);
            TLButtonFrame.origin = CGPointMake(10,TOP_ALIGN - 2);
            _topLeftButton.frame = TLButtonFrame;
            [_topLeftButton setBackgroundImage:topLeftButtonImage forState:UIControlStateNormal];
            [self.view addSubview:_topLeftButton];
            topLeftClicked = YES;
            _callButtonOnLoad = _topLeftButton.titleLabel.text;
        }
        else if ([buttonPressed isEqualToString:_topRightButton.titleLabel.text]){
            topRightButtonImage = [UIImage imageNamed:@"RetrievalGreen.png"];
            TRButtonFrame.size = CGSizeMake(69, 69);
            TRButtonFrame.origin = CGPointMake(87,TOP_ALIGN - 2);
            _topRightButton.frame = TRButtonFrame;
            [_topRightButton setBackgroundImage:topRightButtonImage forState:UIControlStateNormal];
            [self.view addSubview:_topRightButton];
            topRightClicked = YES;
            _callButtonOnLoad = _topRightButton.titleLabel.text;
        }
        else if ([buttonPressed isEqualToString:_botLeftButton.titleLabel.text]){
            botLeftButtonImage = [UIImage imageNamed:@"RetrievalRed.png"];
            BLButtonFrame.size = CGSizeMake(69, 69);
            BLButtonFrame.origin = CGPointMake(165,TOP_ALIGN - 2);
            _botLeftButton.frame = BLButtonFrame;
            [_botLeftButton setBackgroundImage:botLeftButtonImage forState:UIControlStateNormal];
            [self.view addSubview:_botLeftButton];
            botLeftClicked = YES;
            _callButtonOnLoad = _botLeftButton.titleLabel.text;
        }
        else if ([buttonPressed isEqualToString:_botRightButton.titleLabel.text]){
            botRightButtonImage = [UIImage imageNamed:@"RetrievalOrange.png"];
            BRButtonFrame.size = CGSizeMake(69, 69);
            BRButtonFrame.origin = CGPointMake(242,TOP_ALIGN - 2);
            _botRightButton.frame = BRButtonFrame;
            [_botRightButton setBackgroundImage:botRightButtonImage forState:UIControlStateNormal];
            [self.view addSubview:_botRightButton];
            botRightClicked = YES;
            _callButtonOnLoad = _topRightButton.titleLabel.text;
        }
    }
}

-(void)longGestureRecognized:(UILongPressGestureRecognizer *)gestureRecognizer{
    int DISTANCE_ABOVE_FINGER = 30;
    int BORDER_SIZE = 1.0;
    int CORNER_RADIUS_CONSTANT = 3.0;
    UIColor *borderColor = [UIColor colorWithRed:166.0/255.0 green:169.0/255.0 blue:172.0/255.0 alpha:1.0];
    
    CGPoint newPoint = [gestureRecognizer locationInView:self.collectionView];
    CGPoint anotherPoint = [self.view convertPoint:newPoint fromView:self.collectionView];
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            dIndexPath = [self.collectionView indexPathForItemAtPoint:newPoint];
            if (dIndexPath == nil){
                NSLog(@"Couldn't find index path");
            }
            else {
                dCell = (SKPhotoCell *)[self.collectionView cellForItemAtIndexPath:dIndexPath];
                if (!multi) {
                    dispatch_async(loadImageToShare, ^{

                    [selected removeAllObjects];
                    [selected addObject:dCell.asset];
                    imageURL = dCell.asset.defaultRepresentation.url;
                    ALAssetRepresentation *defaultRep = [dCell.asset defaultRepresentation];
                    simage = [UIImage imageWithCGImage:[defaultRep fullScreenImage] scale:[defaultRep scale] orientation:0];
                    NSString* imagePath = [NSString stringWithFormat:@"%@/image.igo", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
                    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
                    [UIImagePNGRepresentation(simage) writeToFile:imagePath atomically:YES];

                    _docFile = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath]];
                    });
                }
                dImage = [UIImage imageWithCGImage:[dCell.asset thumbnail]];
                anotherPoint.y -= DISTANCE_ABOVE_FINGER;
                [_dNewImageView setCenter:anotherPoint];
                [_dNewImageView setHidden:NO];
                [_dNewImageView setImage:dImage];
                [self.view bringSubviewToFront:_dNewImageView];
                [self.collectionView removeGestureRecognizer:gestureRecognizer];    // Transferring recognizer to draggable thumbnail.
                [_dNewImageView addGestureRecognizer:gestureRecognizer];
                [_dNewImageView.layer setBorderColor: [borderColor CGColor]];
                [_dNewImageView.layer setBorderWidth: BORDER_SIZE];
                _dNewImageView.layer.cornerRadius = dImage.size.width / CORNER_RADIUS_CONSTANT;
                _dNewImageView.layer.masksToBounds = YES;
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (dIndexPath == nil){
                NSLog(@"Couldn't find index path");
            }
            else {
                anotherPoint.y -= DISTANCE_ABOVE_FINGER;
                [_dNewImageView setCenter:anotherPoint];
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [_dNewImageView setHidden:YES];
            [_dNewImageView setCenter:defaultPoint];
            NSURL *url = [dCell.asset valueForProperty:ALAssetPropertyAssetURL];
            [self recordTags: anotherPoint forURL: url];
            [_dNewImageView removeGestureRecognizer:gestureRecognizer];     // Transferring recongizer back to collection view.
            [self.collectionView addGestureRecognizer:gestureRecognizer];
            break;
        }
        default:
            break;
    }
}

-(void)recordTags: (CGPoint) point forURL: (NSURL *) assetURL {
    int TAG_SENSITIVITY = 30;
    int FRAME_HEIGHT = self.view.frame.size.height;

    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
    SKAssetURLTagsMap *urlToTagMap = [SKAssetURLTagsMap sharedInstance];
    
    SKImageTag *tag;
    //Untag
    if (point.x >= 0 && point.x <= 65 && point.y >= FRAME_HEIGHT - 44 - TAG_SENSITIVITY && point.y <= FRAME_HEIGHT){
        tag = [[SKImageTag alloc] initWithName:currentTag location:SKCornerLocationUndefined andColor:nil];
        if (![tag.tagName isEqualToString:@""]) {
            if (tag && [urlToTagMap doesURL:assetURL haveTag:tag]) {
                if (multi){
                    [urlToTagMap removeTag:tag forMultipleAssets:selected];
                    [tagCollection removeMultipleAssets:selected forTag:tag];
                    multi = NO;
                    [selected removeAllObjects];
                    [self toggleMultiImage];
                }
                else {
                    /* Logic for removing a tag from a new image - it is necessary to update both urlToTagMap and tagCollection. */
                    [urlToTagMap removeTag:tag forAssetURL:assetURL];
                    [tagCollection removeImageURL:assetURL forTag:tag];
                }
                if ([currentTag isEqualToString:_topLeftButton.titleLabel.text]){
                    [_topLeftButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                }
                else if ([currentTag isEqualToString:_topRightButton.titleLabel.text]){
                    [_topRightButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                }
                else if ([currentTag isEqualToString:_botLeftButton.titleLabel.text]){
                    [_botLeftButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                }
                else if ([currentTag isEqualToString:_botRightButton.titleLabel.text]){
                    [_botRightButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                }
            }
        }
    }
    //Share
    if (point.x >= 255 && point.x <= 320 && point.y >= FRAME_HEIGHT - 44 - TAG_SENSITIVITY && point.y <= FRAME_HEIGHT){

            [self setupScrollMenuWithButtons:[self loadButtons]];

    }

}
#pragma mark Segue Handling
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"showTagDetail"] && multi){
        return NO;
    }
    else {
        return YES;
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showTagDetail"])
    {
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        ALAsset *asset = self.assets[indexPath.row];        
        NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
        ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
        UIImage *image = [UIImage imageWithCGImage:[defaultRep fullScreenImage] scale:[defaultRep scale] orientation:0];
        SKDetailViewController *detailViewController = [segue destinationViewController];
        if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
            detailViewController.video = YES;
        }
        detailViewController.image = image;
        detailViewController.imageURL = url;
        detailViewController.assets = _assets;
        detailViewController->imageIndex = (int) indexPath.row;
    }
    /* Enlarge Image. */
    else if ([[segue identifier] isEqualToString:@"instaShare"])
    {
        SKIGShareViewController *instaController = [segue destinationViewController];
        instaController.image = simage;
        instaController.url = imageURL;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    /* Cleanup. */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
