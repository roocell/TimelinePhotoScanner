//
//  tpsSecondViewController.m
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-02-23.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#import "SettingsViewController.h"
#import "tpsAppDelegate.h"
#import "util.h"

@implementation SettingsViewController

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
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.tintColor = RGB(51, 75, 125);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
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



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) return @"Facebook";
    return nil;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0) return 1;
    if (section==1) return 1;
    return 0;
}

-(void) logoutPressed:(id)sender
{
    TGLog(@"");
  	tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appdel.facebook logout];
    appdel.loggedIn=FALSE;
    [self.tableView reloadData];
}
-(void) loginPressed:(id)sender
{
    TGLog(@"");
  	tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"user_photos", @"publish_stream", 
                            nil];
    [appdel.facebook authorize:permissions];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  	tpsAppDelegate* appdel = (tpsAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *CellIdentifier=@"FacebookCell";
    
    if ([indexPath section]==1) 
    {
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if ([indexPath section]==0) 
    {
        // Configure the cell...
        UIImageView* avatar=(UIImageView*)[cell viewWithTag:100];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
        UIButton* button=(UIButton*)[cell viewWithTag:102];
        if (appdel.facebook.isSessionValid)
        {
            if (appdel.fbavatar) [avatar setImage:appdel.fbavatar];
            else [avatar  setImage:[UIImage imageNamed:@"fbicon.png"]];
            nameLabel.text=appdel.fbrealname;
            [button setImage:[UIImage imageNamed:@"logout.png"] forState:UIControlStateNormal];
            [button removeTarget:self action:@selector(loginPressed:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(logoutPressed:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [avatar  setImage:[UIImage imageNamed:@"fbicon.png"]];
            nameLabel.text=@"Please Log In";
            [button setImage:[UIImage imageNamed:@"login.png"] forState:UIControlStateNormal];
            [button removeTarget:self action:@selector(logoutPressed:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(loginPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
    } else if ([indexPath section]==1) {
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

@end
