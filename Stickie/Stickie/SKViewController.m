//
//  SKViewController.m
//  Stickie
//
//  Created by Stephen Z on 1/22/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SKPhotoCell.h"
#import "SKDetailViewController.h"
#import "SKAssetURLTagsMap.h"
#import "SKTagCollection.h"
#import "SKImageTag.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SKTagSearchViewController.h"
#import "SKTagAssignViewController.h"
#import "SKLongPressButton.h"


@interface SKViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>
{
    SKPhotoCell *dCell;
    NSIndexPath *dIndexPath;
    UIImage *dImage;
    CGPoint defaultPoint;
    BOOL retainScroll;
}

@property (strong, nonatomic) IBOutlet UIImageView *dNewImageView;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *assets;
@property BOOL newMedia;

@end

@implementation SKViewController

/* Prepare static saved image library */
+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [ALAssetsLibrary new];
    });
    return library;
}

/* Load images at app startup */
- (void)viewDidLoad
{
    [super viewDidLoad];
    _pageImages = @[@"page1.png", @"page2.png", @"page3.png", @"page4.png"];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"wasLaunchedBefore"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wasLaunchedBefore"];
        [self loadTutorial];
    }
    else {
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];

        defaultPoint = CGPointMake(50.0, 0.0);              // Sets default point for draggable ghost image.
        
        [self loadTags];
        [self loadImageAssets];
        
        /* Setting up long-press gesture recognizer and adding it to collectionView and corner buttons */
        UILongPressGestureRecognizer *longGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureRecognized:)];
        longGestureRecognizer.minimumPressDuration = 0.15;
        longGestureRecognizer.delegate = self;
        _dNewImageView.userInteractionEnabled = YES;
        [self.collectionView addGestureRecognizer:longGestureRecognizer];
        [self.topLeftCorner setLongTouchAction:@selector(longPressCornerRecognized:) withTarget:self];
        [self.topRightCorner setLongTouchAction:@selector(longPressCornerRecognized:) withTarget:self];
        [self.botLeftCorner setLongTouchAction:@selector(longPressCornerRecognized:) withTarget:self];
        [self.botRightCorner setLongTouchAction:@selector(longPressCornerRecognized:) withTarget:self];
        
        /* Add observer to main view controller to determine when this specific view enters foreground. */
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
        /* Note, the notification center is intentially left unremoved from this view in viewWillDisappear - for the cases that a photo is deleted when the user is outside this application */
    }
}

- (void) applicationWillEnterForeground:(NSNotification *) notification
{
    /* Reload view so user changes are recognized */
    [self loadImageAssets];
}

#pragma mark - Tutorial Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((SKTutorialViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((SKTutorialViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageImages count]) {
        [((SKTutorialViewController*) viewController).view bringSubviewToFront:((SKTutorialViewController*) viewController).startButton];
    }
    return [self viewControllerAtIndex:index];
}

