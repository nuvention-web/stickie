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

    /* Reinitialize tags as empty when view loads again, then replace as necessary */
    _topLeftLabel.text = @"";
    _topRightLabel.text = @"";
    _botLeftLabel.text = @"";
    _botRightLabel.text = @"";
    
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
    
    defaultPoint = CGPointMake(50.0, 0.0);
    
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
    
    UILongPressGestureRecognizer *longGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureRecognized:)];
    longGestureRecognizer.minimumPressDuration = 0.15;
    longGestureRecognizer.delegate = self;
    _dNewImageView.userInteractionEnabled = YES;
    [self.collectionView addGestureRecognizer:longGestureRecognizer];
    
    [self.topLeftCorner setLongTouchAction:@selector(longPressCornerRecognized:) withTarget:self];
    [self.topRightCorner setLongTouchAction:@selector(longPressCornerRecognized:) withTarget:self];
    [self.botLeftCorner setLongTouchAction:@selector(longPressCornerRecognized:) withTarget:self];
    [self.botRightCorner setLongTouchAction:@selector(longPressCornerRecognized:) withTarget:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    /* Note, the notification center is intentially left unremoved from this view in viewWillDisappear - for the cases that a photo is deleted when the user is outside this application */
}

-(void)viewDidAppear:(BOOL)animated {
    if (!retainScroll) {
        NSInteger section = 0;
        NSInteger item = [self collectionView:_collectionView numberOfItemsInSection:section] - 1;
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        retainScroll = YES;
        if (item > -1) {
            [_collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
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
    int DISTANCE_ABOVE_FINGER = 50;
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
                [_dNewImageView addGestureRecognizer:gestureRecognizer];
                [_dNewImageView.layer setBorderColor: [borderColor CGColor]];
                [_dNewImageView.layer setBorderWidth: BORDER_SIZE];
                _dNewImageView.layer.cornerRadius = dImage.size.width / CORNER_RADIUS_CONSTANT;
                _dNewImageView.layer.masksToBounds = YES;
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            anotherPoint.y -= DISTANCE_ABOVE_FINGER;
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
#pragma mark Edit Tag
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
#pragma mark Drag and Drop Tagging
-(void)recordTags: (CGPoint) point forURL: (NSURL *) assetURL {
    
    /* Constants to define how close thumbnail must be to a given corner in order for a tag to register */
    int TAG_SENSITIVITY_X = dImage.size.width/1.8;
    int TAG_SENSITITVITY_Y = dImage.size.height/1.8;
    
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
                                                          message:@"Tap on the corner to create tag."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    UIButton *button;
    
    /* Tag event occurs in top-left corner */
    if (point.x >= 0 && point.x <= 65 + TAG_SENSITIVITY_X && point.y >= 63 && point.y <= 128 + TAG_SENSITITVITY_Y) {
        tag = [[SKImageTag alloc] initWithName:_topLeftLabel.text andColor:nil];
        button = _topLeftCorner;
    }
    else if (point.x >= 255 - TAG_SENSITIVITY_X && point.x <= 320 && point.y >= 63 && point.y <= 128 + TAG_SENSITITVITY_Y) {
        tag = [[SKImageTag alloc] initWithName:_topRightLabel.text andColor:nil];
        button = _topRightCorner;
    }
    else if (point.x >= 0 && point.x <= 65 + TAG_SENSITIVITY_X && point.y >= 503 - TAG_SENSITITVITY_Y && point.y <= 568) {
        tag = [[SKImageTag alloc] initWithName:_botLeftLabel.text andColor:nil];
        button = _botLeftCorner;
    }
    else if (point.x >= 255 - TAG_SENSITIVITY_X && point.x <= 320 && point.y >= 503 - TAG_SENSITITVITY_Y && point.y <= 568) {
        tag = [[SKImageTag alloc] initWithName:_botRightLabel.text andColor:nil];
        button = _botRightCorner;
    }
    
    if (![tag.tagName isEqualToString:@""]) {
        if (tag && ![urlToTagMap doesURL:assetURL haveTag:tag]) {
            [UIView animateWithDuration:0.6 animations:^{
                button.alpha = 0.0;
            } completion:^(BOOL finished) {
                button.alpha = 1.0;
            }];
            [urlToTagMap addTag: tag forAssetURL:assetURL];
            [tagCollection updateCollectionWithTag: tag forImageURL:assetURL];
        }
        else if (tag && [urlToTagMap doesURL:assetURL haveTag:tag]) {
//            [UIView animateWithDuration:0.6 animations:^{
//                button.alpha = 0.0;
//            } completion:^(BOOL finished) {
//                button.alpha = 1.0;
//            }];
            [alertRemove show];
            [urlToTagMap removeTag:tag forAssetURL:assetURL];
            [tagCollection removeImageURL:assetURL forTag:tag];
        }
    }
    else {
        [alertEmptyTag show];
    }
}
#pragma make Camera Methods
//Take photo
- (IBAction)takePhotoButtonTapped:(id)sender {
    [self performSelector:@selector(useCamera) withObject:nil afterDelay:0.3];

}
-(void)useCamera{
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
-(void)image:(UIImage *)image
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
    [self performSelector:@selector(reloadView) withObject:nil afterDelay:0.3];
}
-(void)reloadView{
    [self viewDidLoad];
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

#pragma mark Tag Assign Delegate Methods
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
        if (![tag.tagName isEqualToString:@""]){
            [tagCollection addTagToCollection:tag];
        }
        if ([corner isEqualToString:@"topLeft"]) {
            oldTag = [oldTag initWithName:_topLeftLabel.text andColor:nil];
            if (!delete) {
                [urlTagsMap transferURLSFrom:oldTag to:tag];
            }
            [urlTagsMap removeAllMappingsToTag:oldTag];
            [tagCollection removeTag:oldTag];
            _topLeftLabel.text = tagSTR;
        }
        else if ([corner isEqualToString:@"topRight"]) {
            oldTag = [oldTag initWithName:_topRightLabel.text andColor:nil];
            if (!delete) {
                [urlTagsMap transferURLSFrom:oldTag to:tag];
            }
            [urlTagsMap removeAllMappingsToTag:oldTag];
            [tagCollection removeTag: oldTag];
            _topRightLabel.text = tagSTR;
        }
        else if ([corner isEqualToString:@"botLeft"]) {
            oldTag = [oldTag initWithName:_botLeftLabel.text andColor:nil];
            if (!delete) {
                [urlTagsMap transferURLSFrom:oldTag to:tag];
            }
            [urlTagsMap removeAllMappingsToTag:oldTag];
            [tagCollection removeTag:oldTag];
            _botLeftLabel.text = tagSTR;
        }
        else if ([corner isEqualToString:@"botRight"]) {
            oldTag = [oldTag initWithName:_botRightLabel.text andColor:nil];
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
