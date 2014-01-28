//
//  PlayerDetailViewController.h
//  Stickie
//
//  Created by Stephen Z on 1/15/14.
//  Copyright (c) 2014 Stephen Z. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GamePickerViewController.h"

@class PlayerDetailsViewController;
@class Player;

@protocol PlayerDetailsViewControllerDelegate <NSObject>
- (void)playerDetailsViewControllerDidCancel:(PlayerDetailsViewController *)controller;
- (void)playerDetailsViewController:(PlayerDetailsViewController *)controller didAddPlayer:(Player *)player;
@end

@interface PlayerDetailsViewController : UITableViewController <GamePickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) id <PlayerDetailsViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@end
