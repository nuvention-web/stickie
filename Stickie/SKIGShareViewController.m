//
//  SKIGShareViewController.m
//  Stickie
//
//  Created by Grant Sheldon on 5/6/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKIGShareViewController.h"
#import "SKAssetURLTagsMap.h"

@interface SKIGShareViewController () <UIDocumentInteractionControllerDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *categories;

@end

typedef enum {
    CUSTOM, BASIC, MORELIKES, POPULAR, FASHION, FITNESS, FOOD, FRIENDS, LOVE, MAKEUP, MEMES,  NATURE, PARTYING, PETS,  SELFIES, SUNSETS,
} Category;

@implementation SKIGShareViewController {
    BOOL autoSquare;
}
- (IBAction)adjustAutoSquare:(id)sender {
    if([sender isOn]){
        autoSquare = YES;
    } else{
        autoSquare = NO;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 125, self.view.bounds.size.width, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0];
    [self.view addSubview:lineView];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Skip  "
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(shareSkip)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    // Do any additional setup after loading the view.
    _categories = @[@"insta_custom.png", @"insta_basic.png", @"insta_morelikes.png", @"insta_popular.png", @"insta_fashion.png", @"insta_fitness.png", @"insta_food.png", @"insta_friends.png",@"insta_love.png", @"insta_makeup.png", @"insta_memes.png",  @"insta_nature.png", @"insta_partying.png",@"insta_pets.png", @"insta_selfies.png", @"insta_sunsets.png"];
}
- (void)shareSkip{
    [self shareToInstaWith:@""];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_categories count];
}

/* Load images into cells. */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"instaCell" forIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.width, cell.frame.size.height)];
    imageView.image = [UIImage imageNamed:[_categories objectAtIndex:[indexPath row]]];
    [cell addSubview:imageView];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath row]) {
        case BASIC:
            [self shareToInstaWith:@""];
            break;
            
        case FITNESS:
            [self shareToInstaWith:@"SWOLE TRAIN"];
            break;
            
        case NATURE:
            [self shareToInstaWith:@"TREES"];
            break;
            
        case POPULAR:
            [self shareToInstaWith:@"I GOT FRIENDS"];
            break;
            
        case SELFIES:
            [self shareToInstaWith:@"#20likes #amazing #bestoftheday #f4f #follow #follow4follow #followme #girl #hot #instacool #instacool #instadaily #instafollow #instafollow #instago #instalike #l4l #like4like #likeall #likethis #love #photooftheday #picoftheday #smile"];
            break;
            
        case SUNSETS:
            [self shareToInstaWith:@"OH SO PRETTY"];
            break;
            
        case CUSTOM:
            [self shareToInstaWith:@"INSERT SEGUE HERE"];
            break;
            
        default:
            [self shareToInstaWith:@"LOLS"];
            break;
    }
}
- (void)shareToInstaWith: (NSString *)str
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        //    UIImage* instaImage = [self thumbnailFromView:imageView]; //Full Image Low Resolution
        UIImage* instaImage;
        if (autoSquare) {
            int size;
            
            if (_imageView.image.size.height > _imageView.image.size.width){
                size = _imageView.image.size.height;
            }
            else {
                size = _imageView.image.size.width;
            }
            
            UIGraphicsBeginImageContext(CGSizeMake(size, size));
            [_imageView.image drawInRect:CGRectMake(size/2-_imageView.image.size.width/2,size/2-_imageView.image.size.height/2,_imageView.image.size.width,_imageView.image.size.height)];
            instaImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        else {
            instaImage = _imageView.image; //Top half of image Full Resolution.
        }
        
        

        NSString* imagePath = [NSString stringWithFormat:@"%@/image.igo", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        [UIImagePNGRepresentation(instaImage) writeToFile:imagePath atomically:YES];
        //    NSLog(@"image size: %@", NSStringFromCGSize(instaImage.size));
        _docFile = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath]];
        _docFile.delegate=self;
        _docFile.UTI = @"com.instagram.exclusivegram";
        
        // Setting up hashtags
        NSMutableString *hashtags = [NSMutableString stringWithString:@"Get @stickiepic | #stickiepic"];
        NSArray *tags = [[NSArray alloc] initWithArray:[[SKAssetURLTagsMap sharedInstance] getTagsForAssetURL:_url]];
        for (int i = 0; i < [tags count]; i++) {
            [hashtags appendString:@" #"];
            [hashtags appendString:[((SKImageTag*)tags[i]) tagName]];
        }
        [hashtags appendString:@" ••"];
        NSString *newString = [NSString stringWithFormat:@"%@\r%@", hashtags,str];
//        [hashtags appendString:str];
        
        _docFile.annotation=[NSDictionary dictionaryWithObjectsAndKeys:newString,@"InstagramCaption", nil];
        [_docFile presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Instagram Not Installed"
                              message: @"Please install Instagram for iOS to share your photos!"
                              delegate: self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:@"Download", nil];
        
        [alert show];
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
