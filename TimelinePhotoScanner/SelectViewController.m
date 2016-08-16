//
//  SelectViewController.m
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-02-23.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#import "SelectViewController.h"
#import "util.h"
#import "EditViewController.h"
#import "tpsAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation SelectViewController
@synthesize iv=_iv;
@synthesize nextButton=_nextButton;
@synthesize image=_image;
@synthesize zimage=_zimage;
@synthesize zw=_zw;
@synthesize bb=_bb;
@synthesize mvc=_mvc;
@synthesize skipButton=_skipButton;
@synthesize container=_container;
@synthesize opencv=_opencv;

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

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

-(void) skipButtonPressed:(id) sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle: nil];
    EditViewController* editvc=(EditViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"EDITVC"];
    editvc.image=_image;
    [self.navigationController pushViewController:editvc animated:TRUE];
}
-(void) createSkipButton
{
    int xpos=self.navigationController.navigationBar.frame.size.width/2+70;
    _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_skipButton addTarget:self action:@selector(skipButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if (!self.navigationItem.rightBarButtonItem) { 
        // move toggle button to the right.
        [_skipButton setFrame:CGRectMake(xpos+53,6,32,32)];
    } else {
        [_skipButton setFrame:CGRectMake(xpos,6,32,32)];
    }
    [_skipButton setImage:[UIImage imageNamed:@"toolbar_skip.png"] forState:UIControlStateNormal];
    _skipButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.navigationController.navigationBar addSubview:_skipButton];
    _skipButton.hidden=NO;

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //_image=[self imageWithImage:_image scaledToSize:_image.size];
    [_iv setImage:_image];
    _nextButton.enabled=FALSE;

    [appdel showMessageView:@"Detecting Photo"];     


}
-(void) getBoundingBox
{
    TGLog(@"");
    tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
    //[NSThread sleepForTimeInterval:2.0];
    // do our Hough Transform using opencv and put it on top of the image
    _bb=[[BoundingBox alloc] initWithFrame:self.view.frame];
    _bb.box=[_opencv getBoundingBoxCorners:_image imageView:_iv];
    
    [self.view addSubview:_bb];
    [self.view addSubview:_zw.view];
    
    
    [appdel removeMessageView];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    _opencv=[[tpsOpenCv alloc] init];

    TGLog(@"bb=%@", _bb);
    if (_bb==nil)
    {
        //UIView* v=[[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width+_zw.view.frame.size.width*2, self.view.frame.size.height+_zw.view.frame.size.width*2)];
        _zimage=[self imageWithView:_container];
        TGLog(@"zimage %fX%f", _zimage.size.width, _zimage.size.height);
        [NSThread detachNewThreadSelector:@selector(getBoundingBox) toTarget:self withObject:nil];
    } else {
        tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appdel removeMessageView];
    }
    _nextButton.enabled=TRUE;
    [self createSkipButton];

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle: nil];
    _zw=(ZoomWindow*)[mainStoryboard instantiateViewControllerWithIdentifier: @"ZOOM_WINDOW"];
    _zw.view.hidden=TRUE;

}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _skipButton.hidden=YES;
    _zw=nil;
    _opencv=nil;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    _image=nil;
    _zimage=nil;
    _zw=nil;
    _bb=nil;
    _mvc=nil;
    _skipButton=nil;
    _opencv=nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TGLog(@"");
    
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"SELVC_EDITVC"])
    {
        tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appdel showMessageView:@"Fixing Photo"];        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];    

        // Get reference to the destination view controller
        EditViewController  *vc = [segue destinationViewController];
        
        // get the image inside the rect and fix it up
        
        // we have to scale up the bounding box to the real image
        bBox newBBox;
        newBBox.pt1=[_opencv scaleScreenPointToImage:_bb.box.pt1 image:_image imageView:_iv];
        newBBox.pt2=[_opencv scaleScreenPointToImage:_bb.box.pt2 image:_image imageView:_iv];
        newBBox.pt3=[_opencv scaleScreenPointToImage:_bb.box.pt3 image:_image imageView:_iv];
        newBBox.pt4=[_opencv scaleScreenPointToImage:_bb.box.pt4 image:_image imageView:_iv];
        
        TGLog(@"newBBox %f,%f %f,%f %f,%f %f,%f", 
              newBBox.pt1.x, newBBox.pt1.y,
              newBBox.pt2.x, newBBox.pt2.y,
              newBBox.pt3.x, newBBox.pt3.y,
              newBBox.pt4.x, newBBox.pt4.y);
        // set the result imageview
        vc.image=[_opencv deskew:newBBox image:_image];

        
    }
}


