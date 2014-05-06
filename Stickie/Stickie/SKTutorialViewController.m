//
//  SKTutorialViewController.m
//  Stickie
//
//  Created by Stephen Z on 4/15/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKTutorialViewController.h"

@interface SKTutorialViewController ()

@end

@implementation SKTutorialViewController

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
    
    self.backgroundImageView.image = [UIImage imageNamed:self.imageFile];
    [self.startButton setCenter:CGPointMake(self.startButton.center.x, self.view.frame.size.height - 100)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
