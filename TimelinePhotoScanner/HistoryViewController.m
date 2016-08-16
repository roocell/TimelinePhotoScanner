//
//  HistoryViewController.m
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-02-23.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#import "HistoryViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "tpsAppDelegate.h"
#import "util.h"

@implementation HistoryViewController
@synthesize albumID=_albumID;
@synthesize data=_data;
@synthesize  imageLoadingThread=_imageLoadingThread;
@synthesize thumbnails=_thumbnails;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationController.navigationBar.tintColor = RGB(51, 75, 125);
    
    _data=[NSMutableArray arrayWithCapacity:0];
    _thumbnails=[NSMutableArray arrayWithCapacity:0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    _albumID=nil;
    [_data removeAllObjects];
    _data=nil;
    _thumbnails=nil;
    _imageLoadingThread=nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_data removeAllObjects];
    [_thumbnails removeAllObjects];
    [self startDataRetrieval];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) photoButtonPressed:(id) sender
{
    UIButton* b=(UIButton*)sender;
    int idx=-1;
    int sect=0;
    // go through table to see which button what pressed
    NSIndexPath* path;
    for (path in [self.tableView indexPathsForVisibleRows])
    {
        UITableViewCell* cell=[self.tableView cellForRowAtIndexPath:path];
        UIButton* b1=(UIButton*)[cell viewWithTag:100];
        UIButton* b2=(UIButton*)[cell viewWithTag:101];
        UIButton* b3=(UIButton*)[cell viewWithTag:102];
        if (b1==b)
        {
            idx=[path row]*3+0;
            sect=[path section];
            break;
        } else if (b2==b) {
            idx=[path row]*3+1;
            sect=[path section];
            break;
        } else if (b3==b) {
            idx=[path row]*3+2;
            sect=[path section];
            break;
        }
    }
    if (idx==-1)
    {
        TGLog(@"ERR");
        return;
    }
    NSDictionary* d=[_data objectAtIndex:idx];
    NSString* l=[d objectForKey:@"link"];

    // launch photo URL
    NSURL *url__ = [NSURL URLWithString:l];
    if (![[UIApplication sharedApplication] openURL:url__])
        NSLog(@"%@%@",@"Failed to open url:",[url__ description]);

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    int remainder=[_data count]%3;
    int partrow=(remainder==0)?0:1;
    return [_data count]/3+partrow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HistoryTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    TGLog(@"%@", indexPath);
    // Configure the cell...
    UIButton *b1 = (UIButton *)[cell viewWithTag:100];
    UIButton *b2 = (UIButton *)[cell viewWithTag:101];
    UIButton *b3 = (UIButton *)[cell viewWithTag:102];
    b1.hidden=TRUE;
    b2.hidden=TRUE;
    b3.hidden=TRUE;

    [b1 removeTarget:self action:@selector(photoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [b2 removeTarget:self action:@selector(photoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [b3 removeTarget:self action:@selector(photoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    int idx=[indexPath row];
    
    UIImage* img1=nil;
    UIImage* img2=nil;
    UIImage* img3=nil;
    if ([_thumbnails count]>idx*3+0)
        img1=[_thumbnails objectAtIndex:idx*3+0];
    if ([_thumbnails count]>idx*3+1)
        img2=[_thumbnails objectAtIndex:idx*3+1];
    if ([_thumbnails count]>idx*3+2)
        img3=[_thumbnails objectAtIndex:idx*3+2];
    
    TGLog(@"%d %@ %@ %@", [indexPath row], img1, img2, img3);
    if (img1)
    {
        [b1 setImage:img1 forState:UIControlStateNormal];
        [b1 addTarget:self action:@selector(photoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        b1.hidden=FALSE;
        [b1.imageView setContentMode:UIViewContentModeScaleAspectFill];
        UIView *v = (UIView *)[cell viewWithTag:200];
        addShadow(v, b1.imageView, 3.0); 
    }
    if (img2)
    {
        [b2 setImage:img2 forState:UIControlStateNormal];
        [b2 addTarget:self action:@selector(photoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        b2.hidden=FALSE;
        [b2.imageView setContentMode:UIViewContentModeScaleAspectFill];
        UIView *v = (UIView *)[cell viewWithTag:201];
        addShadow(v, b2.imageView, 3.0); 
    }
    if (img3)
    {
        [b3 setImage:img3 forState:UIControlStateNormal];
        [b3 addTarget:self action:@selector(photoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        b3.hidden=FALSE;
        [b3.imageView setContentMode:UIViewContentModeScaleAspectFill];
        UIView *v = (UIView *)[cell viewWithTag:202];
        addShadow(v, b3.imageView, 3.0); 
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
}
-(void) loadThumbnailsThread
{
    TGLog(@"processing %d photos", [_data count]);
    NSDictionary* photo;
    for (photo in _data)
    {
        // each photo has an array called 'images' - goes from biggest to smallest
        // use the last one as the thumbnail
        NSArray* thumbs=[photo  objectForKey:@"images"];
        if (thumbs)
        {
            NSDictionary* th;
            NSString* urlStr;
            for (th in thumbs)
            {
                urlStr=[th objectForKey:@"source"];
            }
            if (urlStr)
            {
                NSURL *url = [NSURL URLWithString:urlStr];
                UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
                if (image==nil)
                {
                    image=[UIImage imageNamed:@"Icon@2x.png"];
                }
                TGLog(@"%@", urlStr);
                [_thumbnails addObject:image];
            }
        }
    }
    [self.tableView reloadData];
    tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appdel removeMessageView];
}



#pragma mark HTTP POST METHODS
- (void)requestFinished:(ASIHTTPRequest *)request
{
    
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
    }
    NSArray* data=[feed objectForKey:@"data"];
    if (data==nil || [data count]==0)
    {
        TGLog(@"no data %@", responseString);
        return;
    }
    
    NSRange start = [request.url.absoluteString  rangeOfString:@"albums"];
    if (start.location != NSNotFound) {
        TGLog(@"looking for album id");
        _albumID=nil;
        NSDictionary* album;
        for (album in data)
        {
            TGLog(@"%@", [album objectForKey:@"name"]);
            if (error!=NULL)
            {
                TGLog(@"JSON err: %@", error);
                return;
            }
            NSString* name=[album objectForKey:@"name"];
            NSRange start = [name rangeOfString:@"Timeline Photo Scanner Photos"];
            if (start.location != NSNotFound) {
                _albumID=[album objectForKey:@"id"];
                TGLog(@"Found album %@", _albumID);
                break;
            }
        }	
        if (_albumID)
        {
            [self getPhotosInAlbum:_albumID];
            return;
        }
    } else {
        TGLog(@"getting photos in album");
        NSDictionary* photos;
        for (photos in data)
        {
            //TGLog(@"%@", photos);
            if (error!=NULL)
            {
                TGLog(@"JSON err: %@", error);
                return;
            }
            [_data addObject:photos];
        }	
        
        // there is also paging
        NSDictionary* paging=[photos objectForKey:@"paging"];
        NSString* next=nil;
        if (paging)
        {
            next=[paging objectForKey:@"next"];
            if (next)
            {
                [self getPhotosInAlbumNext:next];
                return;
            }
        }
        if (!next)
        {
            TGLog(@"done paging");
            [self.tableView reloadData];
            _imageLoadingThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadThumbnailsThread) object:nil];
            if (_imageLoadingThread) [_imageLoadingThread start];
        }
       
    }
}
- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
	TGLog(@"%d", bytes);
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"Playlist Error" 
                                                  message:@"Please check your internet connection"
                                                 delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
	TGLog(@"%@", error);
}

-(BOOL) getPhotosInAlbumNext:(NSString*) nextUrl
{	
    tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (![appdel checkFaceBook]) return FALSE;
    
    NSURL *url = [NSURL URLWithString:nextUrl];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    TGLog(@"%@", nextUrl);
    //[request setAllowCompressedResponse:YES];
    [request setTimeOutSeconds:10];
    [request setDelegate:self];
	//[request setUploadProgressDelegate:_loader];
	//request.showAccurateProgress=YES;
	[request startAsynchronous];
    
	return TRUE;
}
                       
-(BOOL) getPhotosInAlbum:(NSString*) facebook_album_id
{	
    tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (![appdel checkFaceBook]) return FALSE;
    
    NSString* urlStr=[NSString stringWithFormat:@"https://graph.facebook.com/%@/photos&access_token=%@", 
                    facebook_album_id,appdel.facebook.accessToken];
    NSURL *url = [NSURL URLWithString:urlStr];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    TGLog(@"%@", urlStr);
    //[request setAllowCompressedResponse:YES];
    [request setTimeOutSeconds:10];
    [request setDelegate:self];
	//[request setUploadProgressDelegate:_loader];
	//request.showAccurateProgress=YES;
	[request startAsynchronous];
    
	return TRUE;
}


-(BOOL) getAlbums
{	
    tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (![appdel checkFaceBook]) return FALSE;
    
    NSString* urlStr=[NSString stringWithFormat:@"https://graph.facebook.com/me/albums?access_token=%@", appdel.facebook.accessToken];
    NSURL *url = [NSURL URLWithString:urlStr];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    TGLog(@"%@", urlStr);
     //[request setAllowCompressedResponse:YES];
    [request setTimeOutSeconds:10];
    [request setDelegate:self];
	//[request setUploadProgressDelegate:_loader];
	//request.showAccurateProgress=YES;
	[request startAsynchronous];
        
	return TRUE;
}

-(void) startDataRetrieval
{
    tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appdel showMessageView:@"Getting Photos"];
    [self getAlbums];
}

@end
