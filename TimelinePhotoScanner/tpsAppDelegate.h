//
//  tpsAppDelegate.h
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-02-23.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

//#define TIMELINE_UPLOAD_LIB

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "MessageViewController.h"
#import "MainTabBarController.h"
#import "SaveData.h"

#ifdef TIMELINE_UPLOAD_LIB
#import "TPTimelineUpload.h"
#endif

@interface tpsAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, 
            FBSessionDelegate, FBRequestDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Facebook *facebook;
@property BOOL loggedIn;
@property (strong, nonatomic) NSString* fbrealname;
@property (strong, nonatomic) UIImage* fbavatar;
@property (strong, nonatomic) UIView* fbLoaderView;
@property (strong, nonatomic) MessageViewController* mvc;
@property (strong, nonatomic) MainTabBarController* tabbar;
@property (strong, nonatomic) SaveData* sd;
#ifdef TIMELINE_UPLOAD_LIB
@property (nonatomic, strong) TPTimelineUpload *timelineUpload;
#endif
-(BOOL) checkFaceBook;
-(void) showMessageView:(NSString*) msg;
-(void) removeMessageView;

@end
