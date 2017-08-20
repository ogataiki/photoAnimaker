#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#import "FilterBase.h"
#import "LineFilter.h"

@interface AnimeFilter : NSObject

+ (UIImage*)animeImageMake:(UIImage*)image level:(NSInteger)level edge:(BOOL)edge;

@end
