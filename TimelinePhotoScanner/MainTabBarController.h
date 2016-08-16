//
//  MainTabBarController.h
//  Mobile Playlist Client
//
//  Created by michael russell on 11-12-19.
//  Copyright (c) 2011 Thumb Genius Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;
@class HistoryViewController;
@class CaptureViewController;

@interface MainTabBarController : UITabBarController

@property (strong, nonatomic) SettingsViewController*  svc;
@property (strong, nonatomic) HistoryViewController*  hvc;
@property (strong, nonatomic) CaptureViewController*  cvc;


@end
