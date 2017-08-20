#import <Foundation/Foundation.h>

#define WINSIZE [[UIScreen mainScreen] bounds]

#define ISIOS7 (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
#define ISIPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IADHEIGHT_PORTRAIT      ((ISIPAD) ? 66 : 50)
#define IADHEIGHT_LANDSCAPE     ((ISIPAD) ? 66 : 32)
#define IADHEIGHT(orientation)  ((((orientation) == UIInterfaceOrientationLandscapeLeft) || ((orientation) == UIInterfaceOrientationLandscapeRight)) ? IADHEIGHT_LANDSCAPE : IADHEIGHT_PORTRAIT)

