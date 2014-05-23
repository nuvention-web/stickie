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
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "SWRevealViewController.h"


@interface SKViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>
{
    SKPhotoCell *dCell;
    NSIndexPath *dIndexPath;
    UIImage *dImage;
    CGPoint defaultPoint;
    BOOL retainScroll;
    BOOL close;
    NSURL *currentURL;
    BOOL multi;
    NSMutableArray *selected;
    UIBarButtonItem *cameraButton;
    UIBarButtonItem *multitagButton;
    UIImage *multiOn;
    UIImage *multiOff;
}

@property (strong, nonatomic) IBOutlet UIImageView *dNewImageView;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *assets;
@property BOOL newMedia;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;

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
    _pageImages = @[@"page1.png", @"page2.png", @"page3.png", @"page4.png", @"page5.png"];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"wasLaunchedBefore"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wasLaunchedBefore"];
        close = YES;
        [self loadTutorial];
        [self viewDidAppear:NO];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"instalikesOn"]; // DEFAULT SETTINGS
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"photostreamOn"];
    }
    else {
        close = NO;
        self.screenName = @"Home Screen";                   // For Google Analytics.
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];

        multiOn = [UIImage imageNamed:@"stickieon.png"];        
        multiOff = [UIImage imageNamed:@"stickie.png"];
        
        defaultPoint = CGPointMake(50.0, 0.0);              // Sets default point for draggable ghost image.
        
        [self loadTags];
        [self loadImageAssets];
        selected = [[NSMutableArray alloc] init];
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
        
        // Necessary for SWRevealViewController - Menu View.
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
        
        UIButton *multitagView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [multitagView addTarget:self action:@selector(multiToggle:) forControlEvents:UIControlEventTouchUpInside];
        [multitagView setBackgroundImage:[UIImage imageNamed:@"stickie.png"]
 forState:UIControlStateNormal];
        multitagButton = [[UIBarButtonItem alloc] initWithCustomView:multitagView];
        
        UIButton *cameraView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 34, 28)];
        [cameraView addTarget:self action:@selector(useCamera) forControlEvents:UIControlEventTouchUpInside];
        [cameraView setBackgroundImage:[UIImage imageNamed:@"camera.png"]
                                forState:UIControlStateNormal];
        cameraButton = [[UIBarButtonItem alloc] initWithCustomView:cameraView];
        
        UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburger.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleMenu)];
//        UIBarButtonItem *multitagButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Stickielogo.png"] style:UIBarButtonItemStylePlain target:self action:@selector(multiToggle:)];
//        UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@""] style:UIBarButtonItemStylePlain target:self action:@selector(useCamera)];
        [self.navigationItem setLeftBarButtonItem:menuButton];
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:cameraButton, multitagButton,  nil]];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    // Necessary for SWRevealViewController - Menu View.
    [self.navigationController.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void) applicationWillEnterForeground:(NSNotification *) notification
{
    /* Reload view so user changes are recognized */
    [self loadImageAssets];
}

