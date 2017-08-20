#import "FilterBase.h"

@implementation FilterBase


- (CGImageRef)doFilter:(CGImageRef)image
{
    CGImageRetain(image);
    
    // 必要なら呼び出し側でCGImageReleaseによりメモリを解放すること
    return image;
}

+ (IplImage *)newIplImageFromCGImage:(CGImageRef)image
{
    CGContextRef context;
    CGColorSpaceRef colorSpace;
    IplImage *iplImageTemp, *iplImage;
    
    // RGB色空間を作成
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 一時的なIplImageを作成
    iplImageTemp = cvCreateImage(cvSize(CGImageGetWidth(image), CGImageGetHeight(image)), IPL_DEPTH_8U, 4);
    
    // CGBitmapContextをIplImageのビットマップデータのポインタから作成
    context = CGBitmapContextCreate(iplImageTemp->imageData,
                                    iplImageTemp->width,
                                    iplImageTemp->height,
                                    iplImageTemp->depth,
                                    iplImageTemp->widthStep,
                                    colorSpace,
                                    kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
    
    // CGImageをCGBitmapContextに描画
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    
    // ビットマップコンテキストと色空間を解放
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // 最終的なIplImageを作成
    iplImage = cvCreateImage(cvGetSize(iplImageTemp), IPL_DEPTH_8U, 3);
    cvCvtColor(iplImageTemp, iplImage, CV_RGBA2RGB);
    
    // 一時的なIplImageを解放
    cvReleaseImage(&iplImageTemp);
    
    // 必要なら呼び出し側でcvReleaseImageよりメモリを解放すること
    return iplImage;
}

+ (CGImageRef)newCGImageFromIplImage:(IplImage *)image
{
    CGColorSpaceRef colorSpace;
    NSData *data;
    CGDataProviderRef provider;
    CGImageRef cgImage;
    
    // RGB色空間
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // IplImageのビットマップデータのポインタアドレスからNSDataを作成
    data = [NSData dataWithBytes:image->imageData length:image->imageSize];
    provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    
    // CGImageを作成
    cgImage = CGImageCreate(image->width,
                            image->height,
                            image->depth,
                            image->depth * image->nChannels,
                            image->widthStep,
                            colorSpace,
                            kCGImageAlphaNone | kCGBitmapByteOrderDefault,
                            provider,
                            NULL,
                            false,
                            kCGRenderingIntentDefault);
    
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(provider);
    
    // 必要なら呼び出し側でCGImageReleaseによりメモリを解放すること
    return cgImage;
}

+ (IplImage *)CreateIplImageFromUIImage:(UIImage *)image
{
	CGImageRef imageRef = image.CGImage;
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	IplImage *iplimage = cvCreateImage(cvSize(image.size.width, image.size.height), IPL_DEPTH_8U, 4);
	CGContextRef contextRef = CGBitmapContextCreate(iplimage->imageData, iplimage->width, iplimage->height,
													iplimage->depth, iplimage->widthStep,
													colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
	CGContextDrawImage(contextRef, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
	CGContextRelease(contextRef);
	CGColorSpaceRelease(colorSpace);
    
	IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
	cvCvtColor(iplimage, ret, CV_RGBA2BGR);
	cvReleaseImage(&iplimage);
    
	return ret;
}

+ (UIImage *)UIImageFromIplImage:(IplImage *)image orientation:(UIImageOrientation)orientation
{
	//NSLog(@"IplImage (%d, %d) %d bits by %d channels, %d bytes/row %s", image->width, image->height, image->depth, image->nChannels, image->widthStep, image->channelSeq);
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
	CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
	CGImageRef imageRef = CGImageCreate(image->width, image->height,
										image->depth, image->depth * image->nChannels, image->widthStep,
										colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
										provider, NULL, false, kCGRenderingIntentDefault);
	UIImage *ret = [UIImage imageWithCGImage:imageRef scale:1.0f orientation:orientation];
	CGImageRelease(imageRef);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorSpace);
	return ret;
}

@end
