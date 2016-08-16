//
//  ZoomWindow.m
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-02-23.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#import "ZoomWindow.h"
#import "util.h"

@implementation ZoomWindow
@synthesize  iv=_iv;

- (id) initWithCoder:(NSCoder *) coder 
{
    self = [super initWithCoder:coder];
    if (self) {
        // Custom initialization
    }
    
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect f=self.view.frame;
    f.size.width=120.0;
    f.size.height=120.0;
    self.view.frame=f;
    
    UIImageView* iv=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"target.png"]];
    CGRect fv=iv.frame;
    fv.size.width=120.0;
    fv.size.height=120.0;
    iv.frame=fv;
    [self.view addSubview:iv];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    //TGLog(@"");
	
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{

}

@end
