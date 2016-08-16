//
//  DetailsViewController.h
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-04-12.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "SSTextView.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface DetailsViewController : UIViewController <UITextFieldDelegate, mvcProtocolDelegate>

@property (weak, nonatomic) IBOutlet UIImageView* iv;
@property (weak, nonatomic) IBOutlet UITextField* location;
@property (weak, nonatomic) IBOutlet SSTextView* textview;
@property (weak, nonatomic) IBOutlet UIDatePicker* picker;
@property (weak, nonatomic) IBOutlet UIProgressView* loader;
@property (weak, nonatomic) IBOutlet UIToolbar *keyboardToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *keyboardDoneButton;
@property (strong, nonatomic) UIButton* mapButton;
@property (strong, nonatomic) UIBarButtonItem* uploadButton;
@property (strong, nonatomic) MapViewController* mapView;
@property (strong, nonatomic) ASIFormDataRequest *uploadRequest;
@property (strong, nonatomic) UIImage* image;

-(IBAction)pickerChanged:(id)sender;
-(IBAction)uploadButtonPressed:(id)sender;
-(BOOL) postPhoto;
-(IBAction) locationTextFieldTouched:(id)sender;
@end
