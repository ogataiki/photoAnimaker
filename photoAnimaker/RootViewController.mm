#import "RootViewController.h"

@implementation RootViewController

@synthesize rootView = rootView_;

NSString *backNames[2][4] =
{
    //iphone
    {
        @"start_for_iphone_640_920.png",    //4,4s statusbar
        @"start_for_iphone_640_960.png",    //4,4s
        @"start_for_iphone_640_1096.png",   //5,5s statusbar
        @"start_for_iphone_640_1136.png"    //5,5s
    },
    //ipad
    {
        @"start_for_ipad_1536_2008.png",    //height statusbar
        @"start_for_ipad_1536_2048.png",    //height
        @"start_for_ipad_2048_1496.png",    //width statusbar
        @"start_for_ipad_2048_1536.png"     //width
    }
};

- (id)init
{
	if( (self = [super init]) )
	{
	}

	return self;
}


//画面表示時に１度だけコール
- (void)viewDidLoad
{
	[super viewDidLoad];

    mode_ = 0;

    //起動時の向き取得
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    //画面サイズ設定
    winSizePortrait_ = WINSIZE;
    winSizeLandscape_ = CGRectMake(winSizePortrait_.origin.x,
                                   winSizePortrait_.origin.y,
                                   winSizePortrait_.size.height,
                                   winSizePortrait_.size.width);
    
    CGRect winSize;
    if( (orientation == UIInterfaceOrientationLandscapeLeft)
       || (orientation == UIInterfaceOrientationLandscapeRight) )
    {
        winSize = winSizeLandscape_;
    }
    else
    {
        winSize = winSizePortrait_;
    }
    if(!ISIOS7)
    {
        winSize.origin.y += 20;
        winSize.size.height -= 20;
    }

	//ルートビュー作成
	rootView_ = [[RootView alloc] initWithFrame:winSize];
	rootView_.userInteractionEnabled = YES;
	rootView_.multipleTouchEnabled = YES;
	[rootView_ setTouchDelegate:self];
	self.view = rootView_;

    barH_ = 44;
    
    //プレビュー
    viewerView_ = [[ZoomImageView alloc] initWithFrame:CGRectMake(0, 0, winSize.size.width, winSize.size.height-barH_)];
    [self.view addSubview:viewerView_];
    
    //プレビュー背景
    int device = 0, devtype = 0;
    if(ISIPAD)
    {
        device = 1;
        
        if( (orientation == UIInterfaceOrientationLandscapeLeft)
           || (orientation == UIInterfaceOrientationLandscapeRight) )
        {
            devtype += 2;
        }
        
    }
    else
    {
        if(rootView_.frame.size.height == 568)
        {
            devtype += 2;
        }
    }
    if(ISIOS7)
    {
        devtype += 1;
    }
    viewerBack_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:backNames[device][devtype]]];
    viewerBack_.frame = viewerView_.frame;
    [self.view addSubview:viewerBack_];

    //toolbar
    toolbar_ = [[UIToolbar alloc] initWithFrame:CGRectMake(0, winSize.size.height-barH_,
                                                           winSize.size.width, barH_)];
    toolbar_.barStyle = UIBarStyleBlackOpaque;
    
    [self.view addSubview:toolbar_];
    
    [self toolbarEdit_Boot];
    
    filterAlert_ = [[UIAlertView alloc] initWithTitle:@"please select filter type"
                                              message:nil
                                             delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    otherButtonTitles:@"Soft", @"Hard", @"Bordering", nil];
    filterAlert_.tag = 0;

    as_ = [[UIActionSheet alloc] init];
    as_.delegate = self;
    as_.title = @"Select the photos.";
    [as_ addButtonWithTitle:@"Camera"];
    [as_ addButtonWithTitle:@"Album"];
    [as_ addButtonWithTitle:@"Cancel"];
    as_.cancelButtonIndex = 2;
    as_.tag = 0;

}

//画面表示後にコール
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

//メモリ不足時に呼び出される
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)toolbarEdit_Boot
{
    UIBarButtonItem *spacer = [[[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                target:nil action:nil] autorelease];
    
    UIBarButtonItem *camerabtn = [[[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                   target:self
                                   action:@selector(selectPhoto)]
                                  autorelease];
    camerabtn.style = UIBarButtonItemStyleDone;
    
    UILabel *guidance = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)] autorelease];
    guidance.text = @"← Select the photos.";
    guidance.backgroundColor = [UIColor clearColor];
    guidance.textColor = [UIColor whiteColor];
    UIBarButtonItem *guidancebtn = [[[UIBarButtonItem alloc] initWithCustomView:guidance] autorelease];
    
    NSArray *items = [NSArray arrayWithObjects:camerabtn, guidancebtn, spacer, nil];
    toolbar_.items = items;
}

