//
//  MapViewController.m
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-04-12.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#import "MapViewController.h"
#import "util.h"
#import "DDAnnotationView.h"
#import "tpsAppDelegate.h"
#import "DDAnnotation.h"

@interface MapViewController ()

@end

@implementation MapViewController
@synthesize firstTime=_firstTime;
@synthesize mvc=_mvc;
@synthesize mapView = _mapView;
@synthesize searchbar=_searchbar;
@synthesize centerMapButton=_centerMapButton;
@synthesize ddMarker=_ddMarker;
@synthesize ddMarkerPresent=_ddMarkerPresent;
@synthesize doneButton=_doneButton;
@synthesize clearButton=_clearButton;
@synthesize forwardGeocoder=_forwardGeocoder;
@synthesize searchResult=_searchResult;
@synthesize placeTextField=_placeTextField;
@synthesize picker=_picker;
@synthesize placeDropdownButton=_placeDropdownButton;
@synthesize data=_data;
@synthesize chosenPickerIndex=_chosenPickerIndex;
@synthesize placeJson=_placeJson;
@synthesize originalPickerY=_originalPickerY;
@synthesize morePlacesUrl=_morePlacesUrl;
@synthesize keyboardToolbar=_keyboardToolbar;
@synthesize keyboardDoneButton=_keyboardDoneButton;
@synthesize keyboardCancelButton=_keyboardCancelButton;
@synthesize delegate=_delegate;
@synthesize navbar=_navbar;
@synthesize request=_request;

#define kInitViewPosition  -480*1.5
#define kOpenViewDuration 0.3

#define PLACEHOLDER_PICK_A_PLACE @"pick a place or search"
#define PLACEHOLDER_DROP_THE_PIN @"drop pin then select a place"
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id) initWithCoder:(NSCoder *) coder 
{
    self = [super initWithCoder:coder];
    if (self) {
        // Custom initialization
    }
    _data=[NSMutableArray arrayWithCapacity:0];
    _placeJson=nil;
    _originalPickerY=0.0;
    _morePlacesUrl=nil;
    _delegate=nil;
    _firstTime=YES;
    return self;
}

#pragma mark 3.1X backwards compatible
static inline CLLocationCoordinate2D CLLocationCoordinate2DInlineMake(CLLocationDegrees latitude, CLLocationDegrees longitude)
{
	CLLocationCoordinate2D coord;
	coord.latitude = latitude;
	coord.longitude = longitude;
	return coord;
}
#define CLLocationCoordinate2DMake CLLocationCoordinate2DInlineMake
-(void) setMapWithDimensions:(MKMapView*) map lat:(double)_lat lng:(double)_lng spanLat:(double)_slat spanLng:(double)_slng
{
	TGLog(@"%f,%f - %f,%f", _lat, _lng, _slat, _slng);
	MKCoordinateRegion region;
	MKCoordinateSpan span;	
	span.latitudeDelta=_slat;
	span.longitudeDelta=_slng;	
    
	CLLocationDegrees latitude  = _lat;
	CLLocationDegrees longitude = _lng;
	CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);	
    
	CLLocationCoordinate2D location=coordinate;
	region.span=span;
	region.center=location;	
	[map setRegion:region animated:TRUE];
	[map regionThatFits:region];	
}

-(void) showUser
{
	MKCoordinateRegion region;
	MKCoordinateSpan span;	
	span.latitudeDelta=0.05;
	span.longitudeDelta=0.05;	
	CLLocationCoordinate2D location=_mapView.userLocation.location.coordinate;
	region.span=span;
	region.center=location;	
	[_mapView setRegion:region animated:TRUE];
	[_mapView regionThatFits:region];	
    
    _ddMarker.coordinate=location;

}


-(IBAction) centerMapButtonPressed:(id) sender
{
	TGLog(@"");
#if (TARGET_IPHONE_SIMULATOR)
    // ottawa
	[self setMapWithDimensions:_mapView lat:45.40761 lng:-75.700264 spanLat:0.20 spanLng:0.20];
#else
	[self showUser];
#endif	
}


