//
//  BoundingBox.m
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-02-24.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#import "BoundingBox.h"

@implementation BoundingBox
@synthesize dragPoint=_dragPoint;
@synthesize drag=_drag;
@synthesize box=_box;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor=[UIColor clearColor];
        //self.alpha=0.5;
    }
    return self;
}

#define CIRC_DIAMETER 15
-(void) drawCircle:(CGPoint) center
{
    CGContextRef context = UIGraphicsGetCurrentContext();    
    CGContextSetLineWidth(context, 2.0);    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGRect rectangle = CGRectMake(center.x-CIRC_DIAMETER/2,center.y-CIRC_DIAMETER/2,CIRC_DIAMETER,CIRC_DIAMETER);    
    CGContextAddEllipseInRect(context, rectangle);    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillPath(context);
    CGContextStrokePath(context);

}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //TGLog(@"[%f,%f] [%f,%f] [%f,%f] [%f.%f]", _box.pt1.x, _box.pt1.y, _box.pt2.x, _box.pt2.y, _box.pt3.x, _box.pt3.y, _box.pt4.x, _box.pt4.y);
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(c, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(c, 2.0);    
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, _box.pt1.x,_box.pt1.y);
    CGContextAddLineToPoint(c, _box.pt2.x, _box.pt2.y);
    CGContextAddLineToPoint(c, _box.pt3.x, _box.pt3.y);
    CGContextAddLineToPoint(c, _box.pt4.x, _box.pt4.y);
    CGContextAddLineToPoint(c, _box.pt1.x, _box.pt1.y);
    CGContextStrokePath(c);
    
    [self drawCircle:CGPointMake(_box.pt1.x,_box.pt1.y)];
    [self drawCircle:CGPointMake(_box.pt2.x,_box.pt2.y)];
    [self drawCircle:CGPointMake(_box.pt3.x,_box.pt3.y)];
    [self drawCircle:CGPointMake(_box.pt4.x,_box.pt4.y)];

}

-(BOOL) findDragPoint:(CGPoint)touchPos
{
    float d1,d2,d3,d4;
    float min;
    CGPoint closest;

    d1=sqrtf(pow(fabs(touchPos.x-_box.pt1.x),2)+pow(fabs(touchPos.y-_box.pt1.y),2));
    d2=sqrtf(pow(fabs(touchPos.x-_box.pt2.x),2)+pow(fabs(touchPos.y-_box.pt2.y),2));
    d3=sqrtf(pow(fabs(touchPos.x-_box.pt3.x),2)+pow(fabs(touchPos.y-_box.pt3.y),2));
    d4=sqrtf(pow(fabs(touchPos.x-_box.pt4.x),2)+pow(fabs(touchPos.y-_box.pt4.y),2));
    
    min=d1; closest=_box.pt1; _drag=DRAG_POINT_1;
    if (d2<min) { min=d2; closest=_box.pt2; _drag=DRAG_POINT_2;}
    if (d3<min) { min=d3; closest=_box.pt3; _drag=DRAG_POINT_3;}
    if (d4<min) { min=d4; closest=_box.pt4; _drag=DRAG_POINT_4;}
    
    //TGLog(@"drag is point %f", min);
    if (min>30.0) 
    {
        _drag=DRAG_POINT_NONE;
        return FALSE;
    }
    
    _dragPoint=closest;
    return TRUE;
}

-(void) changeDragPoint:(CGPoint)touchPos
{
    switch (_drag)
    {
        case DRAG_POINT_1: _box.pt1=touchPos; break;
        case DRAG_POINT_2: _box.pt2=touchPos; break;
        case DRAG_POINT_3: _box.pt3=touchPos; break;
        case DRAG_POINT_4: _box.pt4=touchPos; break;
        default: return; break;
    }
    
    [self setNeedsDisplay];
    
}


@end
