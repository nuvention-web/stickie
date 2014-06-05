//
//  SKCustomIGViewController.m
//  Stickie
//
//  Created by Grant Sheldon on 5/8/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKCustomIGViewController.h"
#import "SKAssetURLTagsMap.h"

@interface SKCustomIGViewController () <UIDocumentInteractionControllerDelegate> {
    BOOL canAddTags;
    int hash_count;
}

@property (weak, nonatomic) IBOutlet UILabel *tagCountLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

typedef void (^ButtonCompletionBlock)(BOOL finished);

@implementation SKCustomIGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_textView setKeyboardType:UIKeyboardTypeTwitter];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(5, 102, self.view.bounds.size.width-10, 0.5)];
    lineView.backgroundColor = [UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:179.0/255.0 alpha:1.0];
    [self.view addSubview:lineView];

    NSData *currentData =[[NSUserDefaults standardUserDefaults] objectForKey:_customChoice];
    NSString *currentHashtags = [NSKeyedUnarchiver unarchiveObjectWithData:currentData];
    if (!currentHashtags) currentHashtags = @"";
    _textView.text = currentHashtags;
    
    //To make the border look very close to a UITextField
//    [_textView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
//    [_textView.layer setBorderWidth:2.0];
    
//    //The rounded corner part, where you specify your view's corner radius:
//    _textView.layer.cornerRadius = 5;
//    _textView.clipsToBounds = YES;
    
    hash_count = (int)[[_textView.text componentsSeparatedByString:@"#"] count]-1;
    _tagCountLabel.text = [NSString stringWithFormat:@"TAGS: %d of 30", hash_count];
    
    _textView.delegate = self;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (hash_count > 29 && [text isEqualToString:@"#"]) {
        [self animateNoMoreHashtagsForTime:0.35 completion:^(BOOL done) {}];
        return NO;
    } else {
        return YES;
    }
}

- (void)animateNoMoreHashtagsForTime:(NSTimeInterval)time completion:(ButtonCompletionBlock)block
{
    [UIView animateWithDuration:(time/2.0) animations:^{
        [self.view setBackgroundColor:[[UIColor redColor] colorWithAlphaComponent:0.9]];
    } completion:^(BOOL finished){
        [UIView animateWithDuration:(time/2.0) animations:^{
            [self.view setBackgroundColor:[UIColor whiteColor]];
            block(YES);
        }];
    }];
}

- (void)viewWillAppear:(BOOL)flag {
    [super viewWillAppear:flag];
    [_textView becomeFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView {
    hash_count = (int)[[_textView.text componentsSeparatedByString:@"#"] count]-1;
    _tagCountLabel.text = [NSString stringWithFormat:@"TAGS: %d of 30", hash_count];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonTapped:(id)sender {
    NSData *finalData = [NSKeyedArchiver archivedDataWithRootObject:_textView.text];
    [[NSUserDefaults standardUserDefaults] setObject:finalData forKey:_customChoice];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submitButtonTapped:(id)sender {
    NSData *finalData = [NSKeyedArchiver archivedDataWithRootObject:_textView.text];
    [[NSUserDefaults standardUserDefaults] setObject:finalData forKey:_customChoice];
    [self shareToInstaWith:_textView.text noBS:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)shareToInstaWith: (NSString *)str noBS:(BOOL)noBS
{
    //    UIImage* instaImage = [self thumbnailFromView:imageView]; //Full Image Low Resolution
    _docFile.delegate=self;
    _docFile.UTI = @"com.instagram.exclusivegram";
    _docFile.annotation=[NSDictionary dictionaryWithObjectsAndKeys:str,@"InstagramCaption", nil];
    [_docFile presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
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