-(void) openView
{
	[UIView beginAnimations:@"openView" context:nil];
	[UIView setAnimationDuration:kOpenViewDuration];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	self.view.center=CGPointMake(self.view.center.x, 480/2+10);
	[UIView commitAnimations];	
    
}
-(void) closeView
{    
	[UIView beginAnimations:@"closeView" context:nil];
	[UIView setAnimationDuration:kOpenViewDuration];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	self.view.center=CGPointMake(self.view.center.x,kInitViewPosition);
	[UIView commitAnimations];	
    
    // save map location on close
    tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
	//appdel.sd.lat=[NSNumber numberWithDouble:self.mapView.centerCoordinate.latitude];
	//appdel.sd.lng=[NSNumber numberWithDouble:self.mapView.centerCoordinate.longitude];
	appdel.sd.lat=[NSNumber numberWithDouble:_ddMarker.coordinate.latitude];
	appdel.sd.lng=[NSNumber numberWithDouble:_ddMarker.coordinate.longitude];
	appdel.sd.spanLat=[NSNumber numberWithDouble:self.mapView.region.span.latitudeDelta];
	appdel.sd.spanLng=[NSNumber numberWithDouble:self.mapView.region.span.longitudeDelta];
    
    appdel.sd.placeJson=_placeJson;
    if (_delegate) [_delegate mvcLocationSelected:_placeTextField.text];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
	self.view.center=CGPointMake(self.view.center.x,kInitViewPosition);
    _doneButton.action=@selector(doneButtonPressed:);
    _clearButton.action=@selector(clearButtonPressed:);

    _originalPickerY=_picker.center.y;
    [self closePicker];
    
#if 0
    // for ios3.0 when *not* using MKPinAnnotationView
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                          selector:@selector(pinChanged:) 
                                          name: kDDAnnotationCoordinateDidChangeNotification
                                          object:nil];
#endif

    _placeTextField.inputAccessoryView = self.keyboardToolbar;
    _keyboardDoneButton.target = self;
    _keyboardDoneButton.action = @selector(keyboardDoneButtonPressed);
    _keyboardCancelButton.target = self;
    _keyboardCancelButton.action = @selector(dismissKeyboard);
    
    _placeTextField.placeholder=PLACEHOLDER_DROP_THE_PIN;

    tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appdel.sd.lat floatValue]!=0.0)
    {
        [self setMapWithDimensions:_mapView 
                               lat:[appdel.sd.lat doubleValue] lng:[appdel.sd.lng doubleValue]
                           spanLat:[appdel.sd.spanLat doubleValue] spanLng:[appdel.sd.spanLng doubleValue]];
        _placeJson=appdel.sd.placeJson;
        _placeTextField.text=[_placeJson valueForKey:@"name"];
        [_delegate mvcLocationSelected:_placeTextField.text];
    }
    
    _navbar.tintColor = RGB(51, 75, 125);

}
-(void) createDroppedPin:(CLLocationCoordinate2D) coordinate
{
    // create droppin here so the map is already loaded
	_ddMarker = [[DDAnnotation alloc] initWithCoordinate:coordinate addressDictionary:nil];
	_ddMarker.title = DroppedPinTag;
	[_mapView addAnnotation:_ddMarker];	
    
    // select annoatation so the user doesnt have to touch twice to move it
    [_mapView selectAnnotation:_ddMarker animated:FALSE]; // will invoke a get

}
-(void) removeDroppedPin
{		
    [_mapView removeAnnotation:_ddMarker];			
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self createDroppedPin:_mapView.centerCoordinate];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle: nil];
    _mvc=(MessageViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"MVC"];
    
}
-(void) viewDidDisappear:(BOOL)animated
{
    if (_request) _request.delegate=nil;
    _ddMarker=nil;
    _delegate=nil;
    _mvc=nil;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [_data removeAllObjects];
    _data=nil;
    _placeJson=nil;
    _morePlacesUrl=nil;
    _mvc=nil;
    _ddMarker=nil;
    _searchResult=nil;
    _forwardGeocoder=nil;
    
    TGLog(@"%@", _mapView);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)doneButtonPressed:(id)sender
{
    [self closeView];
}
-(IBAction)clearButtonPressed:(id)sender
{
    _placeJson=nil;
    _placeTextField.text=nil;
    _placeTextField.placeholder=PLACEHOLDER_DROP_THE_PIN;
    _searchbar.text=nil;
    [_data removeAllObjects];
    [_picker reloadAllComponents];
}

