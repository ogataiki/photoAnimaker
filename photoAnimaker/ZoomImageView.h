#import <UIKit/UIKit.h>

@interface ZoomImageView : UIScrollView <UIScrollViewDelegate>
{
    UIImageView *imageView_;
}

- (void)chgImage:(UIImage*)image;
- (void)setImage:(UIImage*)image;

@end
