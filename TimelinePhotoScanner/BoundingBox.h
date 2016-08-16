//
//  BoundingBox.h
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-02-24.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "util.h"

#define DRAG_POINT_NONE 0
#define DRAG_POINT_1 1
#define DRAG_POINT_2 2
#define DRAG_POINT_3 3
#define DRAG_POINT_4 4

@interface BoundingBox : UIView

@property bBox box;
@property int drag;
@property CGPoint dragPoint;

-(BOOL) findDragPoint:(CGPoint)touchPos;
-(void) changeDragPoint:(CGPoint)touchPos;

@end