#pragma mark MAPVIEW DELEGATES
#if 0
- (void)pinChanged:(NSNotification *)notif
{
    TGLog(@"");
    DDAnnotation* ddm=(DDAnnotation*)notif.object;
    [self queryFacebookForPlaceID:ddm.coordinate];
    
    // bring up loading message
    _mvc.message.text=@"Loading Facebook Places...";
    _mvc.messageView.hidden=FALSE;
}
#endif

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	MKAnnotationView* annotationView = nil;
	
	if (annotation == mapView.userLocation){
		return nil; //default to blue dot
	}
    TGLog(@"");
	// check for pin anno first
	// it has a specific title
	if ([annotation.title isEqual:DroppedPinTag])
	{
        TGLog(@"");
		static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
		MKAnnotationView *draggablePinView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
		
		if (draggablePinView) {
			draggablePinView.annotation = annotation;
			//DDAnnotation* ddm=(DDAnnotation*)annotation;
			TGLog(@"draggable present %f,%f", annotation.coordinate.latitude, annotation.coordinate.longitude);
			//ddm.subtitle = [NSString stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
			draggablePinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			return draggablePinView;
        } else {
            // Use class method to create DDAnnotationView (on iOS 3) or built-in draggble MKPinAnnotationView (on iOS 4).
            draggablePinView = [DDAnnotationView annotationViewWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier mapView:self.mapView];
			
			if ([draggablePinView isKindOfClass:[DDAnnotationView class]]) {
				// draggablePinView is DDAnnotationView on iOS 3.
				TGLog(@"new draggable rel3");
			} else {
				// draggablePinView instance will be built-in draggable MKPinAnnotationView when running on iOS 4.
				TGLog(@"new draggable rel4");
			}
			return draggablePinView;
		}	
	}
    
	return annotationView;		
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    TGLog(@"");
 	if ([view annotation] == mapView.userLocation){
		return;
	}
    
	// check for pin first because it doesnt have userObject
	DDAnnotation* ddm=(DDAnnotation*)view.annotation;
	if ([ddm.title isEqual:DroppedPinTag])
	{
		//ddm.subtitle = [NSString stringWithFormat:@"%f %f", ddm.coordinate.latitude, ddm.coordinate.longitude];
        if (view.selected)
        {
            TGLog(@"pin dropped");
            [self queryFacebookForPlaceID:ddm.coordinate withQuery:nil];
                        
        } else {
            TGLog(@"pin just selected");
        }
		return;
	}

}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	TGLog(@"calloutAccessoryControlTapped");
    
	// check for pin first because it doesnt have userObject
	DDAnnotation* ddm=(DDAnnotation*)view.annotation;
	if ([ddm.title isEqual:DroppedPinTag])
	{
		TGLog(@"pin callout tapped");
		return;
	}
	
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{	
	TGLog(@"");
	// check for pin anno first
	// it has a specific title
	DDAnnotationView* ddm=(DDAnnotationView*)view;
	if ([ddm.annotation.title isEqual:DroppedPinTag])
	{
	}
	return;
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
}

#pragma mark SEARCH DELEGATE
-(void)forwardGeocoderError:(NSString *)errorMessage
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" 
													message:errorMessage
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	
}

