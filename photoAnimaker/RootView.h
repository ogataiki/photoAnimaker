#import <UIKit/UIKit.h>
#import "TouchesDelegate.h"


@interface RootView : UIView 
{
	id<TouchesDelegate>	touchDelegate;
}

@property (nonatomic, retain) id touchDelegate;

@end