- (void)toolbarEdit_Viewer
{
    UIBarButtonItem *spacer = [[[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                target:nil action:nil] autorelease];
    
    UIBarButtonItem *camerabtn = [[[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                        target:self
                                                        action:@selector(selectPhoto)]
                                  autorelease];
    camerabtn.style = UIBarButtonItemStyleDone;

    NSArray *arr = [NSArray arrayWithObjects:@"before", @"after", nil];
    beforeAfter_ = [[[UISegmentedControl alloc] initWithItems:arr] autorelease];
    beforeAfter_.frame = CGRectMake(0, 0, 100, 30);
    beforeAfter_.segmentedControlStyle = UISegmentedControlStyleBar;
    beforeAfter_.selectedSegmentIndex = 1;
    [beforeAfter_ addTarget:self action:@selector(beforeAfter) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *bfbtn = [[[UIBarButtonItem alloc] initWithCustomView:beforeAfter_] autorelease];
    
    UIBarButtonItem *morebtn = [[[UIBarButtonItem alloc] initWithTitle:@"filter"
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self
                                                                action:@selector(moreFilter)] autorelease];

    UIBarButtonItem *savebtn = [[[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                 target:self
                                 action:@selector(savePhoto)]
                                autorelease];

    NSArray *items = [NSArray arrayWithObjects:camerabtn, spacer, morebtn, spacer, bfbtn, spacer, savebtn, nil];
    toolbar_.items = items;
}

- (void)viewsOrientationChange:(UIInterfaceOrientation)orientation
{
    CGRect winSize;
    if( (orientation == UIInterfaceOrientationLandscapeLeft)
       || (orientation == UIInterfaceOrientationLandscapeRight) )
    {
        winSize = winSizeLandscape_;
    }
    else
    {
        winSize = winSizePortrait_;
    }
    if(!ISIOS7)
    {
        winSize.origin.y += 20;
        winSize.size.height -= 20;
    }
    rootView_.frame = winSize;
    
    //プレビュー
    [viewerView_ removeFromSuperview];
    [viewerView_ release];
    viewerView_ = [[ZoomImageView alloc] initWithFrame:CGRectMake(0, 0, winSize.size.width, winSize.size.height-barH_)];
    [self.view addSubview:viewerView_];
    if( beforeAfter_.selectedSegmentIndex == 0 )
    {
        [viewerView_ setImage:image_];
    }
    else if( beforeAfter_.selectedSegmentIndex == 1 )
    {
        [viewerView_ setImage:animeImage_];
    }
    
    if(viewerBack_ != nil)
    {
        [viewerBack_ removeFromSuperview];
        [viewerBack_ release];
        int device = 0, devtype = 0;
        if(ISIPAD)
        {
            device = 1;
            
            if( (orientation == UIInterfaceOrientationLandscapeLeft)
               || (orientation == UIInterfaceOrientationLandscapeRight) )
            {
                devtype += 2;
            }
            
        }
        else
        {
            if(rootView_.frame.size.height == 568)
            {
                devtype += 2;
            }
        }
        if(ISIOS7)
        {
            devtype += 1;
        }
        viewerBack_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:backNames[device][devtype]]];
        viewerBack_.frame = viewerView_.frame;
        [self.view addSubview:viewerBack_];
    }
    
    //toolbar
    toolbar_.frame = CGRectMake(0, self.view.frame.size.height-barH_,
                                winSize.size.width, barH_);
}

- (void)filterExec:(NSInteger)level edge:(BOOL)edge
{
    aiView_ = [[UIView alloc] init];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if( (orientation == UIInterfaceOrientationLandscapeLeft)
       || (orientation == UIInterfaceOrientationLandscapeRight) )
    {
        aiView_.frame = CGRectMake(0, 0, rootView_.frame.size.height, rootView_.frame.size.width);
    }
    else
    {
        aiView_.frame = CGRectMake(0, 0, rootView_.frame.size.width, rootView_.frame.size.height);
    }
    aiView_.backgroundColor = [UIColor blackColor];
    aiView_.alpha = 0.5;
    [self.view addSubview:aiView_];
    
    ai_ = [[UIActivityIndicatorView alloc] initWithFrame:viewerView_.frame];
    ai_.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self.view addSubview:ai_];
    [ai_ startAnimating];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
    
    //アニメ調画像作成
    animeImage_ = [[AnimeFilter animeImageMake:animeImage_ level:level edge:edge] retain];

    [ai_ stopAnimating];
    [ai_ removeFromSuperview];
    [ai_ release];
    [aiView_ removeFromSuperview];
    [aiView_ release];

    beforeAfter_.selectedSegmentIndex = 1;
    [viewerView_ setImage:animeImage_];
}

- (void)selectPhoto
{
    //写真撮影とフォトライブラリから取得を選択
    as_.tag = 1;
    if(ISIPAD)
    {
        [as_ showFromRect:CGRectMake(toolbar_.frame.origin.x, toolbar_.frame.origin.y, 100, 100)
                   inView:self.view
                 animated:YES];
    }
    else
    {
        [as_ showInView:self.view];
    }
}

- (void)moreFilter
{
    filterAlert_.tag = 1;
    [filterAlert_ show];
}

- (void)beforeAfter
{
    if( beforeAfter_.selectedSegmentIndex == 0 )
    {
        [viewerView_ chgImage:image_];
    }
    else if( beforeAfter_.selectedSegmentIndex == 1 )
    {
        [viewerView_ chgImage:animeImage_];
    }
}

- (void)savePhoto
{
    aiView_ = [[UIView alloc] init];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if( (orientation == UIInterfaceOrientationLandscapeLeft)
       || (orientation == UIInterfaceOrientationLandscapeRight) )
    {
        aiView_.frame = CGRectMake(0, 0, rootView_.frame.size.height, rootView_.frame.size.width);
    }
    else
    {
        aiView_.frame = CGRectMake(0, 0, rootView_.frame.size.width, rootView_.frame.size.height);
    }
    aiView_.backgroundColor = [UIColor blackColor];
    aiView_.alpha = 0.5;
    [self.view addSubview:aiView_];
    
    ai_ = [[UIActivityIndicatorView alloc] initWithFrame:viewerView_.frame];
    ai_.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self.view addSubview:ai_];
    [ai_ startAnimating];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];

    toolbar_.userInteractionEnabled = NO;
    
    UIImageWriteToSavedPhotosAlbum(animeImage_,
                                   self,
                                   @selector(finishExport:didFinishSavingWithError:contextInfo:),
                                   nil);    
}