- (void)toggleMenu
{
    [self.revealViewController revealToggleAnimated:YES];
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
    if (close) {
        [pageContentViewController.view sendSubviewToBack:pageContentViewController.closeButton];
    }

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
    multi = NO;
    [selected removeAllObjects];
    [self toggleMultiImage];
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
    cell.selectedAsset = selected;
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
    int CORNER_RADIUS = 157.0/3.0;
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
                if (multi && [selected count] > 1){
                    CGImageRef leftRef;
                    CGImageRef rightRef;
                    CGImageRef topRightRef;
                    CGImageRef botRightRef;
                    CGImageRef topLeftRef;
                    CGImageRef botLeftRef;
                    switch ([selected count]) {
                        case 2:
                            UIGraphicsBeginImageContext(_dNewImageView.frame.size);
                            leftRef = CGImageCreateWithImageInRect([selected[0] thumbnail], CGRectMake(0,0,_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height));
                            rightRef = CGImageCreateWithImageInRect([selected[1] thumbnail], CGRectMake(_dNewImageView.frame.size.width/2,0,_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height));
                            [[UIImage imageWithCGImage:leftRef] drawInRect:CGRectMake(0,0,_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height)];
                            [[UIImage imageWithCGImage:rightRef] drawInRect:CGRectMake(_dNewImageView.frame.size.width/2,0,_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height)];
                            break;
                        case 3:
                            UIGraphicsBeginImageContext(_dNewImageView.frame.size);
                            leftRef = CGImageCreateWithImageInRect([selected[0] thumbnail], CGRectMake(0,0,_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height));
                            topRightRef = CGImageCreateWithImageInRect([selected[1] thumbnail], CGRectMake(_dNewImageView.frame.size.width/2,0,_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height/2));
                            botRightRef = CGImageCreateWithImageInRect([selected[2] thumbnail], CGRectMake(_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height/2,_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height/2));
                            [[UIImage imageWithCGImage:leftRef] drawInRect:CGRectMake(0,0,_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height)];
                            [[UIImage imageWithCGImage:topRightRef] drawInRect:CGRectMake(_dNewImageView.frame.size.width/2,0,_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height/2)];
                            [[UIImage imageWithCGImage:botRightRef] drawInRect:CGRectMake(_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height/2,_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height/2)];
                            break;
                        default:
                            UIGraphicsBeginImageContext(_dNewImageView.frame.size);
                            topLeftRef = CGImageCreateWithImageInRect([selected[0] thumbnail], CGRectMake(0,0,_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height/2));
                            topRightRef = CGImageCreateWithImageInRect([selected[1] thumbnail], CGRectMake(_dNewImageView.frame.size.width/2,0,_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height/2));
                            botLeftRef = CGImageCreateWithImageInRect([selected[2] thumbnail], CGRectMake(0,_dNewImageView.frame.size.height/2,_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height/2));
                            botRightRef = CGImageCreateWithImageInRect([selected[3] thumbnail], CGRectMake(_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height/2,_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height/2));
                            [[UIImage imageWithCGImage:topLeftRef] drawInRect:CGRectMake(0,0,_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height/2)];
                            [[UIImage imageWithCGImage:topRightRef] drawInRect:CGRectMake(_dNewImageView.frame.size.width/2,0,_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height/2)];
                            [[UIImage imageWithCGImage:botLeftRef] drawInRect:CGRectMake(0,_dNewImageView.frame.size.height/2,_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height/2)];
                            [[UIImage imageWithCGImage:botRightRef] drawInRect:CGRectMake(_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height/2,_dNewImageView.frame.size.width/2,_dNewImageView.frame.size.height/2)];
                            break;
                    }
                    dImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                else {
                    dCell = (SKPhotoCell *)[self.collectionView cellForItemAtIndexPath:dIndexPath];
                    dImage = [UIImage imageWithCGImage:[dCell.asset thumbnail]];
                }
                anotherPoint.y -= DISTANCE_ABOVE_FINGER;
                [_dNewImageView setCenter:anotherPoint];
                [_dNewImageView setHidden:NO];
                [_dNewImageView setImage:dImage];
                [self.collectionView removeGestureRecognizer:gestureRecognizer];    // Transferring gesture recognizer to draggable thumbnail image.
                [_dNewImageView addGestureRecognizer:gestureRecognizer];
                [_dNewImageView.layer setBorderColor: [borderColor CGColor]];
                [_dNewImageView.layer setBorderWidth: BORDER_SIZE];
                _dNewImageView.layer.cornerRadius = CORNER_RADIUS;
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
                [_dNewImageView setCenter:defaultPoint];
                [_dNewImageView setHidden:YES];
                NSURL *url = [dCell.asset valueForProperty:ALAssetPropertyAssetURL];
                [self recordTags: anotherPoint forURL: url andIndexPath: dIndexPath];
                [_dNewImageView removeGestureRecognizer:gestureRecognizer];     // Transferring gesture recognizer back to collection view.
                [self.collectionView addGestureRecognizer:gestureRecognizer];
            }
            break;
        }
        default:
            break;
    }
}
#pragma mark - Multi Select

- (void)multiToggle:(id)sender {
    if (multi) {
        multi = NO;
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
    if (multi) {
        ALAsset *asset = self.assets[indexPath.row];
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
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:cameraButton, multitagButton,  nil]];
}
#pragma mark Edit Tag
- (void)longPressCornerRecognized:(UILongPressGestureRecognizer *) gestureRecognizer{
    CGPoint point = [gestureRecognizer locationInView:self.view];
    int FRAME_HEIGHT = self.view.frame.size.height;
    if (point.x >= 0 && point.x <= 65 && point.y >= 63 && point.y <= 128)
        [self performSegueWithIdentifier:@"topLeftTagEdit" sender:self];
    
    else if (point.x >= 255 && point.x <= 320 && point.y >= 63 && point.y <= 128)
       [self performSegueWithIdentifier:@"topRightTagEdit" sender:self];
    
    else if (point.x >= 0 && point.x <= 65 && point.y >= FRAME_HEIGHT - 65  && point.y <= FRAME_HEIGHT)
        [self performSegueWithIdentifier:@"botLeftTagEdit" sender:self];
    
    else if (point.x >= 255 && point.x <= 320 && point.y >= FRAME_HEIGHT - 65  && point.y <= FRAME_HEIGHT)
        [self performSegueWithIdentifier:@"botRightTagEdit" sender:self];
}

