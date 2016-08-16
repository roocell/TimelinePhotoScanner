//
//  CSMapAnnotation.h
//  mapLines
//
//  Created by Craig on 5/15/09.
//  Copyright 2009 Craig Spitzkoff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

// types of annotations for which we will provide annotation views. 
typedef enum {
	CSMapAnnotationTypeStart = 0,
	CSMapAnnotationTypeEnd   = 1,
	CSMapAnnotationTypeImage = 2,
    CSMapAnnotationTypeLabel = 3
} CSMapAnnotationType;

@interface CSMapAnnotation : NSObject <MKAnnotation>
{
	CLLocationCoordinate2D _coordinate;
	CSMapAnnotationType    _annotationType;
	NSString*              _title;
	NSString*              _userData;
	UIImage*              _imgData;
	NSURL*                 _url;
	NSData*                userObject;
	NSString*			   reuseIdentifier;
}

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate 
		  annotationType:(CSMapAnnotationType) annotationType
				   title:(NSString*)title
			reuseIdentifier:(NSString*)reuseId;

@property CSMapAnnotationType annotationType;
@property (nonatomic, retain) NSString* userData;
@property (nonatomic, retain) UIImage* imgData;
@property (nonatomic, retain) NSURL* url;
@property (nonatomic, retain) NSData* userObject;
@property (nonatomic, retain) NSString*			   reuseIdentifier;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@end
