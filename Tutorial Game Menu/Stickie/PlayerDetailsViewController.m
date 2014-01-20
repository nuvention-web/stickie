//
//  PlayersDetailViewController.m
//  Stickie
//
//  Created by Stephen Z on 1/15/14.
//  Copyright (c) 2014 Stephen Z. All rights reserved.
//

#import "PlayerDetailsViewController.h"
#import "Player.h"

@implementation PlayerDetailsViewController
{
    NSString *_game;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super initWithCoder:aDecoder])) {
        NSLog(@"init PlayerDetailsViewController");
        _game = @"Chess";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailLabel.text = _game;
}

- (IBAction)cancel:(id)sender
{
    [self.delegate playerDetailsViewControllerDidCancel:self];
}

- (IBAction)done:(id)sender
{
    Player *player = [Player new];
    player.name = self.nameTextField.text;
    player.game = _game;
    player.rating = 1;
    [self.delegate playerDetailsViewController:self didAddPlayer:player];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0) {
        [self.nameTextField becomeFirstResponder];
    }
}

-(void)dealloc
{
    NSLog(@"dealloc PlayerDetailsViewController");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickGame"]) {
        GamePickerViewController *gamePickerViewController = segue.destinationViewController;
        gamePickerViewController.delegate = self;
        gamePickerViewController.game = _game;
    }
}

- (void)gamePickerViewController:(GamePickerViewController *)controller didSelectGame:(NSString *)game
{
    _game = game;
    self.detailLabel.text = _game;
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
