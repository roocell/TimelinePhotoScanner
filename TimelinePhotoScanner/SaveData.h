//
//  SaveData.h
//  bohdana
//
//  Created by michael russell on 11-02-14.
//  Copyright 2011 roocell. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kFilename	@"tps-SD"
#define kDataKey	@"tps-SD"

#define kKeyLat			@"lat"
#define kKeyLng			@"lng"
#define kKeySLat		@"slat"
#define kKeySLng		@"slng"
#define kKeyPlace		@"place"
#define kKeyDate        @"date"

@interface SaveData : NSObject

@property (retain, nonatomic) NSNumber* lat;
@property (retain, nonatomic) NSNumber* lng;
@property (retain, nonatomic) NSNumber* spanLat;
@property (retain, nonatomic) NSNumber* spanLng;
@property (retain, nonatomic) NSDictionary* placeJson;
@property (retain, nonatomic) NSDate* date;

-(void)writeToSaveData;
-(NSString*) dataFilePath;
-(void) setDefaults;
-(void) removePreviousSavedData;

@end