#pragma mark Drag and Drop Tagging
- (void)recordTags: (CGPoint) point forURL: (NSURL *) assetURL andIndexPath: (NSIndexPath *) path {
    
    /* Constants to define how close thumbnail must be to a given corner in order for a tag to register */
    int TAG_SENSITIVITY_X = dImage.size.width/5.0;
    int TAG_SENSITITVITY_Y = dImage.size.height/5.0;
    int FRAME_HEIGHT = self.view.frame.size.height;
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
    SKAssetURLTagsMap *urlToTagMap = [SKAssetURLTagsMap sharedInstance];
    SKImageTag *tag;
    UIButton *button;
    NSInteger currentTag;

    
    /* Tag event occurs in top-left corner */
    if (point.x >= 0 && point.x <= 65 + TAG_SENSITIVITY_X * 1.5 && point.y >= 63 && point.y <= 128 + TAG_SENSITITVITY_Y * 1.5) {
        tag = [[SKImageTag alloc] initWithName:_topLeftLabel.text location:SKCornerLocationTopLeft andColor:nil];
        button = _topLeftCorner;
        currentTag = 1;
    }
    /* Tag event occurs in top-right corner */
    else if (point.x >= 255 - TAG_SENSITIVITY_X * 1.5 && point.x <= 320 && point.y >= 63 && point.y <= 128 + TAG_SENSITITVITY_Y * 1.5) {
        tag = [[SKImageTag alloc] initWithName:_topRightLabel.text location:SKCornerLocationTopRight andColor:nil];
        button = _topRightCorner;
        currentTag = 2;
    }
    /* Tag event occurs in bot-left corner */
    else if (point.x >= 0 && point.x <= 65 + TAG_SENSITIVITY_X && point.y >= FRAME_HEIGHT - 65 - TAG_SENSITITVITY_Y && point.y <= FRAME_HEIGHT) {
        tag = [[SKImageTag alloc] initWithName:_botLeftLabel.text location:SKCornerLocationBottomLeft andColor:nil];
        button = _botLeftCorner;
        currentTag = 3;
        
    }
    /* Tag event occurs in bot-right corner */
    else if (point.x >= 255 - TAG_SENSITIVITY_X && point.x <= 320 && point.y >= FRAME_HEIGHT - 65 - TAG_SENSITITVITY_Y && point.y <= FRAME_HEIGHT) {
        tag = [[SKImageTag alloc] initWithName:_botRightLabel.text location:SKCornerLocationBottomRight andColor:nil];
        button = _botRightCorner;
        currentTag = 4;
    }

    
    if (![tag.tagName isEqualToString:@""]) {
        if (tag && ![urlToTagMap doesURL:assetURL haveTag:tag]) {
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"image_tag"  // Event action (required)
                                                                   label:nil         // Event label
                                                                   value:nil] build]];    // Event value
            [UIView animateWithDuration:0.1 animations:^{
                button.alpha = 0.0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.9 animations:^{
                    button.alpha = 1.0;
                } completion:^(BOOL finished) {
                    // Cleanup stuff.
                }];
            }];
            if (multi){
                [urlToTagMap addTag:tag forMultipleAssets:selected];
                [tagCollection updateCollectionWithTag:tag forMultipleAssets:selected];
                multi = NO;
                [selected removeAllObjects];
                [self toggleMultiImage];
            }
            else {
            /* Logic for tagging a new image - it is necessary to update both urlToTagMap and tagCollection. */
                [urlToTagMap addTag: tag forAssetURL:assetURL];
                [tagCollection updateCollectionWithTag: tag forImageURL:assetURL];
            }
        }
        else if (tag && [urlToTagMap doesURL:assetURL haveTag:tag]) {
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"image_untag"  // Event action (required)
                                                                   label:nil         // Event label
                                                                   value:nil] build]];    // Event value
            [UIView animateWithDuration:0.1 animations:^{
                button.alpha = 0.0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.9 animations:^{
                    button.alpha = 1.0;
                } completion:^(BOOL finished) {
                    // Cleanup stuff.
                }];
            }];
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
        }
//            [_collectionView reloadItemsAtIndexPaths: [[NSArray alloc] initWithObjects:path, nil]]; // DOES NOT WORK FOR FIRST TAG (APPLE BUG?).
        [_collectionView reloadData];
    }
    else {
        currentURL = assetURL;
        switch (currentTag) {
            case 1:
                [self performSegueWithIdentifier:@"topLeftTagEdit" sender:self];
                break;
            case 2:
                [self performSegueWithIdentifier:@"topRightTagEdit" sender:self];
                break;
            case 3:
                [self performSegueWithIdentifier:@"botLeftTagEdit" sender:self];
                break;
            case 4:
                [self performSegueWithIdentifier:@"botRightTagEdit" sender:self];
                break;
            default:
                break;
        }
    }
}