- (void)finishExport:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    toolbar_.userInteractionEnabled = YES;

    [ai_ stopAnimating];
    [ai_ removeFromSuperview];
    [ai_ release];
    [aiView_ removeFromSuperview];
    [aiView_ release];
}


//-----------------------------------------
//-----------------------------------------
//UIActionSheetデリゲート

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    as_.tag = 0;
    
    if( buttonIndex == 0 )
    {
        //カメラ呼び出し
        mode_ = MODE_CAMERA;
        UIImagePickerController *ipc = [[[UIImagePickerController alloc] init] autorelease];
        [ipc setDelegate:self];
        [ipc setSourceType:UIImagePickerControllerSourceTypeCamera];
        [ipc setAllowsEditing:NO];
        [self presentViewController:ipc animated:YES completion:nil];
    }
    else if( buttonIndex == 1 )
    {
        //フォトライブラリ呼び出し
        mode_ = MODE_SELECTPHOTO;
        if(ISIPAD)
        {
            UIImagePickerController *ipc = [[[UIImagePickerController alloc] init] autorelease];
            [ipc setDelegate:self];
            [ipc setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [ipc setAllowsEditing:NO];
            imagePickerPopover_ = [[UIPopoverController alloc] initWithContentViewController:ipc];
            imagePickerPopover_.delegate = self;
            [imagePickerPopover_ presentPopoverFromRect:CGRectMake(toolbar_.frame.origin.x,
                                                                   toolbar_.frame.origin.y,
                                                                   100, 100)
                                                 inView:self.view
                               permittedArrowDirections:UIPopoverArrowDirectionAny
                                               animated:YES];
        }
        else
        {
            //フォトライブラリ呼び出し
            UIImagePickerController *ipc = [[[UIImagePickerController alloc] init] autorelease];
            [ipc setDelegate:self];
            [ipc setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [ipc setAllowsEditing:NO];
            [self presentViewController:ipc animated:YES completion:nil];
        }
    }
}

//popoverが非表示となったタイミングで呼び出し
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if( mode_ == MODE_SELECTPHOTO )
    {
        [imagePickerPopover_ release];
        mode_ = 0;
    }
    
    if( as_.tag == 1 )
    {
        as_.tag = 0;
    }
}

//-----------------------------------------
//-----------------------------------------
//UIAlertViewデリゲート

//アラートのボタンが押された時に呼ばれるデリゲート例文
-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
}

