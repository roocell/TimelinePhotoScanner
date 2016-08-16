//
//  DetailsViewController.m
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-04-12.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#import "DetailsViewController.h"
#import "util.h"
#import "tpsAppDelegate.h"
#import "SBJson.h"
#import "Facebook.h"
#import <QuartzCore/QuartzCore.h>
#import "SBJsonWriter.h"
#import "DDAnnotation.h"

#import "MainTabBarController.h"
#import "CaptureViewController.h"

#define ALERT_CANCEL_TITLE @"Cancel"
#define ALERT_COMPLETE_TITLE @"Complete"

@interface DetailsViewController ()

@end

@implementation DetailsViewController
@synthesize location=_location;
@synthesize mapButton=_mapButton;
@synthesize textview=_textview;
@synthesize iv=_iv;
@synthesize picker=_picker;
@synthesize loader=_loader;
@synthesize mapView=_mapView;
@synthesize uploadButton=_uploadButton;
@synthesize keyboardToolbar=_keyboardToolbar;
@synthesize keyboardDoneButton=_keyboardDoneButton;
@synthesize image=_image;
@synthesize uploadRequest=_uploadRequest;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:ALERT_CANCEL_TITLE])
    {
        if (buttonIndex==0)
        {
            TGLog(@"cancelling request");
            [_uploadRequest cancel];
            [self setupMapButton];
        }
        
    } else if ([alertView.title isEqualToString:ALERT_COMPLETE_TITLE])
    {
        TGLog(@"");
        [self.navigationController popToRootViewControllerAnimated:YES];
        tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appdel.tabbar.cvc newButtonPressed:appdel.tabbar.cvc.createButton];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dismissKeyboard
{
    [_textview resignFirstResponder];
}
-(IBAction) locationTextFieldTouched:(id)sender
{
    // bring up the map
    TGLog(@"");
    [_mapView openView];
    
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
}

- (void)viewDidLoad
{
	//tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _loader.hidden=TRUE;
        
    _textview.placeholder = @"Write something about this photo...";
    _textview.placeholderColor = [UIColor colorWithWhite:0.600 alpha:1.000];
    
    _textview.inputAccessoryView = self.keyboardToolbar;
    _keyboardDoneButton.target = self;
    _keyboardDoneButton.action = @selector(dismissKeyboard);
    

}

-(void) setupMapButton
{
    self.navigationItem.hidesBackButton = NO;
    self.navigationItem.rightBarButtonItem.enabled=TRUE;
    _loader.hidden=TRUE;
    [_mapButton setImage:[UIImage imageNamed:@"globe_button.png"] forState:UIControlStateNormal];
}

-(void) mapButtonPressed:(id)sender
{
    if ([_uploadRequest isExecuting])
    {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:ALERT_CANCEL_TITLE 
                                                      message:@"Cancel upload?"
                                                     delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel",nil];
        [alert show];
    } else {
        TGLog(@"");
        [_mapView openView];
    }
}

-(void) mvcLocationSelected:(NSString *)name
{
    _location.text=name;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    int xpos=self.navigationController.navigationBar.frame.size.width/2+60;
    _mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_mapButton addTarget:self action:@selector(mapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if (!self.navigationItem.rightBarButtonItem) { 
        // move toggle button to the right.
        [_mapButton setFrame:CGRectMake(xpos+53,6,32,32)];
    } else {
        [_mapButton setFrame:CGRectMake(xpos,6,32,32)];
    }
    [self setupMapButton];
    _mapButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.navigationController.navigationBar addSubview:_mapButton];
    _mapButton.hidden=NO;
    
    _iv.image=_image;
    addShadow(self.view, _iv, 3.0); 
    
	tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
    TGLog(@"%@", appdel.sd.date);
    if (appdel.sd.date) [_picker setDate:appdel.sd.date animated:YES];

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle: nil];
    _mapView=(MapViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"MAPVIEW"];
    _mapView.delegate=self;
    [appdel.window addSubview:_mapView.view];

}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _mapButton.hidden=YES;
    _textview.text = @"";
    _mapButton=nil;
    
    [_mapView.view removeFromSuperview];
    _mapView=nil;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    _mapButton=nil;
    _uploadButton=nil;
    _mapView=nil;
    _uploadRequest=nil;
    _image=nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    TGLog(@"");
    _keyboardToolbar.hidden=TRUE;
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    _keyboardToolbar.hidden=FALSE;
}

-(void)pickerChanged:(id)sender
{
    //TGLog(@"");
    tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
    appdel.sd.date=_picker.date;
}

-(IBAction)uploadButtonPressed:(id)sender
{
    TGLog(@"");
    [self postPhoto];
}


#pragma mark HTTP POST METHODS
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // upload complete
    [self setupMapButton];
    
	// Use when fetching text data
	NSString *responseString = [request responseString];
	TGLog(@"%@", responseString);
	
	// Use when fetching binary data
	//NSData *responseData = [request responseData];
	    
    NSError* error = NULL;
	SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
	NSDictionary *feed = (NSDictionary *)[jsonParser objectWithString:responseString error:&error];
    if (error!=NULL)
    {
        TGLog(@"JSON err: %@", error);
    }
    NSString* postid=[feed valueForKey:@"post_id"];
    if (!postid)
    {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"Failed" 
                                                      message:@"Upload to Facebook failed."
                                                     delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    } else {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:ALERT_COMPLETE_TITLE 
                                                      message:@"Your upload is complete."
                                                     delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];

    }
    _loader.hidden=TRUE;
	
}
- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
	TGLog(@"%d", bytes);
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.isCancelled) return;
	NSError *error = [request error];
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"Request Failed" 
                                                  message:@"Please check your internet connection"
                                                 delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [self setupMapButton];
	TGLog(@"%@", error);
}

// album for appid will be created automatically
- (void)setProgress:(float)newProgress {
    [_loader setProgress:newProgress];
    //TGLog(@"value: %f",[_loader progress]);
}
-(BOOL) postPhoto
{	
    tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (![appdel checkFaceBook]) return FALSE;
    
    [_mapButton setImage:[UIImage imageNamed:@"toolbar_cancel.png"] forState:UIControlStateNormal];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem.enabled=FALSE;

    NSString* urlStr=[NSString stringWithFormat:@"https://graph.facebook.com/me/photos?access_token=%@", appdel.facebook.accessToken];
    NSURL *url = [NSURL URLWithString:urlStr];
	_uploadRequest = [ASIFormDataRequest requestWithURL:url];

    TGLog(@"%@", urlStr);
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSString* isodate=[dateFormat stringFromDate:_picker.date];
    //http://stackoverflow.com/questions/8576541/upload-photos-for-past-date   
	[_uploadRequest setPostValue:isodate forKey:@"backdated_time"];
	[_uploadRequest setPostValue:_textview.text forKey:@"message"];
    [_uploadRequest setPostValue:[_mapView.placeJson objectForKey:@"id"] forKey:@"place"];
    
    NSData *photoData = UIImagePNGRepresentation(_image);
    [_uploadRequest setData:photoData withFileName:[NSString stringWithFormat:@"file.png"] andContentType:@"image/png" forKey:@"source"];
	//[_req2 setData:photoData forKey:@"source"];	

    
    //[request setAllowCompressedResponse:YES];
    
    // do it!
    [_uploadRequest setTimeOutSeconds:10];
    [_uploadRequest setDelegate:self];
    _loader.hidden=FALSE;
	[_uploadRequest setUploadProgressDelegate:self];
	_uploadRequest.showAccurateProgress=YES;
	[_uploadRequest startAsynchronous];
    
	return TRUE;
}


@end
