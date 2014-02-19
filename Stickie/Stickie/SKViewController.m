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


@interface SKViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>
{
    SKPhotoCell *dCell;
    NSIndexPath *dIndexPath;
    UIImage *dImage;
//    UIImageView *_dNewImageView;
}

@property (strong, nonatomic) IBOutlet UIImageView *dNewImageView;
@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property(nonatomic, strong) NSArray *assets;



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
        case UIGestureRecognizerStateBegan:
            dIndexPath = [self.collectionView indexPathForItemAtPoint:newPoint];
            if (dIndexPath == nil){
                NSLog(@"Couldn't find index path");
            }
            dCell = (SKPhotoCell *)[self.collectionView cellForItemAtIndexPath:dIndexPath];
            dImage = [UIImage imageWithCGImage:[dCell.asset thumbnail]];
            [_dNewImageView setCenter:anotherPoint];
            [_dNewImageView setImage:dImage];
            [_dNewImageView addGestureRecognizer:gestureRecognizer];
            NSLog(@"Yo I'm in start");
            break;
        case UIGestureRecognizerStateChanged:
            [_dNewImageView setCenter:anotherPoint];
            NSLog(@"Yo I'm in middle");
            break;
        case UIGestureRecognizerStateEnded:
            _dNewImageView.image = nil;
            [self.collectionView addGestureRecognizer:gestureRecognizer];
            NSLog(@"Yo I'm in end");
            break;
        default:
            break;
    }

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
