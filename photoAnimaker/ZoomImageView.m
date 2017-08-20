#import "ZoomImageView.h"

@implementation ZoomImageView

- (id)initWithFrame:(CGRect)frame
{
    if( self = [super initWithFrame:frame] )
    {
        imageView_ = [[[UIImageView alloc] init] retain];
        imageView_.frame = self.bounds;
        imageView_.autoresizesSubviews = YES;
        imageView_.contentMode = UIViewContentModeScaleAspectFit;
        
        self.backgroundColor = [UIColor blackColor];
        self.delegate = self;
        [self addSubview:imageView_];
    }
    
    return self;
}

- (void)chgImage:(UIImage *)image
{
    imageView_.image = image;
}

- (void)setImage:(UIImage *)image
{
    CGSize srcSize = image.size;
    CGSize boundsSize = self.bounds.size;
    self.zoomScale = 1.0;
    self.contentSize = srcSize;
    imageView_.image = image;
    
    
    self.minimumZoomScale = 1.0;
    
    //最大サイズの計算
    //最大サイズは画像のオリジナルサイズだが、画像が小さいときは３倍
    CGFloat imageAspectRate = image.size.width / image.size.height; //画像の縦横比率
    CGFloat viewAspectRate = boundsSize.width / boundsSize.height; //Viewの縦横の比率
    
    if( imageAspectRate > viewAspectRate )
    {
        self.maximumZoomScale = srcSize.width / boundsSize.width;
    }
    else
    {
        self.maximumZoomScale = srcSize.height / boundsSize.height;
    }
    
    if( (srcSize.width < boundsSize.width * 3)
     && (srcSize.height < boundsSize.height * 3) )
    {
        self.maximumZoomScale = 3.0;
    }
    
    self.zoomScale = self.minimumZoomScale;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if( [touch tapCount] > 1 )
    {
        if( self.zoomScale == self.maximumZoomScale )
        {
            [self setZoomScale:self.minimumZoomScale animated:YES];
        }
        else
        {
            [self setZoomScale:self.maximumZoomScale animated:YES];
        }
    }
}



//ビンチイン／ピンチアウトを動かすためのデリゲート
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView_;
}


- (void)dealloc
{
    [imageView_ release];

    [super dealloc];
    
}

@end