- (SKTutorialViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageImages count] == 0) || (index >= [self.pageImages count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    SKTutorialViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.pageIndex = index;
    [pageContentViewController.view sendSubviewToBack:pageContentViewController.startButton];

    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageImages count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (void)loadTutorial
{
    self.screenName = @"Tutorial Screen";                   // For Google Analytics.
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    SKTutorialViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}
- (IBAction)tutorialButton:(id)sender {
    [self loadTutorial];
}
#pragma mark - Main Screen
/* Sets name of tags based on serialized tag information. */
- (void)loadTags
{
    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
    NSMutableArray *tagArray = [tagCollection getAllTags];
    
    if (![self tagLocationsAreUnique:tagArray]) {
        [NSException raise:@"Non-unique locations" format:@"User tags found which non-unique locations (excluding SKCornerLocationUndefined"];
    }
    
    /* Reinitialize tags as empty when view loads again, then replace as necessary */
    _topLeftLabel.text = @"";
    _topRightLabel.text = @"";
    _botLeftLabel.text = @"";
    _botRightLabel.text = @"";
    
    /* Initialize array of location options for the case a tag has location SKCornerLocationUndefined, which is used for dummy tags and loading the view. */
    NSMutableArray *locationOptions = [[NSMutableArray alloc] init];
    [locationOptions addObject: [NSNumber numberWithInt:SKCornerLocationTopLeft]];
    [locationOptions addObject: [NSNumber numberWithInt:SKCornerLocationTopRight]];
    [locationOptions addObject: [NSNumber numberWithInt:SKCornerLocationBottomLeft]];
    [locationOptions addObject: [NSNumber numberWithInt:SKCornerLocationBottomRight]];
    
    for (SKImageTag* tag in tagArray) {
        /* Place tags according to their locations. */
        if (tag.tagLocation == SKCornerLocationTopLeft) {
            _topLeftLabel.text = tag.tagName;
        }
        else if (tag.tagLocation == SKCornerLocationTopRight) {
            _topRightLabel.text = tag.tagName;
        }
        else if (tag.tagLocation == SKCornerLocationBottomLeft) {
            _botLeftLabel.text = tag.tagName;
        }
        else if (tag.tagLocation == SKCornerLocationBottomRight) {
            _botRightLabel.text = tag.tagName;
        }
        /* Account for SKCornerLocation undefined. */
        else {
            NSInteger cornerToAddLabel = [locationOptions[0] integerValue];
            
            if (cornerToAddLabel == SKCornerLocationTopLeft) {
                _topLeftLabel.text = ((SKImageTag *) tagArray[0]).tagName;
            }
            else if (cornerToAddLabel == SKCornerLocationTopRight) {
                _topRightLabel.text = ((SKImageTag *) tagArray[1]).tagName;
            }
            else if (cornerToAddLabel == SKCornerLocationBottomLeft) {
                _botLeftLabel.text = ((SKImageTag *) tagArray[2]).tagName;
            }
            else if (cornerToAddLabel == SKCornerLocationBottomRight) {
                _botRightLabel.text = ((SKImageTag *) tagArray[3]).tagName;
            }
            [locationOptions removeObjectAtIndex:0];    // Updated location options.
        }
        
        /* Update location options. */
        if (tag.tagLocation != SKCornerLocationUndefined) {
            [locationOptions removeObject:[NSNumber numberWithInt:tag.tagLocation]];
        }
    }
}

/* Returns NO if tagArray has SKImageTag objects with non-unique tagLocations (excluding SKCornerLocationUndefined) and YES otherwise. */
- (BOOL) tagLocationsAreUnique: (NSMutableArray *) tagArray
{
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    for (SKImageTag* tag in tagArray) {
        if ([locations containsObject:[NSNumber numberWithInt:tag.tagLocation]] && tag.tagLocation != SKCornerLocationUndefined) {
            return NO;
        }
        [locations addObject: [NSNumber numberWithInt:tag.tagLocation]];
    }
    return YES;
}

/* Enumerates through all user ALAssets and collects them in _assets. */
- (void)loadImageAssets
{
    _assets = [@[] mutableCopy];
    __block NSMutableArray *tmpAssets = [@[] mutableCopy];
    
    ALAssetsLibrary *assetsLibrary = [SKViewController defaultAssetsLibrary];
    
    [assetsLibrary enumerateGroupsWithTypes:(ALAssetsGroupSavedPhotos | ALAssetsGroupAlbum | ALAssetsGroupLibrary)usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result) {
                [tmpAssets addObject:result];
            }
        }];
        
        self.assets = tmpAssets;
        
        [self.collectionView reloadData];
    } failureBlock:^(NSError *error) {
        NSLog(@"Error loading images %@", error);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    /* Automatically scrolls to bottom of collection view so user will see most recent photos. */
    if (!retainScroll) {
        NSInteger section = 0;
        NSInteger item = [self collectionView:_collectionView numberOfItemsInSection:section] - 1;
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        retainScroll = YES;
        if (item > -1) {
            [_collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        }
    }
    else {
       [self loadImageAssets]; 
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

/* Load images into cells. */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKPhotoCell *cell = (SKPhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    ALAsset *asset = self.assets[indexPath.row];

    cell.asset = asset;
    
    cell.topLeftCorner = _topLeftLabel.text;
    cell.topRightCorner = _topRightLabel.text;
    cell.botLeftCorner = _botLeftLabel.text;
    cell.botRightCorner = _botRightLabel.text;
    
    return cell;
}

/* Adjust image spacing. */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

- (void)longGestureRecognized:(UILongPressGestureRecognizer *)gestureRecognizer{
    int DISTANCE_ABOVE_FINGER = 30;
    int BORDER_SIZE = 1.0;
    int CORNER_RADIUS = 3.0;
    UIColor *borderColor = [UIColor colorWithRed:166.0/255.0 green:169.0/255.0 blue:172.0/255.0 alpha:1.0];
    
    CGPoint newPoint = [gestureRecognizer locationInView:self.collectionView];
    CGPoint anotherPoint = [self.view convertPoint:newPoint fromView:self.collectionView];
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            dIndexPath = [self.collectionView indexPathForItemAtPoint:newPoint];
            if (dIndexPath == nil){
                NSLog(@"Couldn't find index path.");
            }
            /* Loading data into draggable thumbnail image. */
            else {
                dCell = (SKPhotoCell *)[self.collectionView cellForItemAtIndexPath:dIndexPath];
                dImage = [UIImage imageWithCGImage:[dCell.asset thumbnail]];
                [dCell.asset valueForProperty:ALAssetPropertyURLs];
                anotherPoint.y -= DISTANCE_ABOVE_FINGER;
                [_dNewImageView setCenter:anotherPoint];
                [_dNewImageView setImage:dImage];
                [self.collectionView removeGestureRecognizer:gestureRecognizer];    // Transferring gesture recognizer to draggable thumbnail image.
                [_dNewImageView addGestureRecognizer:gestureRecognizer];
                [_dNewImageView.layer setBorderColor: [borderColor CGColor]];
                [_dNewImageView.layer setBorderWidth: BORDER_SIZE];
                _dNewImageView.layer.cornerRadius = dImage.size.width / CORNER_RADIUS;
                _dNewImageView.layer.masksToBounds = YES;
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (dIndexPath == nil){
                NSLog(@"Couldn't find index path.");
            }
            else {
                anotherPoint.y -= DISTANCE_ABOVE_FINGER;
                [_dNewImageView setCenter:anotherPoint];
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (dIndexPath == nil){
                NSLog(@"Couldn't find index path.");
            }
            else {
                _dNewImageView.image = nil;
                [_dNewImageView setCenter:defaultPoint];
                NSURL *url = [dCell.asset valueForProperty:ALAssetPropertyAssetURL];
                [self recordTags: anotherPoint forURL: url];
                [_dNewImageView removeGestureRecognizer:gestureRecognizer];     // Transferring gesture recognizer back to collection view.
                [self.collectionView addGestureRecognizer:gestureRecognizer];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark Edit Tag
- (void)longPressCornerRecognized:(UILongPressGestureRecognizer *) gestureRecognizer{
    CGPoint point = [gestureRecognizer locationInView:self.view];
    if (point.x >= 0 && point.x <= 65 && point.y >= 63 && point.y <= 128)
        [self performSegueWithIdentifier:@"topLeftTagEdit" sender:self];
    
    else if (point.x >= 255 && point.x <= 320 && point.y >= 63 && point.y <= 128)
       [self performSegueWithIdentifier:@"topRightTagEdit" sender:self];
    
    else if (point.x >= 0 && point.x <= 65 && point.y >= 503 && point.y <= 568)
        [self performSegueWithIdentifier:@"botLeftTagEdit" sender:self];
    
    else if (point.x >= 255 && point.x <= 320 && point.y >= 503 && point.y <= 568)
        [self performSegueWithIdentifier:@"botRightTagEdit" sender:self];
}

#pragma mark Drag and Drop Tagging
- (void)recordTags: (CGPoint) point forURL: (NSURL *) assetURL {
    
    /* Constants to define how close thumbnail must be to a given corner in order for a tag to register */
    int TAG_SENSITIVITY_X = dImage.size.width/5.0;
    int TAG_SENSITITVITY_Y = dImage.size.height/5.0;
    
    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
    SKAssetURLTagsMap *urlToTagMap = [SKAssetURLTagsMap sharedInstance];
    SKImageTag *tag;
    UIButton *button;
    
    UIAlertView *alertEmptyTag = [[UIAlertView alloc] initWithTitle:@"The tag is unlabeled."
                                                          message:@"Tap on the corner to create tag."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    
    /* Tag event occurs in top-left corner */
    if (point.x >= 0 && point.x <= 65 + TAG_SENSITIVITY_X * 1.5 && point.y >= 63 && point.y <= 128 + TAG_SENSITITVITY_Y * 1.5) {
        tag = [[SKImageTag alloc] initWithName:_topLeftLabel.text location:SKCornerLocationTopLeft andColor:nil];
        button = _topLeftCorner;
    }
    else if (point.x >= 255 - TAG_SENSITIVITY_X * 1.5 && point.x <= 320 && point.y >= 63 && point.y <= 128 + TAG_SENSITITVITY_Y * 1.5) {
        tag = [[SKImageTag alloc] initWithName:_topRightLabel.text location:SKCornerLocationTopRight andColor:nil];
        button = _topRightCorner;
    }
    else if (point.x >= 0 && point.x <= 65 + TAG_SENSITIVITY_X && point.y >= 503 - TAG_SENSITITVITY_Y && point.y <= 568) {
        tag = [[SKImageTag alloc] initWithName:_botLeftLabel.text location:SKCornerLocationBottomLeft andColor:nil];
        button = _botLeftCorner;
    }
    else if (point.x >= 255 - TAG_SENSITIVITY_X && point.x <= 320 && point.y >= 503 - TAG_SENSITITVITY_Y && point.y <= 568) {
        tag = [[SKImageTag alloc] initWithName:_botRightLabel.text location:SKCornerLocationBottomRight andColor:nil];
        button = _botRightCorner;
    }
    
    if (![tag.tagName isEqualToString:@""]) {
        if (tag && ![urlToTagMap doesURL:assetURL haveTag:tag]) {
            [UIView animateWithDuration:0.1 animations:^{
                button.alpha = 0.0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.9 animations:^{
                    button.alpha = 1.0;
                } completion:^(BOOL finished) {
                    // Cleanup stuff.
                }];
            }];
            
            /* Logic for tagging a new image - it is necessary to update both urlToTagMap and tagCollection. */
            [urlToTagMap addTag: tag forAssetURL:assetURL];
            [tagCollection updateCollectionWithTag: tag forImageURL:assetURL];
        }
        else if (tag && [urlToTagMap doesURL:assetURL haveTag:tag]) {
            [UIView animateWithDuration:0.1 animations:^{
                button.alpha = 0.0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.9 animations:^{
                    button.alpha = 1.0;
                } completion:^(BOOL finished) {
                    // Cleanup stuff.
                }];
            }];
            /* Logic for removing a tag from a new image - it is necessary to update both urlToTagMap and tagCollection. */
            [urlToTagMap removeTag:tag forAssetURL:assetURL];
            [tagCollection removeImageURL:assetURL forTag:tag];
        }
        [self loadImageAssets];
    }
    else {
        [alertEmptyTag show];
    }
}

#pragma make Camera Methods
/* Take photo. */
- (IBAction)takePhotoButtonTapped:(id)sender {
    [self performSelector:@selector(useCamera) withObject:nil afterDelay:0.3];
}

/* Setup for image picker. */
- (void)useCamera{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
        _newMedia = YES;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        if (_newMedia){
            retainScroll = NO;
            UIImageWriteToSavedPhotosAlbum(image,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
        }
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
}

- (void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    [self performSelector:@selector(reloadCollectionView) withObject:nil afterDelay:0.3];
}

/* Reloads collection view. */
- (void)reloadCollectionView{
    [self loadImageAssets];
    [_collectionView reloadData];
}

#pragma mark Segue Handling
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([_topLeftLabel.text isEqualToString:@""] && [identifier isEqualToString:@"topLeftTag"]) {
        [self performSegueWithIdentifier:@"topLeftTagEdit" sender:self];
        return NO;
    }
    else if ([_topRightLabel.text isEqualToString:@""] && [identifier isEqualToString:@"topRightTag"]){
        [self performSegueWithIdentifier:@"topRightTagEdit" sender:self];
        return NO;
    }
    else if ([_botLeftLabel.text isEqualToString:@""] && [identifier isEqualToString:@"botLeftTag"]){
        [self performSegueWithIdentifier:@"botLeftTagEdit" sender:self];
        return NO;
    }
    else if ([_botRightLabel.text isEqualToString:@""] && [identifier isEqualToString:@"botRightTag"]){
        [self performSegueWithIdentifier:@"botRightTagEdit" sender:self];
        return NO;
    }
    else {
        return YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /* Enlarge Image. */
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        ALAsset *asset = self.assets[indexPath.row];
        NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
        ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
        UIImage *image = [UIImage imageWithCGImage:[defaultRep fullScreenImage] scale:[defaultRep scale] orientation:0];
        SKDetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.image = image;
        detailViewController.imageURL = url;
        detailViewController.assets = _assets;
        detailViewController->imageIndex = (int) indexPath.row;
    }
    
    /* Routes to tag search view. */
    else if ([[segue identifier] isEqualToString:@"tagSearch"])
    {
        SKTagSearchViewController *tagSearchViewController = [segue destinationViewController];
        [self assignTagText:tagSearchViewController];
    }
    
    /* Prepopulates selected tag in tag search view. */
    else if ([[segue identifier] isEqualToString:@"topLeftTag"]){
        SKTagSearchViewController *tagSearchViewController = [segue destinationViewController];
        [self assignTagText:tagSearchViewController];
        tagSearchViewController.callButtonOnLoad = @"topLeftButton";
    }
    else if ([[segue identifier] isEqualToString:@"topRightTag"]){
        SKTagSearchViewController *tagSearchViewController = [segue destinationViewController];
        [self assignTagText:tagSearchViewController];
        tagSearchViewController.callButtonOnLoad = @"topRightButton";
    }
    else if ([[segue identifier] isEqualToString:@"botLeftTag"]){
        SKTagSearchViewController *tagSearchViewController = [segue destinationViewController];
        [self assignTagText:tagSearchViewController];
        tagSearchViewController.callButtonOnLoad = @"botLeftButton";
    }
    else if ([[segue identifier] isEqualToString:@"botRightTag"]){
        SKTagSearchViewController *tagSearchViewController = [segue destinationViewController];
        [self assignTagText:tagSearchViewController];
        tagSearchViewController.callButtonOnLoad = @"botRightButton";
    }
    
    /* For tag editing. */
    else if ([[segue identifier] isEqualToString:@"topLeftTagEdit"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SKTagAssignViewController *tagAssignViewController = [navigationController viewControllers][0];
        if ([_topLeftLabel.text isEqualToString:@""]) {
            tagAssignViewController.createTag = YES;
        }
        tagAssignViewController.location = SKCornerLocationTopLeft;
        tagAssignViewController.delegate = self;
        tagAssignViewController.preLabel = _topLeftLabel.text;

    }
    else if ([[segue identifier] isEqualToString:@"topRightTagEdit"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SKTagAssignViewController *tagAssignViewController = [navigationController viewControllers][0];
        if ([_topRightLabel.text isEqualToString:@""]) {
            tagAssignViewController.createTag = YES;
        }
        tagAssignViewController.location = SKCornerLocationTopRight;
        tagAssignViewController.delegate = self;
        tagAssignViewController.preLabel = _topRightLabel.text;

        
    }
    else if ([[segue identifier] isEqualToString:@"botLeftTagEdit"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SKTagAssignViewController *tagAssignViewController = [navigationController viewControllers][0];
        if ([_botLeftLabel.text isEqualToString:@""]) {
            tagAssignViewController.createTag = YES;
        }
        tagAssignViewController.location = SKCornerLocationBottomLeft;
        tagAssignViewController.delegate = self;
        tagAssignViewController.preLabel = _botLeftLabel.text;

    }
    else if ([[segue identifier] isEqualToString:@"botRightTagEdit"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SKTagAssignViewController *tagAssignViewController = [navigationController viewControllers][0];
        if ([_botRightLabel.text isEqualToString:@""]) {
            tagAssignViewController.createTag = YES;
        }
        tagAssignViewController.location = SKCornerLocationBottomRight;
        tagAssignViewController.delegate = self;
        tagAssignViewController.preLabel = _botRightLabel.text;

    }
}

/* Assigns label to corner. */
- (void)assignTagText: (SKTagSearchViewController *) tagSearchViewController
{
    tagSearchViewController.topLeftText = _topLeftLabel.text;
    tagSearchViewController.topRightText = _topRightLabel.text;
    tagSearchViewController.botLeftText = _botLeftLabel.text;
    tagSearchViewController.botRightText = _botRightLabel.text;
}

#pragma mark Tag Assign Delegate Methods
- (void)tagAssignViewControllerDidCancel:(SKTagAssignViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/* Edit or delete tags from SKTagAssignViewController. */
- (void)tagAssignViewController:(SKTagAssignViewController *)controller didAddTag:(NSString *)tagSTR forLocation:(SKCornerLocation) cornerLocation andDelete:(BOOL)delete
{
    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
    SKImageTag *tag = [[SKImageTag alloc] initWithName:tagSTR location:cornerLocation andColor:nil];
    SKImageTag *oldTag =[SKImageTag alloc];
    SKAssetURLTagsMap *urlTagsMap = [SKAssetURLTagsMap sharedInstance];
    
    if (![tagCollection isTagInCollection:tag]) {
        if (![tag.tagName isEqualToString:@""]){
            [tagCollection addTagToCollection:tag];
        }
        if (cornerLocation == SKCornerLocationTopLeft) {
            oldTag = [oldTag initWithName:_topLeftLabel.text location:cornerLocation andColor:nil];
            if (!delete) {
                [urlTagsMap transferURLSFrom:oldTag to:tag];
            }
            [urlTagsMap removeAllMappingsToTag:oldTag];
            [tagCollection removeTag:oldTag];
            _topLeftLabel.text = tagSTR;
        }
        else if (cornerLocation == SKCornerLocationTopRight) {
            oldTag = [oldTag initWithName:_topRightLabel.text location:cornerLocation andColor:nil];
            if (!delete) {
                [urlTagsMap transferURLSFrom:oldTag to:tag];
            }
            [urlTagsMap removeAllMappingsToTag:oldTag];
            [tagCollection removeTag: oldTag];
            _topRightLabel.text = tagSTR;
        }
        else if (cornerLocation == SKCornerLocationBottomLeft) {
            oldTag = [oldTag initWithName:_botLeftLabel.text location:cornerLocation andColor:nil];
            if (!delete) {
                [urlTagsMap transferURLSFrom:oldTag to:tag];
            }
            [urlTagsMap removeAllMappingsToTag:oldTag];
            [tagCollection removeTag:oldTag];
            _botLeftLabel.text = tagSTR;
        }
        else if (cornerLocation == SKCornerLocationBottomRight) {
            oldTag = [oldTag initWithName:_botRightLabel.text location:cornerLocation andColor:nil];
            if (!delete) {
                [urlTagsMap transferURLSFrom:oldTag to:tag];
            }
            [urlTagsMap removeAllMappingsToTag:oldTag];
            [tagCollection removeTag:oldTag];
            _botRightLabel.text = tagSTR;
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @" Tag already in collection."
                              message: nil
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
