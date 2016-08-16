//
//  ResultViewController.m
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-02-23.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#import "EditViewController.h"
#import "util.h"
#import "DetailsViewController.h"
#import "tpsAppDelegate.h"

@implementation EditViewController
@synthesize iv=_iv;
@synthesize image=_image;
@synthesize  editButton=_editButton;
@synthesize sessions=_sessions;

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
    _sessions=[NSMutableArray arrayWithCapacity:0];
    [super viewDidLoad];
}
#define SUPPORT_BIG_IMAGE 1
-(void) editButtonPressed:(id) sender
{
    //https://github.com/AviaryInc/Mobile-Feather-SDK-for-iOS
    // go here for more customization, etc
#if SUPPORT_BIG_IMAGE
    // to support maximum resolution
    AFPhotoEditorController *photoEditor = [[AFPhotoEditorController alloc] initWithImage:_image];
    
    // Capture the user's session and store it in an array
    __block AFPhotoEditorSession *session = [photoEditor session];
    [[self sessions] addObject:session];
    
    // Create a context with the maximum output resolution
    AFPhotoEditorContext *context = [session createContext];
    
    [context renderInputImage:_image completion:^(UIImage *result) {
        // `result` will be nil if the session is canceled, or non-nil if the session was closed successfully and rendering completed
        [[self sessions] removeObject:session];
        if (result==nil)
        {
            TGLog(@"BIG cancelled");

        } else {
            _image=result;
            _iv.image=result;
            TGLog(@"BIG %f,%f", result.size.width, result.size.height);
                
        }
    }];
#else
    // bring up aviary
    AFPhotoEditorController *photoEditor = [[AFPhotoEditorController alloc] initWithImage:_image];
#endif
    [photoEditor setDelegate:self];
    [self presentModalViewController:photoEditor animated:YES];  
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    int xpos=self.navigationController.navigationBar.frame.size.width/2+70;
    _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_editButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if (!self.navigationItem.rightBarButtonItem) { 
        // move toggle button to the right.
        [_editButton setFrame:CGRectMake(xpos+53,6,32,32)];
    } else {
        [_editButton setFrame:CGRectMake(xpos,6,32,32)];
    }
    [_editButton setImage:[UIImage imageNamed:@"edit_button.png"] forState:UIControlStateNormal];
    _editButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.navigationController.navigationBar addSubview:_editButton];
    _editButton.hidden=NO;

    [_iv setImage:_image];
 
    tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appdel removeMessageView];  
    
    TGLog(@"%f,%f", _image.size.width, _image.size.height);

}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _editButton.hidden=YES;
    _editButton=nil; // because it's created on viewDidAppear
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    _image=nil;
    _editButton=nil;
    [_sessions removeAllObjects];
    _sessions=nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"EDITVC_DETAILSVC"])
    {
        TGLog(@"");
        // Get reference to the destination view controller
        DetailsViewController  *vc = [segue destinationViewController];
        vc.image=_iv.image;
    }
}



#pragma mark AVIARY DELEGATES
- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
#if SUPPORT_BIG_IMAGE
    // Handle the result image here
    _image=image;
    _iv.image=image;
#endif
    [editor dismissModalViewControllerAnimated:YES];
    
    TGLog(@"%f,%f", _image.size.width, _image.size.height);

}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    // Handle cancelation here
    TGLog(@"");
    [editor dismissModalViewControllerAnimated:YES];
    
}
@end
