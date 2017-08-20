#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MyMacros.h"
#import "TouchesDelegate.h"
#import "RootView.h"
#import "FilterBase.h"
#import "LineFilter.h"
#import "AnimeFilter.h"
#import "ZoomImageView.h"

#define MODE_SELECTPHOTO    1
#define MODE_CAMERA         2

@interface RootViewController : UIViewController
<TouchesDelegate,
 UIAlertViewDelegate,
 UIActionSheetDelegate,
 UINavigationControllerDelegate,
 UIImagePickerControllerDelegate,
 UIPopoverControllerDelegate>
{
	//common
	RootView                    *rootView_;
    CGRect                      winSizePortrait_;
    CGRect                      winSizeLandscape_;
    UIView                      *aiView_;
    UIActivityIndicatorView     *ai_;
    UIAlertView                 *filterAlert_;
    UIActionSheet               *as_;
    
    //camera
    UIImage                     *image_;
    UIImage                     *animeImage_;
    UIPopoverController         *imagePickerPopover_;
    NSInteger                   mode_;
    
    //toolbar
    UIToolbar                   *toolbar_;
    NSInteger                   barH_;
    UISegmentedControl          *beforeAfter_;
    
    //viewer
    ZoomImageView               *viewerView_;
    UIImageView                 *viewerBack_;
}

@property (nonatomic, retain) RootView *rootView;

- (void)toolbarEdit_Boot;
- (void)toolbarEdit_Viewer;
- (void)viewsOrientationChange:(UIInterfaceOrientation)orientation;

- (void)filterExec:(NSInteger)level edge:(BOOL)edge;
- (void)selectPhoto;
- (void)moreFilter;
- (void)beforeAfter;
- (void)savePhoto;

@end
