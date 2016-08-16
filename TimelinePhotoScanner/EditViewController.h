//
//  ResultViewController.h
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-02-23.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFPhotoEditorController.h"

@interface EditViewController : UIViewController <AFPhotoEditorControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView* iv;
@property (strong, nonatomic) UIImage* image;
@property (strong, nonatomic) UIButton* editButton;
@property (strong, nonatomic) NSMutableArray* sessions;
@end
