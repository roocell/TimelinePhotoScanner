//
//  CSLabelAnnotationView.m
//  ocua
//
//  Created by michael russell on 11-03-29.
//  Copyright 2011 Thumb Genius Software. All rights reserved.
//

#import "CSLabelAnnotationView.h"
#import "CSMapAnnotation.h"
#import "util.h"

@implementation CSLabelAnnotationView
@synthesize label = _label;

#define kWidth  100
#define kHeight 20

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	self.frame = CGRectMake(0, 0, kWidth, kHeight);
	
	CSMapAnnotation* csAnnotation = (CSMapAnnotation*)annotation;	
	_label = [[UILabel alloc] initWithFrame:self.frame];
    _label.text=csAnnotation.title;
    _label.textAlignment=UITextAlignmentCenter;
	_label.backgroundColor = [UIColor clearColor];
    _label.textColor=[UIColor whiteColor];
    
    _label.font = [UIFont fontWithName:@"Arial-BoldMT" size: 12.0];
 	//_label.shadowColor = [UIColor blackColor];
	//_label.shadowOffset = CGSizeMake(1,1);
   
    [self addSubview:_label];
	return self;
	
}
#if 0
- (void)prepareForReuse
{
	TGLog(@"");
	[_imageView removeFromSuperview];
	[_imageView release];
}
#endif

-(void) dealloc
{
	[_label release];
	[super dealloc];
}
@end
