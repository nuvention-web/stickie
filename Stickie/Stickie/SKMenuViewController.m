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

@property (nonatomic, strong) UISwitch* photostreamSwitch;
@property (nonatomic, strong) UISwitch* instalikesSwitch;

@end

typedef enum {
    SKMenuSectionSettings = 0, SKMenuSectionOptions = 1, SKMenuSectionFeedback = 2
} SKMenuSection;

@implementation SKMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _photostreamSwitch = [[UISwitch alloc] init];
    _instalikesSwitch = [[UISwitch alloc] init];
    
    [_photostreamSwitch addTarget:self action:@selector(photostreamToggle:) forControlEvents:UIControlEventValueChanged];
    
    [_instalikesSwitch addTarget:self action:@selector(instalikesToggle:) forControlEvents:UIControlEventValueChanged];
    
    _instalikesSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"instalikesOn"];
    _photostreamSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"photostreamOn"];
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
            return 2;
            break;
        case SKMenuSectionOptions:
            return 3;
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
    
    
    switch ([indexPath section]) {
        case SKMenuSectionSettings:
            cell = [tableView dequeueReusableCellWithIdentifier:@"ToggleCell"];
//            theSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(cell.frame.size.width - 125.0, 10.0, 0.0, 0.0)];
//            theSwitch.transform = CGAffineTransformMakeScale(0.85, 0.85);
//            [cell.contentView addSubview:theSwitch];
            if ([indexPath row] == 0) {
                cell.textLabel.text = @"Sync Photo Stream";
                _photostreamSwitch.frame = CGRectMake(cell.frame.size.width - 125.0, 10.0, 0.0, 0.0);
                _photostreamSwitch.transform = CGAffineTransformMakeScale(0.85, 0.85);
                [cell.contentView addSubview:_photostreamSwitch];
            }
            else if ([indexPath row] == 1) {
                cell.textLabel.text = @"InstaLikes+";
                _instalikesSwitch.frame = CGRectMake(cell.frame.size.width - 125.0, 10.0, 0.0, 0.0);
                _instalikesSwitch.transform = CGAffineTransformMakeScale(0.85, 0.85);
                [cell.contentView addSubview:_instalikesSwitch];
            }
            break;
        case SKMenuSectionOptions:
            cell = [tableView dequeueReusableCellWithIdentifier:@"TapCell"];
            if ([indexPath row] == 0) {
                cell.textLabel.text = @"Tutorial";
            }
            else if ([indexPath row] == 1) {
                cell.textLabel.text = @"About Us";
            }
            else if ([indexPath row] == 2) {
                cell.textLabel.text = @"FAQ";
            }
            break;
        case SKMenuSectionFeedback:
            cell = [tableView dequeueReusableCellWithIdentifier:@"TapCell"];
            if ([indexPath row] == 0) {
                cell.textLabel.text = @"Email CEO";
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

- (void)photostreamToggle:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"photostreamOn"];
}

- (void)instalikesToggle:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"instalikesOn"];
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