-(void)forwardGeocoderFoundLocation
{
	TGLog(@"");
	if(_forwardGeocoder.status == G_GEO_SUCCESS)
	{
		//int searchResults = [forwardGeocoder.results count];
		
#if 0      
		// Add placemarks for each result
		for(int i = 0; i < searchResults; i++)
		{
			BSKmlResult *place = [forwardGeocoder.results objectAtIndex:i];
            
			// Add a placemark on the map
			CustomPlacemark *placemark = [[[CustomPlacemark alloc] initWithRegion:place.coordinateRegion] autorelease];
			placemark.title = place.address;
			//placemark.subtitle = place.countryName;
			[mapView addAnnotation:placemark];	
            
			NSArray *countryName = [place findAddressComponent:@"country"];
			if([countryName count] > 0)
			{
				NSLog(@"Country: %@", ((BSAddressComponent*)[countryName objectAtIndex:0]).longName );
			}
		}
#endif		
		if([_forwardGeocoder.results count] == 1)
		{
			BSKmlResult *place = [_forwardGeocoder.results objectAtIndex:0];
			TGLog(@"found %f,%f", place.coordinate.latitude, place.coordinate.longitude);
            
            // drop pin here
            _ddMarker.coordinate=place.coordinate;
            // do a facebook places search here
            [self queryFacebookForPlaceID:place.coordinate withQuery:nil];
            _placeTextField.text=nil; // clear this so placemarker is shown

            // Zoom into the location		
			[_mapView setRegion:place.coordinateRegion animated:TRUE];
            
            // dismiss options view
            [self viewWillDisappear:YES];
            
		}
		
		// Dismiss the keyboard
		[_searchbar resignFirstResponder];
	}
	else {
		NSString *message = @"";
		
		switch (_forwardGeocoder.status) {
			case G_GEO_BAD_KEY:
				message = @"The API key is invalid.";
				break;
				
			case G_GEO_UNKNOWN_ADDRESS:
				message = [NSString stringWithFormat:@"Could not find %@", _forwardGeocoder.searchQuery];
				break;
				
			case G_GEO_TOO_MANY_QUERIES:
				message = @"Too many queries has been made for this API key.";
				break;
				
			case G_GEO_SERVER_ERROR:
				message = @"Server error, please try again.";
				break;
				
				
			default:
				break;
		}
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information" 
														message:message
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
	}
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	
	TGLog(@"Searching for: %@", _searchbar.text);
	if(_forwardGeocoder == nil)
	{
		_forwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
	}
	
	// Forward geocode!
	[_forwardGeocoder findLocation:_searchbar.text];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    TGLog(@"");
	[UIView beginAnimations:@"keyboardmove" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    _searchbar.center=CGPointMake(_searchbar.center.x, _searchbar.center.y-215);
    
    _keyboardToolbar.center=CGPointMake(_searchbar.center.x, _searchbar.center.y-44);
    _keyboardToolbar.hidden=FALSE;
    _keyboardDoneButton.enabled=FALSE;
    
	[UIView commitAnimations];
    
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    TGLog(@"");
	[UIView beginAnimations:@"keyboardmove" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    _searchbar.center=CGPointMake(_searchbar.center.x, _searchbar.center.y+215);
    _keyboardToolbar.hidden=TRUE;
    _keyboardDoneButton.enabled=TRUE;
	[UIView commitAnimations];
}

#pragma mark FACEBOOK PLACES 
-(void) placeButtonAction
{
    TGLog(@"");
    if (_picker.center.y<0)
    {
        [self openPicker];
    } else {
        [self closePicker];
    }
}
-(IBAction)placeDropdownButtonPressed:(id)sender
{
    [self placeButtonAction];
}
-(IBAction)placeTextFieldSelected:(id)sender
{
    [self placeButtonAction];
}
- (void)dismissKeyboard
{
    [_placeTextField resignFirstResponder];
    [_searchbar resignFirstResponder];
}
- (void)keyboardDoneButtonPressed
{
    [_placeTextField resignFirstResponder];
    // perform facebook places search with string
    [self queryFacebookForPlaceID:_ddMarker.coordinate withQuery:_placeTextField.text];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    TGLog(@"");
#if 0
    // return NO to not allow editing
    // allows us to still have user interaction enabled
    return NO;
#endif
    // we're allowing to search facebook places with string
    _keyboardToolbar.hidden=FALSE;
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    TGLog(@"");
    _keyboardToolbar.hidden=TRUE;
}

#pragma mark picker delegates
#pragma mark Picker View Protocol
-(void) openPicker
{
   	[UIView beginAnimations:@"openPicker" context:nil];
	[UIView setAnimationDuration:kOpenViewDuration];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	_picker.center=CGPointMake(_picker.center.x, _originalPickerY);
	[UIView commitAnimations];	
    [_placeDropdownButton setImage:[UIImage imageNamed:@"toolbar_uparrow.png"] forState:UIControlStateNormal];
 
}
-(void) closePicker
{
    [UIView beginAnimations:@"closePicker" context:nil];
	[UIView setAnimationDuration:kOpenViewDuration];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	_picker.center=CGPointMake(_picker.center.x, -(_picker.frame.size.height));
	[UIView commitAnimations];	
    [_placeDropdownButton setImage:[UIImage imageNamed:@"toolbar_downarrow.png"] forState:UIControlStateNormal];

}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	TGLog(@"");
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    int rows=0;
    if (_morePlacesUrl!=nil) rows= [_data count]+1; // plus more row
	else rows= [_data count];
	TGLog(@"%d count %d", rows, [_data count]);
    return rows;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	TGLog(@"row %d", row);
    if (row >= [_data count]) return @"more...";
    NSDictionary* place=[_data objectAtIndex:row];
	return [place objectForKey:@"name"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (row >= [_data count])
    {
        [self queryFacebookForMorePlaces];
        return;
    }
	TGLog(@"%@", [_data objectAtIndex:row]);
	_chosenPickerIndex=row;
	//[self closePicker];
    NSDictionary* place=[_data objectAtIndex:row];
    _placeJson=place;
    _placeTextField.text=[_placeJson objectForKey:@"name"];
}

-(void) showMessageView:(NSString*) msg
{
    _mvc.text=msg;
    _mvc.msg.text=msg;
    [self.view addSubview:_mvc.view];
    [self.view bringSubviewToFront:_mvc.view];
}
-(void) removeMessageView
{
    [_mvc.view removeFromSuperview];
}


#pragma mark HTTP POST METHODS
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self removeMessageView];
    
	// Use when fetching text data
	NSString *responseString = [request responseString];
	//TGLog(@"%@", responseString);
	
	// Use when fetching binary data
	//NSData *responseData = [request responseData];
	    
    NSError* error = NULL;
	SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
	NSDictionary *feed = (NSDictionary *)[jsonParser objectWithString:responseString error:&error];
    if (error!=NULL)
    {
        TGLog(@"JSON err: %@", error);
        return;
    }
    NSArray* data=[feed objectForKey:@"data"];
    if (data==nil)
    {
        TGLog(@"no data %@", responseString);
        return;
    }

	NSDictionary* place;
    for (place in data)
    {
        TGLog(@"%@", place);
        if (error!=NULL)
        {
            TGLog(@"JSON err: %@", error);
            return;
        }
        [_data addObject:place];
    }
    NSDictionary* morePlaces=[feed objectForKey:@"paging"];
    if (morePlaces!=nil) _morePlacesUrl=[morePlaces objectForKey:@"next"];
    else _morePlacesUrl=nil;
    
    [_picker reloadAllComponents];

    if ([_data count]==0 && !_firstTime)
    {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"Sorry" 
                                                      message:@"There's no Facebook Places here."
                                                     delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    _firstTime=NO;

    _placeTextField.placeholder=PLACEHOLDER_PICK_A_PLACE;
}
- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
	//TGLog(@"%d", bytes);
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self removeMessageView];
	NSError *error = [request error];
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"Facebook Search Error" 
                                                  message:@"Please check your internet connection"
                                                 delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
	TGLog(@"%@", error);
}

