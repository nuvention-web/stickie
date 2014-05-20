//
//  SKCustomIGViewController.h
//  Stickie
//
//  Created by Grant Sheldon on 5/8/14.
//  Copyright (c) 2014 Stickie Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKCustomIGViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) NSString *customChoice;
@property (nonatomic,retain) UIDocumentInteractionController *docFile;

@end