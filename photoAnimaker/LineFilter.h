#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>
#import "FilterBase.h"

@interface LineFilter : NSObject

+ (CGImageRef)doFilter:(CGImageRef)image param1:(UInt8)prm1 param2:(UInt8)prm2;

@end