-(BOOL) queryFacebookForMorePlaces
{
    if (!_morePlacesUrl) return FALSE;
    [self showMessageView:@"Loading Places..."];
    TGLog(@"%@", _morePlacesUrl);
    NSURL *url = [NSURL URLWithString:_morePlacesUrl];
	_request = [ASIFormDataRequest requestWithURL:url];    
    [_request setTimeOutSeconds:10];
    [_request setDelegate:self];
	//[request setUploadProgressDelegate:progress];
	//request.showAccurateProgress=YES;
	[_request startAsynchronous];
	return TRUE;
}
-(BOOL) queryFacebookForPlaceID:(CLLocationCoordinate2D) coordinate withQuery:(NSString*)query
{
    // bring up loading message
    tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
    [self showMessageView:@"Loading Places..."];

    [_data removeAllObjects];
    //https://graph.facebook.com/search?q=ritual&type=place&center=37.76,-122.427&distance=1000&access_token=mytoken
    
    if (![appdel checkFaceBook]) return FALSE;
    
    NSString* centerStr=[NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude];
    // have to put it all into a URL
    NSString* urlStr=[NSString stringWithFormat:@"https://graph.facebook.com/search?"];
    if (query!=nil)
    {
        urlStr=[urlStr stringByAppendingFormat:@"q=%@&", query];
    }
    urlStr=[urlStr stringByAppendingFormat:@"type=place&center=%@&distance=1000&access_token=%@", centerStr,appdel.facebook.accessToken];
    NSURL *url = [NSURL URLWithString:urlStr];
	_request = [ASIFormDataRequest requestWithURL:url];
    
    TGLog(@"%@", urlStr);
    
    //[request setPostValue:@"searchterm" forKey:@"q"]; // narrow search by name
    //[request setPostValue:@"place" forKey:@"type"];
    //[request setPostValue:centerStr forKey:@"center"];
    //[request setPostValue:@"1000" forKey:@"distance"];
    
    //[request setAllowCompressedResponse:YES];
    
    // do it!
    [_request setTimeOutSeconds:10];
    [_request setDelegate:self];
	//[request setUploadProgressDelegate:progress];
	//request.showAccurateProgress=YES;
	[_request startAsynchronous];
    
	return TRUE;
}

@end
