//
//  AppDelegate.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 24/05/2012.
//  Copyright Wicked Little Websites 2012. All rights reserved.
//

#import "AppDelegate.h"
#import "StartScene.h"
//#import "GameScene.h"
//#import "EquipMenuScene.h"
//#import "LevelSelectScene.h"
#import "GameOverFacebookScene.h"
//#import "WorldSelectScene.h"
#import "MKStoreManager.h"
#import "FlurryAnalytics.h"

#import <Parse/Parse.h>

@implementation AppController

@synthesize window=window_, navController=navController_, director=director_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Connect to Parse
    [Parse setApplicationId:@"ku2m9Hu2IJjciLhQT1blymmwo97eOOjgGYS5hpNX"
                  clientKey:@"0rr4JmAqVvRLfsKsonH52X4P5wANvEq5tCQW8bE3"];
    
    [[PHPublisherOpenRequest requestForApp:(NSString *)WDPHToken secret:(NSString *)WDPHSecret] send];
    
    // Connect Parse to Facebook
//    [PFFacebookUtils initializeWithApplicationId:@"292930497469007"];
    [PFFacebookUtils initializeFacebook];
    
    // Start an observer for the store
    [MKStoreManager sharedManager];
    
    // Start the flurry session
    [FlurryAnalytics startSession:@"ZH4F8GJFJSD8C3QBTYR4"];
    [FBSettings publishInstall:@"292930497469007"];
    
    // Cache all music/SFX
    [self cacheSFX];
    
    
    // Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
	director_.wantsFullScreenLayout = YES;
    
	// Display FSP and SPF
	[director_ setDisplayStats:NO];

	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];

	// attach the openglView to the director
	[director_ setView:glView];

	// for rotation and other messages
    [director_ setDelegate:self];

	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
    //[director setProjection:kCCDirectorProjection3D];
    
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// Create a Navigation Controller with the Director
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;

	// set the Navigation Controller as the root view controller
	[window_ addSubview:navController_.view];


	// make main window visible
	[window_ makeKeyAndVisible];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    //[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];


	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    
	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
	[director_ pushScene:[StartScene scene]];    
//	[director_ pushScene:[WorldSelectScene scene]];
//	[director_ pushScene:[LevelSelectScene sceneWithWorld:1]];
//    [director_ pushScene:[EquipMenuScene scene]];
//    [director_ pushScene:[GameScene sceneWithWorld:(int)1 andLevel:1 isRestart:TRUE restartMusic:FALSE]];

	return YES;
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
    {
		[director_ startAnimation];
    }
    [[PHPublisherOpenRequest requestForApp:(NSString *)WDPHToken secret:(NSString *)WDPHSecret] send];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

- (void) cacheSFX
{
    [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"bg-main.aifc"];
    [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"detective-music.aifc"];
    [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"bg-loop1.aifc"];
    [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"bg-loop2.aifc"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"complete.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"collect1.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"collect2.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"collect3.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"collect-small.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"player-hit.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"bat-hit.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"boom.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"jump1.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"jump2.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"jump4.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"score.caf"];
}

@end
