//
//  tpsOpenCv.m
//  TimelinePhotoScanner
//
//  Created by michael russell on 12-02-23.
//  Copyright (c) 2012 Thumb Genius Software. All rights reserved.
//

#import "UIImage+OpenCV.h"
#import "UIImage+Extensions.h"
#import "tpsOpenCv.h"
#import "util.h"


@implementation tpsOpenCv

double angle( cv::Point pt1, cv::Point pt2, cv::Point pt0 );

-(CGPoint) scaleScreenPointToImage:(CGPoint)point image:(UIImage*)_image imageView:(UIImageView*)_iv
{
    float ivw=_iv.frame.size.width;
    float ivh=_iv.frame.size.height;
    float srcw=_image.size.width;
    float srch=_image.size.height;
    
    //TGLog(@"[%f,%f], [%f,%f]", ivw,ivh,srcw,srch);
    
    float scalex=srcw/ivw;
    float scaley=srch/ivh;
    float scale_src=(srch>srcw)?scaley:scalex;

    float posx_insrc=point.x*scale_src;
    float posy_insrc=point.y*scale_src;
    
    float white_barx=(ivw-srcw/scale_src)/2.0;
    float white_bary=(ivh-srch/scale_src)/2.0;
    posx_insrc-=white_barx*scale_src;
    posy_insrc-=white_bary*scale_src;

    return CGPointMake(posx_insrc,posy_insrc);
}

// this magically fixes the orientation ???
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

double angle( cv::Point pt1, cv::Point pt2, cv::Point pt0 ) {
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
}

