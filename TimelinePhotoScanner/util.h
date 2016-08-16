/*
 *  util.h
 *
 *  Created by michael russell on 10-11-15.
 *  Copyright 2010 Thumb Genius Software. All rights reserved.
 *
 */


#define TGLog(message, ...) NSLog(@"%s:%d %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:message, ##__VA_ARGS__])

typedef struct
{
    CGPoint pt1;    
    CGPoint pt2;
    CGPoint pt3;
    CGPoint pt4;
} bBox;

#define NAVBAR_OFFSET (44.0+20.0)/2
#define IMAGE_VIEW_HEIGHT 367.0
#define IMAGE_VIEW_WIDTH  320.0

#define FACEBOOK_APPID @"310809355654008"
#define FACEBOOK_SECRET @"310338ea42a71a071094ce871ec6814d"

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

void addBorderAndShadow(UIView* view, float borderWidth, float shadowWidth);
void addShadow(UIView* view, UIImageView* iv, float shadowWidth);
NSString* decodeStringFromServer(NSString* source);
