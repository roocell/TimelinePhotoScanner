//
//  tpsAppDelegate.m
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-02-23.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#import "tpsAppDelegate.h"
#import "util.h"
#import "TestFlight.h" 
#import "SettingsViewController.h"

@implementation tpsAppDelegate

@synthesize window = _window;
@synthesize facebook=_facebook;
@synthesize loggedIn=_loggedIn;
@synthesize fbrealname=_fbrealname;
@synthesize fbavatar=_fbavatar;
@synthesize fbLoaderView=_fbLoaderView;
@synthesize mvc=_mvc;
@synthesize tabbar=_tabbar;
@synthesize sd=_sd;

#ifdef TIMELINE_UPLOAD_LIB
@synthesize timelineUpload;
#endif

-(BOOL) readFromSaveData
{	
    [_sd removePreviousSavedData]; // remove data file from doc dir
    BOOL saveDataPresent=FALSE;
	NSData *data=[[NSMutableData alloc] initWithContentsOfFile:[_sd dataFilePath]];
	if (data==nil) 
	{
		NSLog(@"readFromSaveData failed file dne");
		[_sd setDefaults];
		saveDataPresent=FALSE;
	} else {
		NSKeyedUnarchiver *unarchiver=[[NSKeyedUnarchiver alloc] initForReadingWithData:data];	
		self.sd=[unarchiver decodeObjectForKey:kDataKey];
		[unarchiver finishDecoding];
		TGLog(@"savedata MapType %f,%f", [_sd.lat doubleValue], [_sd.lng doubleValue]);
        saveDataPresent=TRUE;
	}
    if (saveDataPresent)
    {
        return TRUE;
    }
    return FALSE;
}
#pragma FACEBOOK STUFF
#define LOGIN_TITLE @"Log In"
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:LOGIN_TITLE])
    {
        
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"user_photos", @"publish_stream", 
                                nil];
        [_facebook authorize:permissions];
    }
}

-(BOOL) checkFaceBook
{
    if (!_loggedIn) {
        TGLog(@"FACEBOOK: session not valid");
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:LOGIN_TITLE 
                                                      message:[NSString stringWithFormat:@"You have to log into facebook first."]
                                                     delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return FALSE;
    }
    return TRUE;
}

//https://developers.facebook.com/docs/mobile/ios/build/
-(void) facebookStartup
{
    _facebook = [[Facebook alloc] initWithAppId:FACEBOOK_APPID andDelegate:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"tps_FBAccessTokenKey"] 
        && [defaults objectForKey:@"tps_FBExpirationDateKey"]) {
        _facebook.accessToken = [defaults objectForKey:@"tps_FBAccessTokenKey"];
        _facebook.expirationDate = [defaults objectForKey:@"tps_FBExpirationDateKey"];
    }
    if (![_facebook isSessionValid]) {
        _loggedIn=FALSE;
        TGLog(@"FACEBOOK: session not valid");
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:LOGIN_TITLE 
                                                      message:[NSString stringWithFormat:@"You have to log into facebook first."]
                                                     delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    } else {
        TGLog(@"FACEBOOK: session is still valid %@",  [_facebook accessToken]);
        [_facebook requestWithGraphPath:@"me" andDelegate:self];
    }
}
// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [_facebook handleOpenURL:url]; 
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [_facebook handleOpenURL:url]; 
}
- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[_facebook accessToken] forKey:@"tps_FBAccessTokenKey"];
    [defaults setObject:[_facebook expirationDate] forKey:@"tps_FBExpirationDateKey"];
    [defaults synchronize];
    
    [_facebook requestWithGraphPath:@"me" andDelegate:self];
    TGLog(@"expires %@", [_facebook expirationDate]);
    [_facebook requestWithGraphPath:@"me/permissions" andDelegate:self];
    
    
}
-(void)fbDidNotLogin:(BOOL)cancelled {
    TGLog(@"");
    if (cancelled) {
        TGLog(@"FACEBOOK: cancelled");
    } else {
        TGLog(@"FACEBOOK: failed");
    }
}

- (void)request:(FBRequest*)request didLoad:(id)result
{
    NSRange start = [request.url rangeOfString:@"permissions"];
    if (start.location != NSNotFound) {
        TGLog(@"permissions");
        TGLog(@"%@", result);
        return;
    } 
   
    //TGLog(@"%@", result);
	//SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSString* username=[result valueForKey:@"username"];
    //NSString* email=[result valueForKey:@"email"];
    
    
    NSString* profilepic=[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", username];
    NSURL* ppurl=[NSURL URLWithString:profilepic];
    NSData* ppdata=[NSData dataWithContentsOfURL:ppurl];
    _fbavatar=[UIImage imageWithData:ppdata];
    _fbrealname=[result valueForKey:@"name"];
    
    [_tabbar.svc.tableView reloadData];
#ifdef TIMELINE_UPLOAD_LIB
    [self.timelineUpload
     startAsyncFacebookLoginWithEmailAddressString:self.loginView.emailTextField.text
     andPasswordString:self.loginView.passwordTextField.text];
#endif
    _loggedIn=TRUE;

}
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error;
{
    TGLog(@"");
    _loggedIn=FALSE;
    [self removeMessageView];
    
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"Facebook Failed "
                                                  message:[NSString stringWithFormat:@"Failed to authenticate with Facebook. Try again on the settings tab."]
                                                 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


-(void) showMessageView:(NSString*) msg
{
    _mvc.text=msg;
    _mvc.msg.text=msg;
    [_tabbar.view addSubview:_mvc.view];
    [_tabbar.view bringSubviewToFront:_mvc.view];
}
-(void) removeMessageView
{
    [_mvc.view removeFromSuperview];
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // prints out the location of the docs dir (simulator)
    TGLog(@"Documents: %@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]);
    
    // Override point for customization after application launch.
    [TestFlight takeOff:@"9965ac740c7efa0d541c0730c6d791f9_MTMxMzIwMTEtMTAtMTYgMTE6NTQ6MDQuNTMxNjk3"];

    _sd=[[SaveData alloc] init];
	if ([self readFromSaveData]==TRUE)
	{
		
	}
    
    [self facebookStartup];
    

    _tabbar = (MainTabBarController *)self.window.rootViewController; 
    _tabbar.delegate=self;

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle: nil];
    _mvc=(MessageViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"MVC"];
    //if (_mvc==nil) TGLog(@"ERR cant find MVC in storyboard");
    //[_tabbar.view addSubview:_mvc.view];

#ifdef TIMELINE_UPLOAD_LIB
    self.timelineUpload = [[TPTimelineUpload alloc] init];
#endif
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [_sd writeToSaveData];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [_sd writeToSaveData];
}

@end
