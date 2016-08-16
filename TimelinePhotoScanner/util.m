//
//  util.m
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-04-21.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#include "util.h"
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

void addBorderAndShadow(UIView* view, float borderWidth, float shadowWidth)
{    
    // make sure we dont keep adding shadows
    if (view.layer.shadowRadius==10.0f) return;
    
    //http://blog.barrettj.com/2010/10/of-rounded-corners-and-drop-shadows-how-to-turn-your-uiimageview-into-an-icon/
    if (borderWidth>0.0)
    {
        view.layer.borderColor = [UIColor whiteColor].CGColor;
        view.layer.borderWidth = borderWidth;
    }
    // WARNING: shadows make for slow carousel animations!!
    // it shawdows EVERYTHING In the view
#if 1
    view.layer.shadowColor = [[UIColor blackColor] CGColor];
    view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    view.layer.shadowOpacity = 0.7f;
    view.layer.shadowRadius = shadowWidth;
    
    // http://nachbaur.com/blog/fun-shadow-effects-using-custom-calayer-shadowpaths
    // this makes it faster
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.shadowPath = path.CGPath;
#else
    
    UIView* shadow=[[UIView alloc] initWithFrame:CGRectMake(-5, -5, view.frame.size.width+10, view.frame.size.height+10)];
    shadow.backgroundColor=[UIColor darkGrayColor];
    [view addSubview:shadow];
    [view sendSubviewToBack:shadow];
#endif 
}
void addShadow(UIView* view, UIImageView* iv, float shadowWidth)
{
    // make sure we dont keep adding shadows
    if (view.layer.shadowRadius==10.0f) return;
    
    iv.layer.borderColor = [UIColor whiteColor].CGColor;
    iv.layer.borderWidth = 2.0;
    
    UIView* shadowView = [[UIView alloc] initWithFrame:iv.frame];
    addBorderAndShadow(shadowView, 2.0, shadowWidth);    
    [view addSubview:shadowView];
    [view sendSubviewToBack:shadowView];
    
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
}

NSString* decodeStringFromServer(NSString* source)
{
    const char* encodedCStr=[source cStringUsingEncoding:NSISOLatin1StringEncoding];
    return [[NSString alloc]initWithCString:encodedCStr encoding:NSUTF8StringEncoding];
}
