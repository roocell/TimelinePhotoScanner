//
//  tpsFirstViewController.m
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-02-23.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#import "CaptureViewController.h"
#import "util.h"
#import "SelectViewController.h"
#import "tpsAppDelegate.h"

@implementation CaptureViewController
@synthesize iv=_iv;
@synthesize image=_image;
@synthesize createButton=_createButton;
@synthesize nextButton=_nextButton;
@synthesize tableView=_tableView;
@synthesize scroller=_scroller;
@synthesize ivs_idx=_ivs_idx;
@synthesize images=_images;
@synthesize pagectrl=_pagectrl;

- (id) initWithCoder:(NSCoder *) coder 
{
    self = [super initWithCoder:coder];
    if (self) {
        // Custom initialization
    }
    _image=nil;
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
-(void) initScroller
{
    _images=[[NSMutableArray alloc] initWithCapacity:0];
    _ivs_idx=0;
    
    [_images addObject:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"slideshow1" ofType:@"png"]]];
    [_images addObject:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"slideshow2" ofType:@"png"]]];
    [_images addObject:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"slideshow3" ofType:@"png"]]];
    [_images addObject:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"slideshow4" ofType:@"png"]]];
    [_images addObject:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"slideshow5" ofType:@"png"]]];
        
    UIImage* i;
    float sw=_scroller.frame.size.width;
    float sh=_scroller.frame.size.height;
    float width=0;
    for (i in _images)
    {

        UIImageView* iv=[[UIImageView alloc] initWithImage:i];
        iv.frame=CGRectMake(width, 0, sw, sh);
        [self.scroller addSubview:iv];
        
        _scroller.minimumZoomScale = _scroller.frame.size.width / iv.frame.size.width;
        _scroller.maximumZoomScale = 1.0; // no zoom for now.
        
        width+=iv.frame.size.width;        
    }
    
    [_scroller setZoomScale:_scroller.minimumZoomScale];
    _scroller.contentSize=CGSizeMake(width, _scroller.contentSize.height);
    _scroller.pagingEnabled=TRUE;
    
    float w=100;
    float h=20;
    float x=(320-w)/2;
    float y=367-10-h/2;
    
    _pagectrl = [[UIPageControl alloc] initWithFrame:CGRectMake(x,y,w,h)];
    [_pagectrl setNumberOfPages:[_images count]];
    [_pagectrl setCurrentPage:0];
    [_pagectrl setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_pagectrl];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    _createButton.action = @selector(newButtonPressed:);
    _createButton.target = self;

    _nextButton.enabled=FALSE;

    //self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    self.navigationController.navigationBar.tintColor = RGB(51, 75, 125);
    
    [self initScroller];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    _image=nil;
    [_images removeAllObjects];
    _images=nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    //if (_image==nil) [self pickSource];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark IMAGE PICKER
#define ALERT_TITLE_CAM_PICKER @"Pick Source"

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:ALERT_TITLE_CAM_PICKER])
    {
        if (buttonIndex==0)
        {
            [self getCameraPicture];
        } else {
            [self getPictureFromPhotos];
        }
    }
    
}
// new button
-(IBAction) newButtonPressed:(id)sender
{
    _nextButton.enabled=FALSE;
    self.tableView.hidden=FALSE;
    self.scroller.hidden=FALSE;
    
    _image=nil;
    _iv.image=nil;
    TGLog(@"");
}

-(void) pickSource
{
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:ALERT_TITLE_CAM_PICKER message:@"Pick a source." 
                                                 delegate:self cancelButtonTitle:@"Camera" otherButtonTitles:@"Photos",nil];
    [alert show];
    
}

- (void)getCameraPicture
{	
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]==FALSE)
    {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Looks like you don't have a camera." 
                                                     delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	[self presentModalViewController:picker animated:YES];
	
}
- (void) getPictureFromPhotos
{	
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]==FALSE)
    {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Looks like you don't have that source available." 
                                                     delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[self presentModalViewController:picker animated:YES];
	
}
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}
- (void)imagePickerController:(UIImagePickerController *)picker 
		didFinishPickingImage:(UIImage *)image
				  editingInfo:(NSDictionary *)editingInfo
{
	TGLog(@"%f,%f orien %d -> %f,%f", image.size.width, image.size.height, image.imageOrientation);
    [picker dismissModalViewControllerAnimated:YES];
    _image=[self imageWithImage:image scaledToSize:CGSizeMake(image.size.width/4, image.size.height/4)];
    
    //_image=[self imageWithImage:image scaledToSize:image.size];
    [_iv setImage:_image];
    
    // bring up next button in nav controller
    _nextButton.enabled=TRUE;
    self.tableView.hidden=TRUE;
    self.scroller.hidden=TRUE;
    
    // automatically goto next
    [self autoNext];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissModalViewControllerAnimated:YES];	
}

-(void) autoNext
{
    tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle: nil];
    SelectViewController* vc=(SelectViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"SVC"];
    vc.image=_image;
    vc.bb=nil;
    
    [appdel showMessageView:@"Detecting Photo"];          
    [self.navigationController pushViewController:vc animated:TRUE];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
        
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"CAPVC_SELVC"])
    {
        // Get reference to the destination view controller
        SelectViewController  *vc = [segue destinationViewController];
        vc.image=_image;
        vc.bb=nil;

        tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appdel showMessageView:@"Detecting Photo"];          
        TGLog(@"");

     }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier=@"CaptureCellBig";
    
    switch ([indexPath row])
    {
        case 0:
            CellIdentifier=@"CaptureCellCamera";
            break;
        case 1:
            CellIdentifier=@"CaptureCellLibrary";
            break;
        case 2:
            CellIdentifier=@"CaptureCellBig";
            break;
        default:break;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    switch ([indexPath row])
    {
        case 0:
            break;
        case 1:
            break;
        case 2:
        {
        }
            break;
        default:break;
    }
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    switch ([indexPath row])
    {
        case 0:
            [self getCameraPicture];
            break;
        case 1:
            [self getPictureFromPhotos];
            break;
        case 2:
            break;
        default:break;
    }
}

#pragma UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil; // no zooming for now
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	int i=_scroller.contentOffset.x/_scroller.frame.size.width;
    _ivs_idx=i;
    [_pagectrl setCurrentPage:i];
}

-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
}
-(void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
 
}

@end