#pragma mark Camera Methods
/* Take photo. */
//- (IBAction)takePhotoButtonTapped:(id)sender {
//    [self performSelector:@selector(useCamera) withObject:nil afterDelay:0.3];
//}

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
    if ([identifier isEqualToString:@"showDetail"] && multi){
        return NO;
    }
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
                tagAssignViewController.tagImageURL = currentURL;
                tagAssignViewController.assets = selected;
        }
        currentURL = nil;
        tagAssignViewController.location = SKCornerLocationTopLeft;
        tagAssignViewController.delegate = self;
        tagAssignViewController.preLabel = _topLeftLabel.text;

    }
    else if ([[segue identifier] isEqualToString:@"topRightTagEdit"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SKTagAssignViewController *tagAssignViewController = [navigationController viewControllers][0];
        if ([_topRightLabel.text isEqualToString:@""]) {
            tagAssignViewController.createTag = YES;
            tagAssignViewController.tagImageURL = currentURL;
            tagAssignViewController.assets = selected;
        }
        currentURL = nil;
        tagAssignViewController.location = SKCornerLocationTopRight;
        tagAssignViewController.delegate = self;
        tagAssignViewController.preLabel = _topRightLabel.text;

        
    }
    else if ([[segue identifier] isEqualToString:@"botLeftTagEdit"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SKTagAssignViewController *tagAssignViewController = [navigationController viewControllers][0];
        if ([_botLeftLabel.text isEqualToString:@""]) {
            tagAssignViewController.createTag = YES;
            tagAssignViewController.tagImageURL = currentURL;
            tagAssignViewController.assets = selected;
        }
        currentURL = nil;
        tagAssignViewController.location = SKCornerLocationBottomLeft;
        tagAssignViewController.delegate = self;
        tagAssignViewController.preLabel = _botLeftLabel.text;

    }
    else if ([[segue identifier] isEqualToString:@"botRightTagEdit"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SKTagAssignViewController *tagAssignViewController = [navigationController viewControllers][0];
        if ([_botRightLabel.text isEqualToString:@""]) {
            tagAssignViewController.createTag = YES;
            tagAssignViewController.tagImageURL = currentURL;
            tagAssignViewController.assets = selected;
        }
        currentURL = nil;
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
- (void)tagAssignViewController:(SKTagAssignViewController *)controller didAddTag:(NSString *)tagSTR forLocation:(SKCornerLocation) cornerLocation andDelete:(BOOL)delete andDidTagImageURL:(NSURL *)assetURL forAssets:(NSArray *)assets
{
    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
    SKImageTag *tag = [[SKImageTag alloc] initWithName:tagSTR location:cornerLocation andColor:nil];
    SKImageTag *oldTag =[SKImageTag alloc];
    SKAssetURLTagsMap *urlTagsMap = [SKAssetURLTagsMap sharedInstance];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
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
        if ([assets count] > 0 && ![tag.tagName isEqualToString:@""]) {
            [urlTagsMap addTag:tag forMultipleAssets:assets];
            [tagCollection updateCollectionWithTag:tag forMultipleAssets:assets];
            [_collectionView reloadData];
        }
        else if (assetURL && ![tag.tagName isEqualToString:@""]) {
            if (tag && ![urlTagsMap doesURL:assetURL haveTag:tag]) {
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                      action:@"image_tag"  // Event action (required)
                                                                       label:nil         // Event label
                                                                       value:nil] build]];    // Event value
                /* Logic for tagging a new image - it is necessary to update both urlToTagMap and tagCollection. */
                [urlTagsMap addTag: tag forAssetURL:assetURL];
                [tagCollection updateCollectionWithTag: tag forImageURL:assetURL];
            }
            else if (tag && [urlTagsMap doesURL:assetURL haveTag:tag]) {
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                      action:@"image_untag"  // Event action (required)
                                                                       label:nil         // Event label
                                                                       value:nil] build]];    // Event value
                /* Logic for removing a tag from a new image - it is necessary to update both urlToTagMap and tagCollection. */
                [urlTagsMap removeTag:tag forAssetURL:assetURL];
                [tagCollection removeImageURL:assetURL forTag:tag];
            }
            //            [_collectionView reloadItemsAtIndexPaths: [[NSArray alloc] initWithObjects:path, nil]]; // DOES NOT WORK FOR FIRST TAG (APPLE BUG?).
            [_collectionView reloadData];
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

-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController.view removeGestureRecognizer:self.revealViewController.panGestureRecognizer];
}


@end
