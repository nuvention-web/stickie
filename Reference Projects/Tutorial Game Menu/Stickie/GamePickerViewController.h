//
//  GamePickerViewController.h
//  Stickie
//
//  Created by Stephen Z on 1/17/14.
//  Copyright (c) 2014 Stephen Z. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  GamePickerViewController;

@protocol GamePickerViewControllerDelegate <NSObject>
- (void)gamePickerViewController:(GamePickerViewController *)controller didSelectGame:(NSString *)game;
@end

@interface GamePickerViewController : UITableViewController

@property (nonatomic, weak) id <GamePickerViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *game;

@end
