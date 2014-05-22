//
//  SKMenuViewController.m
//  Stickie
//
//  Created by Grant on 5/20/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import "SKMenuViewController.h"
#import "SWRevealViewController.h"

@interface SKMenuViewController ()

@end

typedef enum {
    SKMenuSectionSettings = 0, SKMenuSectionOptions = 1, SKMenuSectionFeedback = 2
} SKMenuSection;

@implementation SKMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SKMenuSectionSettings:
            return 3;
            break;
        case SKMenuSectionOptions:
            return 4;
            break;
        case SKMenuSectionFeedback:
            return 2;
            break;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    UISwitch *theSwitch;
    
    switch ([indexPath section]) {
        case SKMenuSectionSettings:
            cell = [tableView dequeueReusableCellWithIdentifier:@"ToggleCell"];
            theSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(cell.frame.size.width - 125.0, 10.0, 0.0, 0.0)];
            theSwitch.transform = CGAffineTransformMakeScale(0.85, 0.85);
            [cell.contentView addSubview:theSwitch];
            if ([indexPath row] == 0) {
                cell.textLabel.text = @"Photostream Media";
            }
            else if ([indexPath row] == 1) {
                cell.textLabel.text = @"InstaLikes+";
            }
            else if ([indexPath row] ==2) {
                cell.textLabel.text = @"Quick MultiTag";
            }
            break;
        case SKMenuSectionOptions:
            cell = [tableView dequeueReusableCellWithIdentifier:@"TapCell"];
            if ([indexPath row] == 0) {
                cell.textLabel.text = @"MultiTag";
            }
            else if ([indexPath row] == 1) {
                cell.textLabel.text = @"Show Tutorial";
            }
            else if ([indexPath row] == 2) {
                cell.textLabel.text = @"About Stickie";
            }
            else if ([indexPath row] == 3) {
                cell.textLabel.text = @"FAQ";
            }
            break;
        case SKMenuSectionFeedback:
            cell = [tableView dequeueReusableCellWithIdentifier:@"TapCell"];
            if ([indexPath row] == 0) {
                cell.textLabel.text = @"Tell Us How We're Doing!";
            }
            else {
                cell.textLabel.text = @"Rate Stickie";
            }
            break;
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SKMenuSectionSettings:
            return @"Settings";
            break;
        case SKMenuSectionOptions:
            return @"Options";
            break;
        case SKMenuSectionFeedback:
            return @"Feedback";
            break;
        default:
            return nil;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
