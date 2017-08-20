#import "LineFilter.h"

@implementation LineFilter

+ (CGImageRef)doFilter:(CGImageRef)image param1:(UInt8)prm1 param2:(UInt8)prm2;
{
    // 1.CGImageからIplImageを作成
    IplImage *srcImage       = [FilterBase newIplImageFromCGImage:image];
    
    IplImage *grayscaleImage = cvCreateImage(cvGetSize(srcImage), IPL_DEPTH_8U, 1);
    IplImage *edgeImage      = cvCreateImage(cvGetSize(srcImage), IPL_DEPTH_8U, 1);
    IplImage *dstImage       = cvCreateImage(cvGetSize(srcImage), IPL_DEPTH_8U, 3);

    cvCvtColor(srcImage, grayscaleImage, CV_BGR2GRAY);
    cvSmooth(grayscaleImage, grayscaleImage, CV_GAUSSIAN, 3, 0, 0);
    cvCanny(grayscaleImage, edgeImage, prm1, prm2);
    cvNot(edgeImage, edgeImage);
    cvCvtColor(edgeImage, dstImage, CV_GRAY2BGR);
    
    // 7.IplImageからCGImageを作成
    CGImageRef effectedImage = [FilterBase newCGImageFromIplImage:dstImage];

    cvReleaseImage(&grayscaleImage);
    cvReleaseImage(&edgeImage);

    cvReleaseImage(&srcImage);
    cvReleaseImage(&dstImage);
    
    // 8.白色の部分を透過する
    const float colorMasking[6] = {255, 255, 255, 255, 255, 255};
    effectedImage = CGImageCreateWithMaskingColors(effectedImage, colorMasking);
    
    return effectedImage;
}

@end
