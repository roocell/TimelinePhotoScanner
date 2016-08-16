/*
 *  util.h
 *  OttawaTrafficCams
 *
 *  Created by michael russell on 10-11-15.
 *  Copyright 2010 Thumb Genius Software. All rights reserved.
 *
 */

#if !(TARGET_IPHONE_SIMULATOR)
#define TARGET_STR @"DEV"
#else
#define TARGET_STR @"SIM"
#endif
#define TGLog(message, ...) NSLog(@"%@ %s:%d %@", TARGET_STR, __FUNCTION__, __LINE__, [NSString stringWithFormat:message, ##__VA_ARGS__])

#define kOpenViewDuration  0.5

#define kSubViewOffset 44

#define DroppedPinTag @"Hold Pin To Move"

#define KEYBOARD_ANIMATION_DURATION 0.3