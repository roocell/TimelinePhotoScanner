//
//  HistoryViewController.h
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-02-23.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryViewController : UITableViewController

@property (strong, nonatomic) NSString* albumID;
@property (strong, nonatomic) NSMutableArray* data;
@property (strong, nonatomic) NSMutableArray* thumbnails;
@property (strong, nonatomic) NSThread* imageLoadingThread;
@end
