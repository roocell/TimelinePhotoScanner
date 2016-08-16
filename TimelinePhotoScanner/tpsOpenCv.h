//
//  tpsOpenCv.h
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-02-23.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "util.h"


@interface tpsOpenCv : NSObject

-(bBox) getBoundingBoxCorners:(UIImage*) image imageView:(UIImageView*) iv;
-(UIImage*) deskew:(bBox) box  image:(UIImage*) image;

-(CGPoint) scaleScreenPointToImage:(CGPoint)point image:(UIImage*)_image imageView:(UIImageView*)_iv;

@end
