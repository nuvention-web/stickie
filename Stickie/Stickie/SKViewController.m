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


@interface SKViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>
{
    SKPhotoCell *dCell;
    NSIndexPath *dIndexPath;
    UIImage *dImage;
    CGPoint defaultPoint;
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

-(void)recordTags: (CGPoint) point forURL: (NSURL *) assetURL {
    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
    SKAssetURLTagsMap *urlToTagMap = [SKAssetURLTagsMap sharedInstance];
    
    SKImageTag *tag;
    
    UIAlertView *alertTag = [[UIAlertView alloc] initWithTitle:@"You tagged a picture."
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    UIAlertView *alertRemove = [[UIAlertView alloc] initWithTitle:@"You untagged a picture."
                                                       message:nil
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    UIAlertView *alertEmptyTag = [[UIAlertView alloc] initWithTitle:@"The tag is unlabeled."
                                                          message:nil
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
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        

        if (_newMedia)
            UIImageWriteToSavedPhotosAlbum(image,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
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
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    [self viewDidLoad];
    [_collectionView reloadData];
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
        NSLog(@"%@", _topLeftLabel.text);
        tagSearchViewController.topRightText = _topRightLabel.text;
        tagSearchViewController.botLeftText = _botLeftLabel.text;
        tagSearchViewController.botRightText = _botRightLabel.text;
    }
    else if ([[segue identifier] isEqualToString:@"topLeftTag"]){
        UINavigationController *navigationController = [segue destinationViewController];
        SKTagAssignViewController *tagAssignViewController = [navigationController viewControllers][0];
        tagAssignViewController.source = @"topLeft";
        tagAssignViewController.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"topRightTag"]){
        UINavigationController *navigationController = [segue destinationViewController];
        SKTagAssignViewController *tagAssignViewController = [navigationController viewControllers][0];
        tagAssignViewController.source = @"topRight";
        tagAssignViewController.delegate = self;
        
    }
    else if ([[segue identifier] isEqualToString:@"botLeftTag"]){
        UINavigationController *navigationController = [segue destinationViewController];
        SKTagAssignViewController *tagAssignViewController = [navigationController viewControllers][0];
        tagAssignViewController.source = @"botLeft";
        tagAssignViewController.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"botRightTag"]){
        UINavigationController *navigationController = [segue destinationViewController];
        SKTagAssignViewController *tagAssignViewController = [navigationController viewControllers][0];
        tagAssignViewController.source = @"botRight";
        tagAssignViewController.delegate = self;

    }
}

- (void)tagAssignViewControllerDidCancel:(SKTagAssignViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)tagAssignViewController:(SKTagAssignViewController *)controller didAddTag:(NSString *)tagSTR for:(NSString *)corner
{
    SKTagCollection *tagCollection = [SKTagCollection sharedInstance];
    SKImageTag *tag = [[SKImageTag alloc] initWithName:tagSTR andColor:nil];
    SKImageTag *oldTag =[SKImageTag alloc];
    SKAssetURLTagsMap *urlTagsMap = [SKAssetURLTagsMap sharedInstance];
    if (![tagCollection isTagInCollection:tag]) {
        if ([corner isEqualToString:@"topLeft"]) {
            SKTagData *tagData = [tagCollection getTagInfo:[oldTag initWithName:_topLeftLabel.text andColor:nil]];
            NSMutableArray *urls = tagData.imageURLs;
            for (NSURL *url in urls){
                [urlTagsMap removeTag:oldTag forAssetURL:url];
            }
            [tagCollection removeTag: oldTag];
            [tagCollection addTagToCollection:tag];
            _topLeftLabel.text = tagSTR;
        }
        else if ([corner isEqualToString:@"topRight"]) {
            SKTagData *tagData = [tagCollection getTagInfo:[oldTag initWithName:_topRightLabel.text andColor:nil]];
            NSMutableArray *urls = tagData.imageURLs;
            for (NSURL *url in urls){
                [urlTagsMap removeTag:oldTag forAssetURL:url];
            }
            [tagCollection removeTag: oldTag];
            [tagCollection addTagToCollection:tag];
            _topRightLabel.text = tagSTR;
        }
        else if ([corner isEqualToString:@"botLeft"]) {
            SKTagData *tagData = [tagCollection getTagInfo:[oldTag initWithName:_botLeftLabel.text andColor:nil]];
            NSMutableArray *urls = tagData.imageURLs;
            for (NSURL *url in urls){
                [urlTagsMap removeTag:oldTag forAssetURL:url];
            }
            [tagCollection removeTag: oldTag];
            [tagCollection addTagToCollection:tag];
            _botLeftLabel.text = tagSTR;
        }
        else if ([corner isEqualToString:@"botRight"]) {
            SKTagData *tagData = [tagCollection getTagInfo:[oldTag initWithName:_botRightLabel.text andColor:nil]];
            NSMutableArray *urls = tagData.imageURLs;
            for (NSURL *url in urls){
                [urlTagsMap removeTag:oldTag forAssetURL:url];
            }
            [tagCollection removeTag: oldTag];
            [tagCollection addTagToCollection:tag];
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
