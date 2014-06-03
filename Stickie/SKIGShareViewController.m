//
//  SKIGShareViewController.m
//  Stickie
//
//  Created by Grant Sheldon on 5/6/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKIGShareViewController.h"
#import "SKAssetURLTagsMap.h"
#import "SKCustomIGViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface SKIGShareViewController () <UIDocumentInteractionControllerDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    UIImage* instaImage;
    dispatch_queue_t loadImageToShare;

}


@property (nonatomic, strong) NSArray *categories;
@property (weak, nonatomic) IBOutlet UILabel *chooseLabel;
@property (nonatomic, strong) NSString *customChoice;

@end

typedef enum {
    CUSTOM1, CUSTOM2, GET_MORE_LIKES, GET_MORE_FOLLOWS, FASHION, FITNESS, FOOD, FRIENDS, LOVE, MAKEUP, MEMES, NATURE, PARTYING, PETS, PHOTOGRAPHY, SELFIES
} Category;

@implementation SKIGShareViewController {
    BOOL autoSquare;
}
- (IBAction)adjustAutoSquare:(id)sender {
    if([sender isOn]){
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
        [self loadImage];
    } else{
        instaImage = _imageView.image; //Top half of image Full Resolution.
        [self loadImage];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 127, self.view.bounds.size.width, 0.5)];
    lineView.backgroundColor = [UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:179.0/255.0 alpha:1.0];
    [self.view addSubview:lineView];
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 128, self.view.bounds.size.width, 32.5)];
    lineView.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0];
    [self.view addSubview:lineView];
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 159.5, self.view.bounds.size.width, 0.5)];
    lineView.backgroundColor = [UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:179.0/255.0 alpha:1.0];
    [self.view addSubview:lineView];
    [_chooseLabel setTextColor:[UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0]];
    [self.view addSubview:_chooseLabel];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Skip  "
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(shareSkip)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.title = @"likes+";
    
    // Do any additional setup after loading the view.
    _categories = @[@"insta_custom1.png", @"insta_custom2.png", @"insta_getmorelikes.png", @"insta_getmorefollows.png", @"insta_fashion.png", @"insta_fitness.png", @"insta_food.png", @"insta_friends.png", @"insta_love.png", @"insta_makeup.png", @"insta_memes.png", @"insta_nature.png", @"insta_partying.png", @"insta_pets.png", @"insta_photography.png",
                    @"insta_selfies.png"];
    
    _customChoice = [[NSString alloc] init];
    instaImage = _imageView.image; //Top half of image Full Resolution.
    loadImageToShare = dispatch_queue_create("Load Image", NULL);
    [self loadImage];
}
- (void)loadImage
{
    @autoreleasepool {
        NSString* imagePath = [NSString stringWithFormat:@"%@/image.igo", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        [UIImagePNGRepresentation(instaImage) writeToFile:imagePath atomically:YES];
        //    NSLog(@"image size: %@", NSStringFromCGSize(instaImage.size));
        _docFile = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath]];
    }
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

-(void)animateWithBoop:(UIView*)item forTime:(NSTimeInterval)time
{
    CGRect currentFrame = item.frame;
    [UIView animateWithDuration:time/2.0 animations:^(void){
        item.frame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y-10, currentFrame.size.width, currentFrame.size.height);
    }completion:^(BOOL finished){
        [UIView animateWithDuration:time/2.0 animations:^(void){
            item.frame = currentFrame;
        }];
    }];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // Reading tag data from JSON file.
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];;
    [self animateWithBoop:cell forTime:0.35];