- (std::vector<std::vector<cv::Point> >)findSquaresInImage:(cv::Mat)_image
{
    std::vector<std::vector<cv::Point> > squares;
    cv::Mat pyr, timg, gray;
    int thresh = 50, N = 11;

    // blur will enhance edge detection
    cv::Mat blurred(_image);
    medianBlur(_image, blurred, 3);

    cv::pyrDown(blurred, pyr, cv::Size(_image.cols/2, _image.rows/2));
    cv::pyrUp(pyr, timg, _image.size());
    std::vector<std::vector<cv::Point> > contours;

    
    for( int l = 0; l < N; l++ ) {
        if( l == 0 ) {
            cv::Canny(blurred, gray, 0, thresh, 5);
            cv::dilate(gray, gray, cv::Mat(), cv::Point(-1,-1));
        }
        else {
            gray = _image >= (l+1)*255/N;
        }
        cv::findContours(gray, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
        std::vector<cv::Point> approx;
        for( size_t i = 0; i < contours.size(); i++ )
        {
            cv::approxPolyDP(cv::Mat(contours[i]), approx, arcLength(cv::Mat(contours[i]), true)*0.02, true);
            if( approx.size() == 4 && fabs(contourArea(cv::Mat(approx))) > 1000 && cv::isContourConvex(cv::Mat(approx))) {
                double maxCosine = 0;
                
                for( int j = 2; j < 5; j++ )
                {
                    double cosine = fabs(angle(approx[j%4], approx[j-2], approx[j-1]));
                    maxCosine = MAX(maxCosine, cosine);
                }
                
                if( maxCosine < 0.3 ) {
                    squares.push_back(approx);
                }
            }
        }
    }
    return squares;
}

-(bBox) getBoundingBoxCorners:(UIImage*) image imageView:(UIImageView*) iv;
{
    TGLog(@"");
    bBox bb;

    // shrink image to make it faster
    UIImage* imageOpenCv=[image imageByScalingProportionallyToSize:CGSizeMake(IMAGE_VIEW_WIDTH,IMAGE_VIEW_HEIGHT)];

    double t = (double)cv::getTickCount();
    cv::Mat tempMat = [imageOpenCv CVMat];
    cv::Mat grayFrame;

    // Convert captured frame to grayscale
    cv::cvtColor(tempMat, grayFrame, cv::COLOR_RGB2GRAY);

    std::vector<std::vector<cv::Point> > squares;
    std::vector<cv::Point> boundingSquare;
    BOOL found=FALSE;
    //find_squares(grayFrame, squares);
    squares=[self findSquaresInImage:grayFrame];
    int i,j;
    TGLog(@"%d squares", squares.size() );
    for(i=0; i<squares.size(); i++)
    {
        std::vector<cv::Point> sq=squares[i];
        TGLog(@"square %d", i);
        BOOL skipit=NO;
        for(j=0; j<sq.size(); j++)
        {
            if (sq[j].x==1)
            {
                // some weird thing where it has a bad rect outside of the image.
                skipit=YES;
            }
            TGLog(@"%d,%d", sq[j].x, sq[j].y);
        }
        if (!skipit) 
        {
            boundingSquare=sq;
            found=TRUE;
        }
    }
    if (squares.size()==0 || !found)
    {
        TGLog(@"didnt find any squares");
        bb.pt1=CGPointMake(100,100);
        bb.pt2=CGPointMake(200,100);
        bb.pt3=CGPointMake(200,200);
        bb.pt4=CGPointMake(100,200);
        return bb;
    }
  
    t = 1000 * ((double)cv::getTickCount() - t) / cv::getTickFrequency();
    
    // Display result 
    //iv.image = [UIImage imageWithCVMat:grayFrame];
        
    // the highest point is boundingSquare[0]
    // have to order it properly
    // (two cases - tilted left or tilted right)
    bb.pt1=CGPointMake(boundingSquare[0].x,boundingSquare[0].y);
    bb.pt2=CGPointMake(boundingSquare[3].x,boundingSquare[3].y);
    bb.pt3=CGPointMake(boundingSquare[2].x,boundingSquare[2].y);
    bb.pt4=CGPointMake(boundingSquare[1].x,boundingSquare[1].y);
    
    // we want
    // 1-----2
    // |     |
    // 4-----3
    
    // sometimes it shows up as
    // 4-----1
    // |     |
    // 3-----2
    
    TGLog(@"[%f,%f] [%f,%f] [%f,%f] [%f,%f]",
          bb.pt1.x, bb.pt1.y,
          bb.pt2.x, bb.pt2.y,
          bb.pt3.x, bb.pt3.y,
          bb.pt4.x, bb.pt4.y);
    
#if 1
    if (bb.pt4.y<bb.pt2.y)
    {
        TGLog(@"tilted left");
        CGPoint t=bb.pt1;
        bb.pt1=bb.pt4;
        bb.pt4=bb.pt3;
        bb.pt3=bb.pt2;
        bb.pt2=t;
    } else {
        TGLog(@"tilted right");
    }
#endif
    return bb;
}



-(UIImage*) deskew:(bBox) box  image:(UIImage*) image
{
    std::vector<cv::Point> not_a_rect_shape;
    not_a_rect_shape.push_back(cv::Point(box.pt1.x, box.pt1.y));
    not_a_rect_shape.push_back(cv::Point(box.pt2.x, box.pt2.y));
    not_a_rect_shape.push_back(cv::Point(box.pt3.x, box.pt3.y));
    not_a_rect_shape.push_back(cv::Point(box.pt4.x, box.pt4.y));

    cv::RotatedRect rbox = minAreaRect(cv::Mat(not_a_rect_shape));
   
    cv::Point2f pts[4];
    rbox.points(pts);
  
    float w=image.size.width;
    float h=image.size.height;
#if 1
    // inverse of what happend to get BB
    if (box.pt1.y<box.pt2.y)
    {
        TGLog(@"tilted right");
        w=rbox.boundingRect().width-1;
        h=rbox.boundingRect().height-1;
    } else {
        TGLog(@"tilted left");
        h=rbox.boundingRect().width-1;
        w=rbox.boundingRect().height-1;
    }
#endif

    cv::Point2f dst_vertices[3];
    dst_vertices[0] = cv::Point(0, 0);
    dst_vertices[1] = cv::Point(w, 0); // Bug was: had mistakenly switched these 2 parameters
    dst_vertices[2] = cv::Point(0, h);

    cv::Point2f src_vertices[3];
    src_vertices[0] = pts[0];
    src_vertices[1] = pts[1];
    src_vertices[2] = pts[3];

    cv::Mat warpAffineMatrix = getAffineTransform(src_vertices, dst_vertices);    
    cv::Mat rotated;
    cv::Size size(w, h);
    cv::Mat src = [image CVMat];
    cv::warpAffine(src, rotated, warpAffineMatrix, size, cv::INTER_LINEAR, cv::BORDER_CONSTANT);

    UIImage* me= [UIImage imageWithCVMat:rotated];
    // rotate 180 degress
    // inverse of what happend to get BB
    UIImage *rotatedImage;
    if (box.pt1.y<box.pt2.y)
    {
        rotatedImage = [me imageRotatedByDegrees:180.0];
    } else {
        rotatedImage = [me imageRotatedByDegrees:-90.0];
    }
        
    TGLog(@"final image size %f,%f", rotatedImage.size.width, rotatedImage.size.height);
    
    // aspect fit to 320X367
    UIImage* scaled=[rotatedImage imageByScalingProportionallyToSize:CGSizeMake(320,367)];
    return scaled;
}

@end
