#import "RootView.h"


@implementation RootView
@synthesize touchDelegate;

- (id)initWithFrame:(CGRect)frame
{
	if( (self = [super initWithFrame:frame]) )
	{
		self.userInteractionEnabled = YES;
		self.multipleTouchEnabled = YES;
	}
	
	return self;
}


//常にファーストレスポンダとする
- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
	[self becomeFirstResponder];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[touchDelegate view:self touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[touchDelegate view:self touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[touchDelegate view:self touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[touchDelegate view:self touchesCancelled:touches withEvent:event];
}




- (void)dealloc
{
	[super dealloc];
}

@end
