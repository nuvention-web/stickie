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
#import "SKDetailViewController.h"
#import "SKAssetURLTagsMap.h"

@interface SKTagSearchViewController()<UIGestureRecognizerDelegate>
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
}

typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);
@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray *assets;
@property (weak, nonatomic) IBOutlet UIImageView *dNewImageView;

@end

@implementation SKTagSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Tag Search Screen";     // Necessary for Google Analytics
    
    /* Sets titles of buttons. */
    [_topLeftButton setTitle:_topLeftText forState:UIControlStateNormal];
    [_topRightButton setTitle:_topRightText forState:UIControlStateNormal];
    [_botLeftButton setTitle:_botLeftText forState:UIControlStateNormal];
    [_botRightButton setTitle:_botRightText forState:UIControlStateNormal];
    
    /* Initialization stuff. */
    topLeftClicked = NO, topRightClicked = NO, botLeftClicked = NO, botRightClicked = NO;
    _assets = [[NSMutableArray alloc] init];
    library = [[ALAssetsLibrary alloc] init];
    
    UILongPressGestureRecognizer *longGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureRecognized:)];
    longGestureRecognizer.minimumPressDuration = 0.15;
    longGestureRecognizer.delegate = self;
    _dNewImageView.userInteractionEnabled = YES;
    [self.collectionView addGestureRecognizer:longGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void) viewWillAppear: (BOOL) animation
{
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

- (void) loadCurrentTag
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

- (void) applicationWillEnterForeground:(NSNotification *) notification
{
    library = [[ALAssetsLibrary alloc] init];
    [self loadCurrentTag];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKPhotoCell *cell = (SKPhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"searchCell" forIndexPath:indexPath];
    
    ALAsset *asset = self.assets[indexPath.row];
    cell.asset = asset;
    
    return cell;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

-(IBAction) colorButton:(id)sender
{
    /* Reset view. */
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
        
        if ([buttonPressed isEqualToString:_topLeftButton.titleLabel.text])
            topLeftClicked = YES;
        else if ([buttonPressed isEqualToString:_topRightButton.titleLabel.text])
            topRightClicked = YES;
        else if ([buttonPressed isEqualToString:_botLeftButton.titleLabel.text])
            botLeftClicked = YES;
        else if ([buttonPressed isEqualToString:_botRightButton.titleLabel.text])
            botRightClicked = YES;
    }
}

-(void)longGestureRecognized:(UILongPressGestureRecognizer *)gestureRecognizer{
    int DISTANCE_ABOVE_FINGER = 30;
    int BORDER_SIZE = 1.0;
    int CORNER_RADIUS_CONSTANT = 3.0;
    UIColor *borderColor = [UIColor blackColor];
    
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
                dImage = [UIImage imageWithCGImage:[dCell.asset thumbnail]];
                [dCell.asset valueForProperty:ALAssetPropertyURLs];
                anotherPoint.y -= DISTANCE_ABOVE_FINGER;
                [_dNewImageView setCenter:anotherPoint];
                [_dNewImageView setImage:dImage];
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
            _dNewImageView.image = nil;
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
    
    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
    SKAssetURLTagsMap *urlToTagMap = [SKAssetURLTagsMap sharedInstance];
    
    SKImageTag *tag;
    
    UIAlertView *alertRemove = [[UIAlertView alloc] initWithTitle:@"Untagged"
                                                          message:nil
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];

    if (point.x >= 86 && point.x <= 234 && point.y >= 524 - TAG_SENSITIVITY && point.y <= 568){
        tag = [[SKImageTag alloc] initWithName:currentTag andColor:nil];
        if (![tag.tagName isEqualToString:@""]) {
            if (tag && [urlToTagMap doesURL:assetURL haveTag:tag]) {
                [urlToTagMap removeTag:tag forAssetURL:assetURL];
                [tagCollection removeImageURL:assetURL forTag:tag];
                [alertRemove show];
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
        detailViewController.image = image;
        detailViewController.imageURL = url;
        detailViewController.assets = _assets;
        detailViewController->imageIndex = indexPath.row;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    /* Cleanup. */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
