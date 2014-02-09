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


@interface SKTagSearchViewController()
{
    ALAssetsLibrary *library;
    BOOL blue;
    BOOL red;
    BOOL green;
    BOOL pink;
}

typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);
@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray *assets;

@end

@implementation SKTagSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    blue = NO, red = NO, green = NO, pink = NO;
	// Do any additional setup after loading the view.
    _assets = [@[] mutableCopy];
    library = [[ALAssetsLibrary alloc] init];
}
- (IBAction)backMain:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)blueButton:(id)sender
{
    if (!blue){
        [self viewDidLoad];
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            NSLog(@"%@",myasset);
            [_assets addObject:myasset];
            [_collectionView reloadData];
        };

        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
        {
            NSLog(@"Cannot access Library Assets");
        };
        
        SKTagCollection *collection = [SKTagCollection sharedInstance];
        SKImageTag *tag = [[SKImageTag alloc] init];
        tag.tagName = @"Food";
        
        SKTagData *tagData = [collection getTagInfo:tag];
        NSMutableArray *imageURLs = [tagData imageURLs];
        
        for (NSURL *url in imageURLs) {
            [library assetForURL:url resultBlock:resultblock failureBlock:failureblock];
        }
        blue = YES;
    }
}
- (IBAction)redButton:(id)sender {
    if (!red){
        [self viewDidLoad];
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            NSLog(@"%@",myasset);
            [_assets addObject:myasset];
            [_collectionView reloadData];
        };
        
        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
        {
            NSLog(@"Cannot access Library Assets");
        };
        
        SKTagCollection *collection = [SKTagCollection sharedInstance];
        SKImageTag *tag = [[SKImageTag alloc] init];
        tag.tagName = @"Favs";
        
        SKTagData *tagData = [collection getTagInfo:tag];
        NSMutableArray *imageURLs = [tagData imageURLs];
        
        for (NSURL *url in imageURLs) {
            [library assetForURL:url resultBlock:resultblock failureBlock:failureblock];
        }
        red = YES;
    }
}
- (IBAction)greenButton:(id)sender {
    if (!green){
        [self viewDidLoad];
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            NSLog(@"%@",myasset);
            [_assets addObject:myasset];
            [_collectionView reloadData];
        };
        
        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
        {
            NSLog(@"Cannot access Library Assets");
        };
        
        SKTagCollection *collection = [SKTagCollection sharedInstance];
        SKImageTag *tag = [[SKImageTag alloc] init];
        tag.tagName = @"Trips";
        
        SKTagData *tagData = [collection getTagInfo:tag];
        NSMutableArray *imageURLs = [tagData imageURLs];
        
        for (NSURL *url in imageURLs) {
            [library assetForURL:url resultBlock:resultblock failureBlock:failureblock];
        }
        green = YES;
    }
}
- (IBAction)pinkButton:(id)sender {
    if (!pink){
        [self viewDidLoad];
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            NSLog(@"%@",myasset);
            [_assets addObject:myasset];
            [_collectionView reloadData];
        };
        
        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
        {
            NSLog(@"Cannot access Library Assets");
        };
        
        SKTagCollection *collection = [SKTagCollection sharedInstance];
        SKImageTag *tag = [[SKImageTag alloc] init];
        tag.tagName = @"Pets";
        
        SKTagData *tagData = [collection getTagInfo:tag];
        NSMutableArray *imageURLs = [tagData imageURLs];
        
        for (NSURL *url in imageURLs) {
            [library assetForURL:url resultBlock:resultblock failureBlock:failureblock];
        }
        pink = YES;
    }
    
}

@end
