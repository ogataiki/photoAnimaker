#import "AnimeFilter.h"

@implementation AnimeFilter

+ (UIImage*)animeImageMake:(UIImage*)image level:(NSInteger)level edge:(BOOL)edge
{
    UIImage *outImage;
    
    UIImageOrientation orientation = image.imageOrientation;
    
    CGImageRef cgImage = image.CGImage;
    size_t height = CGImageGetHeight(cgImage);
    size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
    size_t imageBytes = bytesPerRow * height;
    //NSLog(@"%ld", imageBytes);
    
    //--------------
    //--------------
    //opencvで加工
    IplImage *cv_image = [FilterBase newIplImageFromCGImage:cgImage];
    
    //あまりに大きい画像の場合は縮小する
    if( imageBytes > 30000000 )
    {
        IplImage *min_image = cvCreateImage(cvSize(cv_image->width/2, cv_image->height/2), IPL_DEPTH_8U, 3);
        cvResize(cv_image, min_image, CV_INTER_AREA);
        cvReleaseImage(&cv_image);
        cv_image = cvCloneImage(min_image);
        cvReleaseImage(&min_image);
    }
    else if( imageBytes > 10000000 )
    {
        IplImage *min_image = cvCreateImage(cvSize((cv_image->width*2)/3, (cv_image->height*2)/3), IPL_DEPTH_8U, 3);
        cvResize(cv_image, min_image, CV_INTER_AREA);
        cvReleaseImage(&cv_image);
        cv_image = cvCloneImage(min_image);
        cvReleaseImage(&min_image);
    }
    
    IplImage *gauss;
    int gaussLevel = 5;
    if(level == 0)
    {
        gaussLevel = 5;
    }
    else
    {
        gaussLevel = 7;
    }
    
    IplImage *bilateral;
    int bilateralLevel;
    if(level == 0)
    {
        bilateralLevel = 50;
    }
    else
    {
        bilateralLevel = 50;
    }
    int bilateralLevel2;
    if(level == 0)
    {
        bilateralLevel2 = 9;
    }
    else
    {
        bilateralLevel2 = 11;
    }
    
    IplImage *unsharp;
    float k;
    if(level == 0)
    {
        k = 12.0f;
    }
    else
    {
        k = 9.0f;
    }
    float KernelData[] =
    {
        -k/9.0f,        -k/9.0f, -k/9.0f,
        -k/9.0f, 1 + (8*k)/9.0f, -k/9.0f,
        -k/9.0f,        -k/9.0f, -k/9.0f,
    };
    CvMat kernel = cvMat(3, 3, CV_32F, KernelData);
    
    int filterCount = 2;
    if(level == 0)
    {
        filterCount = 1;
    }
    else
    {
        filterCount = 1;
    }
    for( int i=0; i<filterCount; i++ )
    {
        //ガウシアンフィルタ
        gauss = cvCloneImage(cv_image);
        cvSmooth(cv_image, gauss, CV_GAUSSIAN, gaussLevel, 0, 0);
        cvReleaseImage(&cv_image);
        cv_image = cvCloneImage(gauss);
        cvReleaseImage(&gauss);
        
        //バイラテラルフィルタ
        bilateral = cvCloneImage(cv_image);
        cvSmooth(cv_image, bilateral, CV_BILATERAL, bilateralLevel2, bilateralLevel2, bilateralLevel, 100);
        cvReleaseImage(&cv_image);
        cv_image = cvCloneImage(bilateral);
        cvReleaseImage(&bilateral);
        
        //ガウシアンフィルタ
        gauss = cvCloneImage(cv_image);
        cvSmooth(cv_image, gauss, CV_GAUSSIAN, 5, 0, 0);
        cvReleaseImage(&cv_image);
        cv_image = cvCloneImage(gauss);
        cvReleaseImage(&gauss);
        
        //アンシャープマスク
        unsharp = cvCloneImage(cv_image);
        cvFilter2D(cv_image, unsharp, &kernel);
        cvReleaseImage(&cv_image);
        cv_image = cvCloneImage(unsharp);
        cvReleaseImage(&unsharp);
    }
    
    //セグメント化
    int prmLevel = 2;
    CvRect roi;
    roi.x = roi.y = 0;
    roi.width = cv_image->width & -(1 << prmLevel);
    roi.height = cv_image->height & -(1 << prmLevel);
    cvSetImageROI(cv_image, roi);
    IplImage *seg = cvCloneImage(cv_image);
    cvPyrMeanShiftFiltering(cv_image, seg, 3.0, 16.0, prmLevel,
                            cvTermCriteria(CV_TERMCRIT_ITER+CV_TERMCRIT_EPS, 5, 1));
    cvReleaseImage(&cv_image);
    cv_image = cvCloneImage(seg);
    cvReleaseImage(&seg);
    
    cgImage = [FilterBase newCGImageFromIplImage:cv_image];
    cvReleaseImage(&cv_image);
    
    outImage = [UIImage imageWithCGImage:cgImage scale:1.0f orientation:orientation];
    
    //--------------
    //--------------
    //輪郭合成
    if( edge == YES )
    {
        UIImage *lineImage = [UIImage imageWithCGImage:[LineFilter doFilter:cgImage param1:200 param2:250]
                                                 scale:1.0f
                                           orientation:orientation];
        CGRect result = CGRectMake(0, 0, outImage.size.width, outImage.size.height);
        UIGraphicsBeginImageContext(result.size);
        [outImage drawInRect:result];
        [lineImage drawInRect:result];
        outImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    CGImageRelease(cgImage);
    
    return outImage;
}

@end
