//
//  PlayersViewController.h
//  Stickie
//
//  Created by Stephen Z on 1/15/14.
//  Copyright (c) 2014 Stephen Z. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerDetailsViewController.h"

@interface PlayersViewController : UITableViewController <PlayerDetailsViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *players;

@end
