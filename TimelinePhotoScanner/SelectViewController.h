//
//  SelectViewController.h
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-02-23.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZoomWindow.h"
#import "BoundingBox.h"
#import "MessageViewController.h"
#import "tpsOpenCv.h"

@interface SelectViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView* iv;
@property (weak, nonatomic) IBOutlet UIView* container;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* nextButton;
@property (retain,nonatomic) UIImage* image;
@property (retain, nonatomic) UIImage* zimage;
@property (retain, nonatomic) ZoomWindow* zw;
@property (retain, nonatomic) BoundingBox* bb;
@property (strong, nonatomic) MessageViewController* mvc;
@property (retain, nonatomic) UIButton* skipButton;
@property (retain, nonatomic) tpsOpenCv* opencv; // must be retain
@end
