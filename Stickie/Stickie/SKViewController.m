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
    NSInteger retainScroll;
}

@property (strong, nonatomic) IBOutlet UIImageView *dNewImageView;
@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property(nonatomic, strong) NSArray *assets;
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

-(void) applicationWillEnterForeground:(NSNotification *) notification
{
//    /* Check to ensure no photos have been deleted while the user switched applications */
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    SKAssetURLTagsMap *tagsMap = [SKAssetURLTagsMap sharedInstance];
//    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
//    NSArray *urlArray = [tagsMap allURLs];
//    
//    for (NSURL* url in urlArray) {
//        [library assetForURL:url resultBlock:^(ALAsset *asset) {
//            if (!asset) {
//                [tagsMap removeAllTagsForURL:url];
//                [tagCollection removeAllInstancesOfURL:url];
//            }
//        } failureBlock:^(NSError *error) {
//           [NSException raise:@"Asset Processing Error." format: @"There was an error processing the required ALAssets."];
//        }];
//    }
    
    /* Reload view so user changes are recognized */
    [self viewDidLoad];
}

/* Load images at app startup */
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Home Screen";
    
    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
    NSMutableArray *tagArray = [tagCollection getAllTags];
    if ([tagArray count] > 0) {
        _topLeftLabel.text = ((SKImageTag *) tagArray[0]).tagName;
    }
    if ([tagArray count] > 1) {
        _topRightLabel.text = ((SKImageTag *) tagArray[1]).tagName;
    }
    if ([tagArray count] > 2) {
        _botLeftLabel.text = ((SKImageTag *) tagArray[2]).tagName;
    }
    if ([tagArray count] > 3) {
        _botRightLabel.text = ((SKImageTag *) tagArray[3]).tagName;
    }
    
    /* Removed top margin in collection view at startup */
    self.automaticallyAdjustsScrollViewInsets = NO;
    _assets = [@[] mutableCopy];
    __block NSMutableArray *tmpAssets = [@[] mutableCopy];

    ALAssetsLibrary *assetsLibrary = [SKViewController defaultAssetsLibrary];
    
    defaultPoint = CGPointMake(0.0, 0.0);
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result)
            {
                [tmpAssets addObject:result];
            }
        }];
        
        self.assets = tmpAssets;
        
        [self.collectionView reloadData];
    } failureBlock:^(NSError *error) {
        NSLog(@"Error loading images %@", error);
    }];
    
    UILongPressGestureRecognizer *longGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureRecognized:)];
    longGestureRecognizer.minimumPressDuration = 0.15;
    longGestureRecognizer.delegate = self;
    _dNewImageView.userInteractionEnabled = YES;
    [self.collectionView addGestureRecognizer:longGestureRecognizer];
    
    if (!retainScroll) {
        retainScroll = 0;
    }
    else {
        retainScroll++;
    }
    
    [self.topLeftCorner setLongTouchAction:@selector(longPressCornerRecognized:) withTarget:self];
    [self.topRightCorner setLongTouchAction:@selector(longPressCornerRecognized:) withTarget:self];
    [self.botLeftCorner setLongTouchAction:@selector(longPressCornerRecognized:) withTarget:self];
    [self.botRightCorner setLongTouchAction:@selector(longPressCornerRecognized:) withTarget:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    if (retainScroll < 1 ) {
        NSInteger section = 0;
        NSInteger item = [self collectionView:_collectionView numberOfItemsInSection:section] - 1;
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        if (item > -1) {
            [_collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            retainScroll ++;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collection view data source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

//Load images into cells
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKPhotoCell *cell = (SKPhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    ALAsset *asset = self.assets[indexPath.row];
    cell.asset = asset;
    
    return cell;
}
//Adjust image spacing
- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

-(void)longGestureRecognized:(UILongPressGestureRecognizer *)gestureRecognizer{
    CGPoint newPoint = [gestureRecognizer locationInView:self.collectionView];
    CGPoint anotherPoint = [self.view convertPoint:newPoint fromView:self.collectionView];
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            dIndexPath = [self.collectionView indexPathForItemAtPoint:newPoint];
            if (dIndexPath == nil){
                NSLog(@"Couldn't find index path");
            }
            dCell = (SKPhotoCell *)[self.collectionView cellForItemAtIndexPath:dIndexPath];
            dImage = [UIImage imageWithCGImage:[dCell.asset thumbnail]];
            [dCell.asset valueForProperty:ALAssetPropertyURLs];
            [_dNewImageView setCenter:anotherPoint];
            [_dNewImageView setImage:dImage];
            [_dNewImageView addGestureRecognizer:gestureRecognizer];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [_dNewImageView setCenter:anotherPoint];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            _dNewImageView.image = nil;
            [_dNewImageView setCenter:defaultPoint];
            NSURL *url = [dCell.asset valueForProperty:ALAssetPropertyAssetURL];
            [self recordTags: anotherPoint forURL: url];
            [self.collectionView addGestureRecognizer:gestureRecognizer];
            break;
        }
        default:
            break;
    }
}

-(void)longPressCornerRecognized:(UILongPressGestureRecognizer *) gestureRecognizer{
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

-(void)recordTags: (CGPoint) point forURL: (NSURL *) assetURL {
    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
    SKAssetURLTagsMap *urlToTagMap = [SKAssetURLTagsMap sharedInstance];
    
    SKImageTag *tag;
    
    UIAlertView *alertTag = [[UIAlertView alloc] initWithTitle:@"Tagged!"
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    UIAlertView *alertRemove = [[UIAlertView alloc] initWithTitle:@"Untagged"
                                                       message:nil
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    UIAlertView *alertEmptyTag = [[UIAlertView alloc] initWithTitle:@"The tag is unlabeled."
                                                          message:@"Press on the corner to create tag."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    
    /* Tag event occurs in top-left corner */
    if (point.x >= 0 && point.x <= 65 && point.y >= 63 && point.y <= 128)
        tag = [[SKImageTag alloc] initWithName:_topLeftLabel.text andColor:nil];

    else if (point.x >= 255 && point.x <= 320 && point.y >= 63 && point.y <= 128)
        tag = [[SKImageTag alloc] initWithName:_topRightLabel.text andColor:nil];

    else if (point.x >= 0 && point.x <= 65 && point.y >= 503 && point.y <= 568)
        tag = [[SKImageTag alloc] initWithName:_botLeftLabel.text andColor:nil];

    else if (point.x >= 255 && point.x <= 320 && point.y >= 503 && point.y <= 568)
        tag = [[SKImageTag alloc] initWithName:_botRightLabel.text andColor:nil];
    
    if (![tag.tagName isEqualToString:@""]) {
        if (tag && ![urlToTagMap doesURL:assetURL haveTag:tag]) {
            [alertTag show];
            [urlToTagMap addTag: tag forAssetURL:assetURL];
            [tagCollection updateCollectionWithTag: tag forImageURL:assetURL];
        }
        else if (tag && [urlToTagMap doesURL:assetURL haveTag:tag]) {
            [alertRemove show];
            [urlToTagMap removeTag:tag forAssetURL:assetURL];
            [tagCollection removeImageURL:assetURL forTag:tag];
        }
    }
    else {
        [alertEmptyTag show];
    }
}

//Take photo
- (IBAction)takePhotoButtonTapped:(id)sender {

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
-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        

        if (_newMedia){
            retainScroll = 0;
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

-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    [self viewDidLoad];
    [_collectionView reloadData];
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
}

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
    //Enlarge Image
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
    }
    else if ([[segue identifier] isEqualToString:@"tagSearch"])
    {
        SKTagSearchViewController *tagSearchViewController = [segue destinationViewController];
        tagSearchViewController.topLeftText = _topLeftLabel.text;
        tagSearchViewController.topRightText = _topRightLabel.text;
        tagSearchViewController.botLeftText = _botLeftLabel.text;
        tagSearchViewController.botRightText = _botRightLabel.text;
        
    }
    else if ([[segue identifier] isEqualToString:@"topLeftTag"]){
        SKTagSearchViewController *tagSearchViewController = [segue destinationViewController];
        tagSearchViewController.topLeftText = _topLeftLabel.text;
        tagSearchViewController.topRightText = _topRightLabel.text;
        tagSearchViewController.botLeftText = _botLeftLabel.text;
        tagSearchViewController.botRightText = _botRightLabel.text;
        tagSearchViewController.callButtonOnLoad = @"topLeftButton";
    }
    else if ([[segue identifier] isEqualToString:@"topRightTag"]){
        SKTagSearchViewController *tagSearchViewController = [segue destinationViewController];
        tagSearchViewController.topLeftText = _topLeftLabel.text;
        tagSearchViewController.topRightText = _topRightLabel.text;
        tagSearchViewController.botLeftText = _botLeftLabel.text;
        tagSearchViewController.botRightText = _botRightLabel.text;
        tagSearchViewController.callButtonOnLoad = @"topRightButton";
    }
    else if ([[segue identifier] isEqualToString:@"botLeftTag"]){
        SKTagSearchViewController *tagSearchViewController = [segue destinationViewController];
        tagSearchViewController.topLeftText = _topLeftLabel.text;
        tagSearchViewController.topRightText = _topRightLabel.text;
        tagSearchViewController.botLeftText = _botLeftLabel.text;
        tagSearchViewController.botRightText = _botRightLabel.text;
        tagSearchViewController.callButtonOnLoad = @"botLeftButton";
    }
    else if ([[segue identifier] isEqualToString:@"botRightTag"]){
        SKTagSearchViewController *tagSearchViewController = [segue destinationViewController];
        tagSearchViewController.topLeftText = _topLeftLabel.text;
        tagSearchViewController.topRightText = _topRightLabel.text;
        tagSearchViewController.botLeftText = _botLeftLabel.text;
        tagSearchViewController.botRightText = _botRightLabel.text;
        tagSearchViewController.callButtonOnLoad = @"botRightButton";
    }
    else if ([[segue identifier] isEqualToString:@"topLeftTagEdit"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SKTagAssignViewController *tagAssignViewController = [navigationController viewControllers][0];
        if ([_topLeftLabel.text isEqualToString:@""]) {
            tagAssignViewController.createTag = YES;
        }
        tagAssignViewController.source = @"topLeft";
        tagAssignViewController.delegate = self;
        tagAssignViewController.preLabel = _topLeftLabel.text;

    }
    else if ([[segue identifier] isEqualToString:@"topRightTagEdit"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SKTagAssignViewController *tagAssignViewController = [navigationController viewControllers][0];
        if ([_topRightLabel.text isEqualToString:@""]) {
            tagAssignViewController.createTag = YES;
        }
        tagAssignViewController.source = @"topRight";
        tagAssignViewController.delegate = self;
        tagAssignViewController.preLabel = _topRightLabel.text;

        
    }
    else if ([[segue identifier] isEqualToString:@"botLeftTagEdit"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SKTagAssignViewController *tagAssignViewController = [navigationController viewControllers][0];
        if ([_botLeftLabel.text isEqualToString:@""]) {
            tagAssignViewController.createTag = YES;
        }
        tagAssignViewController.source = @"botLeft";
        tagAssignViewController.delegate = self;
        tagAssignViewController.preLabel = _botLeftLabel.text;

    }
    else if ([[segue identifier] isEqualToString:@"botRightTagEdit"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SKTagAssignViewController *tagAssignViewController = [navigationController viewControllers][0];
        if ([_botRightLabel.text isEqualToString:@""]) {
            tagAssignViewController.createTag = YES;
        }
        tagAssignViewController.source = @"botRight";
        tagAssignViewController.delegate = self;
        tagAssignViewController.preLabel = _botRightLabel.text;

    }
}

- (void)tagAssignViewControllerDidCancel:(SKTagAssignViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)tagAssignViewController:(SKTagAssignViewController *)controller didAddTag:(NSString *)tagSTR for:(NSString *)corner andDelete:(BOOL)delete
{
    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
    SKImageTag *tag = [[SKImageTag alloc] initWithName:tagSTR andColor:nil];
    SKImageTag *oldTag =[SKImageTag alloc];
    SKAssetURLTagsMap *urlTagsMap = [SKAssetURLTagsMap sharedInstance];
    
    if (![tagCollection isTagInCollection:tag]) {
        if ([corner isEqualToString:@"topLeft"]) {
            if (delete) {
                [urlTagsMap removeAllMappingsToTag: [oldTag initWithName:_topLeftLabel.text andColor:nil]];
                [tagCollection removeTag: oldTag];
            }
            if (![tag.tagName isEqualToString:@""]){
                [tagCollection addTagToCollection:tag];
            }
            _topLeftLabel.text = tagSTR;
        }
        else if ([corner isEqualToString:@"topRight"]) {
            if (delete) {
                [urlTagsMap removeAllMappingsToTag: [oldTag initWithName:_topRightLabel.text andColor:nil]];
                [tagCollection removeTag: oldTag];
            }
            if (![tag.tagName isEqualToString:@""]){
                [tagCollection addTagToCollection:tag];
            }
            _topRightLabel.text = tagSTR;
        }
        else if ([corner isEqualToString:@"botLeft"]) {
            if (delete) {
                [urlTagsMap removeAllMappingsToTag: [oldTag initWithName:_botLeftLabel.text andColor:nil]];
                [tagCollection removeTag: oldTag];
            }
            if (![tag.tagName isEqualToString:@""]){
                [tagCollection addTagToCollection:tag];
            }
            _botLeftLabel.text = tagSTR;
        }
        else if ([corner isEqualToString:@"botRight"]) {
            if (delete) {
                [urlTagsMap removeAllMappingsToTag: [oldTag initWithName:_botRightLabel.text andColor:nil]];
                [tagCollection removeTag: oldTag];
            }
            if (![tag.tagName isEqualToString:@""]){
                [tagCollection addTagToCollection:tag];
            }
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
