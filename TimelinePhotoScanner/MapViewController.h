//
//  MapViewController.h
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-04-12.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DDAnnotation.h"
#import "BSForwardGeocoder.h"
#import "BSKmlResult.h"
#import "MessageViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@protocol mvcProtocolDelegate;


@interface MapViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate, UIPickerViewDelegate, UITextFieldDelegate >
@property (weak, nonatomic) IBOutlet MKMapView*  mapView;
@property (weak, nonatomic) IBOutlet UISearchBar* searchbar;
@property (weak, nonatomic) IBOutlet UIButton* centerMapButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* clearButton;
@property (weak, nonatomic) IBOutlet UITextField* placeTextField;
@property (weak, nonatomic) IBOutlet UIPickerView* picker;
@property (weak, nonatomic) IBOutlet UIButton* placeDropdownButton;
@property (weak, nonatomic) IBOutlet UIToolbar *keyboardToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *keyboardDoneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *keyboardCancelButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navbar;

@property (strong, nonatomic) NSMutableArray* data;
@property (strong, nonatomic) NSDictionary* placeJson;
@property (strong, nonatomic) NSString* morePlacesUrl;
@property (strong, nonatomic) MessageViewController* mvc;
@property id <mvcProtocolDelegate>delegate;
@property BOOL firstTime;
@property int chosenPickerIndex;
@property float originalPickerY;

// for pin drop
@property (strong, nonatomic) DDAnnotation* ddMarker;
@property (strong, nonatomic) BSKmlResult* searchResult;
@property (strong, nonatomic) BSForwardGeocoder* forwardGeocoder;
@property BOOL ddMarkerPresent;
@property (strong, nonatomic) ASIFormDataRequest* request;

-(void) openView;
-(void) closeView;
-(IBAction)centerMapButtonPressed:(id)sender;
-(IBAction)doneButtonPressed:(id)sender;
-(IBAction)clearButtonPressed:(id)sender;
-(IBAction)placeDropdownButtonPressed:(id)sender;
-(IBAction)placeTextFieldSelected:(id)sender;
- (void)pinChanged:(NSNotification *)notif;

#define DroppedPinTag @"Hold Pin To Move"

@end
@protocol mvcProtocolDelegate
- (void) mvcLocationSelected:(NSString *)name;
@end