#define ZOOM_SCALE 4.0
- (UIImage *) imageWithView:(UIView *)_haha
{
    UIGraphicsBeginImageContextWithOptions(_haha.bounds.size, _haha.opaque, ZOOM_SCALE);
    [_haha.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}
-(UIImage*) zoomedImage:(CGPoint) pos;
{
    float zww=_zw.view.frame.size.width;
    float zwh=_zw.view.frame.size.height;
#if 0
    float ivw=_iv.frame.size.width;
    float ivh=_iv.frame.size.height;
    float srcw=_image.size.width;
    float srch=_image.size.height;
#endif
#if 0
    float scalex=srcw/ivw;
    float scaley=srch/ivh;
    float scale_src=(srch>srcw)?scaley:scalex;
    float white_barx=(ivw-srcw/scale_src)/2.0;
    float white_bary=(ivh-srch/scale_src)/2.0;
#endif
    CGPoint offset=CGPointMake(_iv.frame.origin.x, _iv.frame.origin.y);
    float posx1=(pos.x+offset.x-15)*ZOOM_SCALE;
    float posy1=(pos.y+offset.y-15)*ZOOM_SCALE;
    
    //TGLog(@"%f,%f %f,%f", white_barx, white_bary, posx1, posy1);

    CGRect rect=CGRectMake(posx1, posy1, zww, zwh);
    CGImageRef imageRef = CGImageCreateWithImageInRect(_zimage.CGImage, rect);
    
    UIImage* maskImage=[UIImage imageNamed:@"target_mask.png"];    
    CGImageRef maskRef = maskImage.CGImage; 
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
	CGImageRef masked = CGImageCreateWithMask(imageRef, mask);
    UIImage *result = [UIImage imageWithCGImage:masked scale:1.0 orientation:_zimage.imageOrientation];
    
    CGImageRelease(imageRef); 
    return result;
}


-(void) moveZW:(CGPoint) touchPos
{
    // move zoom window somewhere other than the touch pos
    if (touchPos.x>self.view.center.x && touchPos.y>self.view.center.y)
    {
        _zw.view.center=CGPointMake(touchPos.x-_zw.view.frame.size.width, touchPos.y-_zw.view.frame.size.height);
    } else if (touchPos.x<self.view.center.x && touchPos.y>self.view.center.y) {
        _zw.view.center=CGPointMake(touchPos.x+_zw.view.frame.size.width, touchPos.y-_zw.view.frame.size.height);
    } else if (touchPos.x>self.view.center.x && touchPos.y<self.view.center.y) {
        _zw.view.center=CGPointMake(touchPos.x-_zw.view.frame.size.width, touchPos.y+_zw.view.frame.size.height);
    } else {
        _zw.view.center=CGPointMake(touchPos.x+_zw.view.frame.size.width, touchPos.y+_zw.view.frame.size.height);
    }
}


- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    TGLog(@"");
    for (UITouch *touch in touches)
	{
		CGPoint touchPos = [touch locationInView:_iv];
        
        // find the nearest drag point in the bounding box
        //_bb.hidden=TRUE;
        if([_bb findDragPoint:touchPos]==FALSE) return;        
        
        _zw.view.hidden=FALSE;

        //TGLog(@"%@", touchPos);
        _zw.view.center=touchPos;

        [_zw.iv setImage:[self zoomedImage:touchPos]];
        [self moveZW:touchPos];
	}
}

-(BOOL) isWithinBox:(CGPoint) point
{
    // go through BB point
    //TGLog(@"%d %f,%f", _bb.drag, point.x, point.y);
    switch (_bb.drag)
    {
        case DRAG_POINT_1:
            if (point.x>=_bb.box.pt2.x && point.x>=_bb.box.pt3.x) return FALSE;
            if (point.y>=_bb.box.pt3.y && point.y>=_bb.box.pt4.y) return FALSE;
            break;
        case DRAG_POINT_2:
            if (point.x<=_bb.box.pt1.x && point.x<=_bb.box.pt4.x) return FALSE;
            if (point.y>=_bb.box.pt3.y && point.y>=_bb.box.pt4.y) return FALSE;
            break;
        case DRAG_POINT_3:
            if (point.x<=_bb.box.pt1.x && point.x<=_bb.box.pt4.x) return FALSE;
            if (point.y<=_bb.box.pt1.y && point.y<=_bb.box.pt2.y) return FALSE;
            break;
        case DRAG_POINT_4:
            if (point.x>=_bb.box.pt2.x && point.x>=_bb.box.pt3.x) return FALSE;
            if (point.y<=_bb.box.pt1.y && point.y<=_bb.box.pt2.y) return FALSE;
            break;
        default: break;
    }
    return TRUE;
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    if (_bb.drag==DRAG_POINT_NONE) return;
    
    for (UITouch *touch in touches)
	{
		CGPoint touchPos = [touch locationInView:_iv];

        // prevent going past other lines
        if (![self isWithinBox:touchPos]) continue;

        //TGLog(@"%@", touchPos);
        _zw.view.center=touchPos;
        [_zw.iv setImage:[self zoomedImage:touchPos]];
        
        
        [_bb changeDragPoint:touchPos];        
        [self moveZW:touchPos];

	}

}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    _zw.view.hidden=TRUE;
}

@end
