//
//  PlayerCell.h
//  Stickie
//
//  Created by Stephen Z on 1/15/14.
//  Copyright (c) 2014 Stephen Z. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *gameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *ratingImageView;

@end
