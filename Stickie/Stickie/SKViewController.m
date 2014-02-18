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


@interface SKViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIGestureRecognizerDelegate>{
    SKPhotoCell *dCell;
    NSIndexPath *dIndexPath;
    UIImage *dImage;
//    UIImageView *dNewImageView;
}

@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property(nonatomic, strong) NSArray *assets;
@property (strong, nonatomic) IBOutlet UIImageView *dNewImageView;


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
    
    /* Removed top margin in collection view at startup */
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _assets = [@[] mutableCopy];
    __block NSMutableArray *tmpAssets = [@[] mutableCopy];

    ALAssetsLibrary *assetsLibrary = [SKViewController defaultAssetsLibrary];

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
    longGestureRecognizer.minimumPressDuration = 0.5;
    longGestureRecognizer.delegate = self;
    [self.collectionView addGestureRecognizer:longGestureRecognizer];
    _dNewImageView = [[UIImageView alloc] init];
    _dNewImageView.userInteractionEnabled = YES;
    [self.view insertSubview:_dNewImageView aboveSubview:self.collectionView];
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
//-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UILongPressGestureRecognizer *longGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureRecognized:)];
//    longGestureRecognizer.delaysTouchesBegan = YES;
//    longGestureRecognizer.minimumPressDuration = 0.5;
//    longGestureRecognizer.delegate = self;
//    ALAsset *asset = self.assets[indexPath.row];
//    UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
//    UIImageView *newImageView = [[UIImageView alloc] initWithImage:image];
//    [newImageView setUserInteractionEnabled:YES];
//    [newImageView addGestureRecognizer:longGestureRecognizer];
//}
//Select image
//- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UILongPressGestureRecognizer *longGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureRecognized:)];
//    longGestureRecognizer.delaysTouchesBegan = YES;
//    longGestureRecognizer.minimumPressDuration = 0.5;
//    longGestureRecognizer.delegate = self;
//    ALAsset *asset = self.assets[indexPath.row];
//////    NSLog(@"%@",[asset valueForProperty:ALAssetPropertyAssetURL]);
//////    NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
//////    SKAssetURLTagsMap *map = [SKAssetURLTagsMap sharedInstance];
//////    [map removeAllTags];
//////    SKImageTag *tag = [[SKImageTag alloc] initWithName:@"stick" andColor: nil];
//////    [map setTag:tag forAssetURL:url];
//////    NSLog(@"%@", [[map getTagForAssetURL:url] tagName]);
////
//////    ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
//////    UIImage *image = [UIImage imageWithCGImage:[defaultRep fullScreenImage] scale:[defaultRep scale] orientation:0];
//    UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
//    UIImageView *newImageView = [[UIImageView alloc] initWithImage:image];
//    [newImageView setUserInteractionEnabled:YES];
////    UILongPressGestureRecognizer *longGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureRecognized:)];
////    [newImageView addGestureRecognizer:longGestureRecognizer];
////    longGestureRecognizer.minimumPressDuration = 0.3;
//
//    [newImageView addGestureRecognizer:longGestureRecognizer];
//}
-(void)longGestureRecognized:(UILongPressGestureRecognizer *)gestureRecognizer{
    gestureRecognizer.delaysTouchesBegan = YES;
    CGPoint newPoint = [gestureRecognizer locationInView:self.collectionView];
//    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:newPoint];
//    if (indexPath == nil){
//        NSLog(@"Couldn't find index path");
//    }
//    else {
//        SKPhotoCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
//        UIImage *image = [UIImage imageWithCGImage:[cell.asset thumbnail]];
//        UIImageView *newImageView = [[UIImageView alloc] initWithImage:image];
//        [newImageView setCenter:newPoint];
//        
//    }
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            dIndexPath = [self.collectionView indexPathForItemAtPoint:newPoint];
            if (dIndexPath == nil){
                NSLog(@"Couldn't find index path");
            }
            dCell = (SKPhotoCell *)[self.collectionView cellForItemAtIndexPath:dIndexPath];
            dImage = [UIImage imageWithCGImage:[dCell.asset thumbnail]];
            [_dNewImageView setImage:dImage];
            [_dNewImageView setUserInteractionEnabled:YES];
            [self.view insertSubview:_dNewImageView aboveSubview:self.collectionView];
//            [[self view] bringSubviewToFront:[_dNewImageView superview]];
//            [[_dNewImageView superview] bringSubviewToFront:_dNewImageView];
            NSLog(@"Yo I'm in start");
            break;
        case UIGestureRecognizerStateChanged:
            [_dNewImageView setCenter:newPoint];
            NSLog(@"Yo I'm in middle");
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"Yo I'm in end");
            break;
        default:
            break;
    }
//    CGPoint newPoint = [gestureRecognizer locationInView:[self view]];
//    [[self view] bringSubviewToFront:[gestureRecognizer view]];
//    [[gestureRecognizer view] setCenter:newPoint];
}

//Take photo
//- (IBAction)takePhotoButtonTapped:(id)sender
//{
//    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)) {
//        return;
//    }
//    
//    UIImagePickerController *mediaUI = [UIImagePickerController new];
//    mediaUI.sourceType = UIImagePickerControllerSourceTypeCamera;
//    mediaUI.allowsEditing = NO;
//    mediaUI.delegate = self;
//    
//    [self presentViewController:mediaUI animated:YES completion:nil];
//}

//Enlarge Image
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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
}

@end
