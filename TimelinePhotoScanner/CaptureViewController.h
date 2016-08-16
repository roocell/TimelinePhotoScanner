//
//  tpsFirstViewController.h
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-02-23.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaptureViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet UIImageView* iv;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* createButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* nextButton;
@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet UIScrollView* scroller;
@property (strong, nonatomic) UIPageControl* pagectrl;
@property (strong, nonatomic) UIImage* image;
@property (strong, nonatomic) NSMutableArray* images;

@property int ivs_idx;

-(void) pickSource;
- (void)getCameraPicture;
- (void) getPictureFromPhotos;

-(IBAction) newButtonPressed:(id)sender;
@end
