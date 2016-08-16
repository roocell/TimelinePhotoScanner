//
//  MessageViewController.h
//  Mobile Playlist Client
//
//  Created by michael russell on 12-01-25.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView* msgView;
@property (weak, nonatomic) IBOutlet UILabel* msg;
@property (strong, nonatomic) NSString* text;
@end