//    cell.backgroundColor = [UIColor redColor];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"stickie_likes" ofType:@"json"];
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *dictResults = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    switch ([indexPath row]) {
        case CUSTOM1:
            _customChoice = @"custom1";
            [self performSegueWithIdentifier:@"customInsta" sender:self];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"insta_custom1"  // Event action (required)
                                                                   label:nil         // Event label
                                                                   value:nil] build]];    // Event value
            break;
            
        case CUSTOM2:
            _customChoice = @"custom2";
            [self performSegueWithIdentifier:@"customInsta" sender:self];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"insta_custom2"  // Event action (required)
                                                                   label:nil         // Event label
                                                                   value:nil] build]];    // Event value
            break;
            
        case GET_MORE_LIKES:
            [self shareToInstaWith:[dictResults objectForKey:@"get_more_likes"]];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"insta_get_more_likes"  // Event action (required)
                                                                   label:nil         // Event label
                                                                   value:nil] build]];    // Event value
            break;
            
        case GET_MORE_FOLLOWS:
            [self shareToInstaWith:[dictResults objectForKey:@"get_more_follows"]];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"insta_get_more_follows"  // Event action (required)
                                                                   label:nil         // Event label
                                                                   value:nil] build]];    // Event value
            break;
            
        case FASHION:
            [self shareToInstaWith:[dictResults objectForKey:@"fashion"]];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"insta_fashion"  // Event action (required)
                                                                   label:nil         // Event label
                                                                   value:nil] build]];    // Event value
            break;
            
        case FITNESS:
            [self shareToInstaWith:[dictResults objectForKey:@"fitness"]];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"insta_fitness"  // Event action (required)
                                                                   label:nil         // Event label
                                                                   value:nil] build]];    // Event value
            break;
            
        case FOOD:
            [self shareToInstaWith:[dictResults objectForKey:@"food"]];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"insta_food"  // Event action (required)
                                                                   label:nil         // Event label
                                                                   value:nil] build]];    // Event value
            break;
            
        case FRIENDS:
            [self shareToInstaWith:[dictResults objectForKey:@"friends"]];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"insta_friends"  // Event action (required)
                                                                   label:nil         // Event label
                                                                   value:nil] build]];    // Event value

            break;
            
        case LOVE:
            [self shareToInstaWith:[dictResults objectForKey:@"love"]];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"insta_love"  // Event action (required)
                                                                   label:nil         // Event label
                                                                   value:nil] build]];    // Event value
            break;
            
        case MAKEUP:
            [self shareToInstaWith:[dictResults objectForKey:@"makeup"]];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"insta_makeup"  // Event action (required)
                                                                   label:nil         // Event label
                                                                   value:nil] build]];    // Event value
            break;
            
        case MEMES:
            [self shareToInstaWith:[dictResults objectForKey:@"memes"]];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"insta_memes"  // Event action (required)
                                                                   label:nil         // Event label
                                                                   value:nil] build]];    // Event value
            break;
            
        case NATURE:
            [self shareToInstaWith:[dictResults objectForKey:@"nature"]];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"insta_nature"  // Event action (required)
                                                                   label:nil         // Event label
                                                                   value:nil] build]];    // Event value
            break;
            
        case PARTYING:
            [self shareToInstaWith:[dictResults objectForKey:@"partying"]];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"insta_partying"  // Event action (required)
                                                                   label:nil         // Event label
                                                                   value:nil] build]];    // Event value
            break;
            
        case PETS:
            [self shareToInstaWith:[dictResults objectForKey:@"pets"]];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"insta_pets"  // Event action (required)
                                                                   label:nil         // Event label
                                                                   value:nil] build]];    // Event value
            break;
            
        case PHOTOGRAPHY:
            [self shareToInstaWith:[dictResults objectForKey:@"photography"]];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"insta_photography"  // Event action (required)
                                                                   label:nil         // Event label
                                                                   value:nil] build]];    // Event value
            break;
            
        case SELFIES:
            [self shareToInstaWith:[dictResults objectForKey:@"selfies"]];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                                  action:@"insta_selfies"  // Event action (required)
                                                                   label:nil         // Event label
                                                                   value:nil] build]];    // Event value
            break;
    }
}

- (void)shareToInstaWith: (NSString *)str
{
    // Wonderfully messy code follows.
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        // Setting up hashtags
        NSString *emptyString = @"⠀";
        NSString *otherString = @"☛ Get @StickieApp ••";
        NSString *hashtags = [NSString stringWithFormat:@"%@\r%@", emptyString, otherString];
        NSArray *tags = [[NSArray alloc] initWithArray:[[SKAssetURLTagsMap sharedInstance] getTagsForAssetURL:_url]];
        NSMutableString *customtags = [NSMutableString stringWithString:@""];
        for (int i = 0; i < [tags count]; i++) {
            [customtags appendString:@"#"];
            [customtags appendString:[((SKImageTag*)tags[i]) tagName]];
            [customtags appendString:@" "];
        }
        [customtags appendString:str];
        NSString *newString = [NSString stringWithFormat:@"%@\r%@", hashtags,customtags];
        _docFile.delegate=self;
        _docFile.UTI = @"com.instagram.exclusivegram";
        _docFile.annotation=[NSDictionary dictionaryWithObjectsAndKeys:newString,@"InstagramCaption", nil];
        dispatch_sync(loadImageToShare, ^(void){
            [_docFile presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
        });
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"customInsta"]) {
        UINavigationController *navController = segue.destinationViewController;
        SKCustomIGViewController *customIGViewController = navController.childViewControllers[0];
        customIGViewController.customChoice = _customChoice;
        customIGViewController.docFile = _docFile;
    }
}

@end
