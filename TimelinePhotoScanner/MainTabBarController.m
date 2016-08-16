//
//  MainTabBarController.m
//  Mobile Playlist Client
//
//  Created by michael russell on 11-12-19.
//  Copyright (c) 2011 Thumb Genius Software. All rights reserved.
//

#import "MainTabBarController.h"
#import "SettingsViewController.h"
#import "HistoryViewController.h"
#import "CaptureViewController.h"
#import "util.h"

@implementation MainTabBarController
@synthesize svc=_svc;
@synthesize hvc=_hvc;
@synthesize cvc=_cvc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    TGLog(@"");
    [super viewDidLoad];

    UINavigationController* n;
    for (n in self.viewControllers)
    {
        TGLog(@"");
        UIViewController* vc=[n.viewControllers objectAtIndex:0];
        TGLog(@"%@", [vc class]);
        if ([vc isKindOfClass:[CaptureViewController class]])
        {
            _cvc = (CaptureViewController*)vc;
        }
        if ([vc isKindOfClass:[SettingsViewController class]])
        {
            _svc = (SettingsViewController*)vc;
        }
        if ([vc isKindOfClass:[HistoryViewController class]])
        {
            _hvc = (HistoryViewController*)vc;
        }        
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    _svc=nil;
    _hvc=nil;
    _cvc=nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



@end
