//
//  SaveData.m
//  bohdana
//
//  Created by michael russell on 11-02-14.
//  Copyright 2011 roocell. All rights reserved.
//

#import "SaveData.h"
#import "util.h"

@implementation SaveData
@synthesize lat=_lat;
@synthesize lng=_lng;
@synthesize spanLat=_spanLat;
@synthesize spanLng=_spanLng;
@synthesize placeJson=_placeJson;
@synthesize date=_date;

-(id) init
{
	if (self=[super init])
	{
	}
	return self;
}

#pragma mark -
#pragma mark archiving methods

-(void)encodeWithCoder:(NSCoder*)encoder
{	
	[encoder encodeObject:_lat forKey: kKeyLat];
	[encoder encodeObject:_lng forKey: kKeyLng];	
	[encoder encodeObject:_spanLat forKey: kKeySLat];
	[encoder encodeObject:_spanLng forKey: kKeySLng];	
	[encoder encodeObject:_placeJson forKey: kKeyPlace];	
	[encoder encodeObject:_date forKey: kKeyDate];	
}

-(id)initWithCoder:(NSCoder*)decoder
{
	if (self=[super init])
	{
		self.lat = [decoder decodeObjectForKey:kKeyLat];
		self.lng = [decoder decodeObjectForKey:kKeyLng];		
		self.spanLat = [decoder decodeObjectForKey:kKeySLat];
		self.spanLng = [decoder decodeObjectForKey:kKeySLng];		
		self.placeJson = [decoder decodeObjectForKey:kKeyPlace];		
		self.date = [decoder decodeObjectForKey:kKeyDate];		
	}
	return self;
}

-(id)copyWithZone:(NSZone*)zone
{
	SaveData* copy=[[[self class] allocWithZone:zone] init];
	copy.lat=[self.lat copy];
	copy.lng=[self.lng copy];
	copy.spanLat=[self.spanLat copy];
	copy.spanLng=[self.spanLng copy];
	copy.placeJson=[self.placeJson copy];
	copy.date=[self.date copy];
	return copy;
}


-(NSString*) dataFilePath
{
	NSArray* paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory=[paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
}
-(NSString*) v1_1_dataFilePath
{
	NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory=[paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

-(void) removePreviousSavedData
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[self v1_1_dataFilePath] error:NULL];
}

-(void)writeToSaveData
{
	// assume the data has already been filled in
	TGLog(@"Saving SaveData %@", self.placeJson);
	NSMutableData *data=[[NSMutableData alloc] init];
	NSKeyedArchiver *archiver=[[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:self forKey:kDataKey];
	[archiver finishEncoding];
	[data writeToFile:[self dataFilePath] atomically:YES];
}

-(void) setDefaults
{
	TGLog(@"");
}

@end