//アラートが閉じた後に呼ばれる
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if( buttonIndex != 0 && filterAlert_.tag == 1 )
    {
        if( beforeAfter_.selectedSegmentIndex == 0 )
        {
            [animeImage_ release];
            animeImage_ = nil;
            animeImage_ = [image_ retain];
        }        
    }
    filterAlert_.tag = 0;

    if( buttonIndex == 1 )
    {
        [self filterExec:1 edge:0];
    }
    else if( buttonIndex == 2 )
    {
        [self filterExec:0 edge:0];
    }
    else if( buttonIndex == 3 )
    {
        [self filterExec:0 edge:1];
    }
}


//-----------------------------------------
//-----------------------------------------
//画像取得デリゲートメソッド

//画像が選択されたときに呼び出される
- (void)imagePickerController:(UIImagePickerController*)picker
		didFinishPickingImage:(UIImage*)image
				  editingInfo:(NSDictionary*)editingInfo
{
    [self toolbarEdit_Viewer];

    for( int i=[image_ retainCount]; i<0; i++ )
    {
        [image_ release];
    }
    
    for( int i=[animeImage_ retainCount]; i<0; i++ )
    {
        [animeImage_ release];
    }
    
    image_ = nil;
    animeImage_ = nil;
    image_ = [image retain];
    animeImage_ = [image retain];
    [viewerView_ setImage:image_];
    
    if(viewerBack_ != nil)
    {
        [viewerBack_ removeFromSuperview];
        [viewerBack_ release];
        viewerBack_ = nil;
    }
    
    [toolbar_ removeFromSuperview];
    [self.view addSubview:toolbar_];
    
    if( mode_ == MODE_CAMERA )
    {
        [self viewsOrientationChange:[[UIApplication sharedApplication] statusBarOrientation]];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        if(ISIPAD)
        {
            [imagePickerPopover_ dismissPopoverAnimated:YES];
            [imagePickerPopover_ release];
        }
        else
        {
            [self viewsOrientationChange:[[UIApplication sharedApplication] statusBarOrientation]];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    mode_ = 0;

    filterAlert_.tag = 0;
    [filterAlert_ show];
}

//画像の選択がキャンセルされたときに呼ばれる
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if( mode_ == MODE_CAMERA )
    {
        [self viewsOrientationChange:[[UIApplication sharedApplication] statusBarOrientation]];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        if(ISIPAD)
        {
            [imagePickerPopover_ dismissPopoverAnimated:YES];
            [imagePickerPopover_ release];
        }
        else
        {
            [self viewsOrientationChange:[[UIApplication sharedApplication] statusBarOrientation]];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    mode_ = 0;
}






//タッチしたときにコール
- (void)view:(UIView*)view touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
}

//ドラッグしたときにコール
- (void)view:(UIView*)view touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
}

//タッチ終了時にコール
- (void)view:(UIView*)view touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
}

//割り込みによるタッチキャンセル時にコール
- (void)view:(UIView*)view touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
}

- (BOOL)shouldAutorotate
{
    //YESなら回転する
    if(ISIPAD)
    {
        return YES;
    }

	return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if(ISIPAD)
    {
        return UIInterfaceOrientationMaskAll;
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

//画面回転をする場合に呼ばれる
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [self viewsOrientationChange:toInterfaceOrientation];
    
    if(mode_ == MODE_SELECTPHOTO && ISIPAD)
    {
        [imagePickerPopover_ dismissPopoverAnimated:YES];
    }
    
    if( as_.tag == 1 )
    {
        [as_ dismissWithClickedButtonIndex:-1 animated:YES];
    }
}

//画面回転が終わったら呼ばれる
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if(mode_ == MODE_SELECTPHOTO && ISIPAD)
    {
        [imagePickerPopover_ presentPopoverFromRect:CGRectMake(toolbar_.frame.origin.x,
                                                               toolbar_.frame.origin.y,
                                                               100, 100)
                                             inView:self.view
                           permittedArrowDirections:UIPopoverArrowDirectionAny
                                           animated:YES];
    }
    
    if( as_.tag == 1 )
    {
        [self selectPhoto];
    }
}

- (void)dealloc
{
    aiView_ = nil;
    ai_ = nil;
    
    if(mode_ == MODE_SELECTPHOTO && ISIPAD)
    {
        [imagePickerPopover_ release];
    }
    
    [as_ release];
    [filterAlert_ release];
    [beforeAfter_ release];
    [toolbar_ removeFromSuperview];
    [toolbar_ release];
    [viewerView_ release];
    
    if(viewerBack_ != nil)
    {
        [viewerBack_ release];
    }
    
	[rootView_ release];

	[super dealloc];
}

@end
