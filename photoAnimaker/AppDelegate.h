#import <UIKit/UIKit.h>
#import "MyMacros.h"
#import "RootViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    RootViewController *RootViewController_;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RootViewController *RootViewController;

@end
