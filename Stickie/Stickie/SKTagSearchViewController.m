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
    BOOL blue;
    BOOL red;
    BOOL green;
    BOOL pink;
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
    self.screenName = @"Tag Search Screen";
    [_topLeftButton setTitle:_topLeftText forState:UIControlStateNormal];
    [_topRightButton setTitle:_topRightText forState:UIControlStateNormal];
    [_botLeftButton setTitle:_botLeftText forState:UIControlStateNormal];
    [_botRightButton setTitle:_botRightText forState:UIControlStateNormal];
    blue = NO, red = NO, green = NO, pink = NO;
	// Do any additional setup after loading the view.
    _assets = [[NSMutableArray alloc] init];
    library = [[ALAssetsLibrary alloc] init];
}
- (IBAction)backMain:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear: (BOOL) animation
{
    /* Can call a button press from a previous view. */
    if ([_callButtonOnLoad isEqualToString:@"topLeftButton"])
        [_topLeftButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    else if ([_callButtonOnLoad isEqualToString:@"topRightButton"])
        [_topRightButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    else if ([_callButtonOnLoad isEqualToString:@"botLeftButton"])
        [_botLeftButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    else if ([_callButtonOnLoad isEqualToString:@"botRightButton"])
        [_botRightButton sendActionsForControlEvents:UIControlEventTouchUpInside];
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
    cell.backgroundColor = [UIColor redColor];
    
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
    [self viewDidLoad];
    [_collectionView reloadData];
    BOOL beenClickedBefore;
    
    NSString *buttonPressed = [sender currentTitle];
    currentTag = buttonPressed;
    if ([buttonPressed isEqualToString:_topLeftButton.titleLabel.text]){
        beenClickedBefore = blue;
    }
    else if ([buttonPressed isEqualToString:_topRightButton.titleLabel.text]){
        beenClickedBefore = red;
    }
    else if ([buttonPressed isEqualToString:_botLeftButton.titleLabel.text]){
        beenClickedBefore = green;
    }
    else{
        beenClickedBefore = pink;
    }
    
    if (!beenClickedBefore) {
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            [_assets addObject:myasset];
            [_collectionView reloadData];
        };
        
        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
        {
            NSLog(@"Cannot access Library Assets");
        };
        
        SKTagCollection *collection = [SKTagCollection sharedInstance];
        SKImageTag *tag = [[SKImageTag alloc] init];
        tag.tagName = buttonPressed;
        
        SKTagData *tagData = [collection getTagInfo:tag];
        NSMutableArray *imageURLs = [tagData imageURLs];
        
        for (NSURL *url in imageURLs) {
            [library assetForURL:url resultBlock:resultblock failureBlock:failureblock];
        }
        
        if ([buttonPressed isEqualToString:_topLeftButton.titleLabel.text])
            blue = YES;
        else if ([buttonPressed isEqualToString:_topRightButton.titleLabel.text])
            red = YES;
        else if ([buttonPressed isEqualToString:_botLeftButton.titleLabel.text])
            green = YES;
        else if ([buttonPressed isEqualToString:_botRightButton.titleLabel.text])
            pink = YES;
        UILongPressGestureRecognizer *longGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureRecognized:)];
        longGestureRecognizer.minimumPressDuration = 0.15;
        longGestureRecognizer.delegate = self;
        _dNewImageView.userInteractionEnabled = YES;
        [self.collectionView addGestureRecognizer:longGestureRecognizer];
    }
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
    
    UIAlertView *alertRemove = [[UIAlertView alloc] initWithTitle:@"Untagged"
                                                          message:nil
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    
//    UIAlertView *alertDelete = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to untag this photo?"
//                                                          message:nil
//                                                         delegate:self
//                                                cancelButtonTitle:@"Cancel"
//                                                otherButtonTitles:@"Untag",nil];
  
    if (point.x >= 86 && point.x <= 234 && point.y >= 524 && point.y <= 568){
        tag = [[SKImageTag alloc] initWithName:currentTag andColor:nil];
//        [alertDelete show];
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
//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 1) {
//        untag = YES;
//    }
//}
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
    }
}
@end
