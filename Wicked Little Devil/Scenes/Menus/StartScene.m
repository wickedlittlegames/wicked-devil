//
//  StartScreen.m
//  Wicked Little Devil
//
//  This SCENE is the Angry Birds-style "Start" button that takes you to the world selector
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "AppDelegate.h"
#import "StartScene.h"
#import "WorldSelectScene.h"
#import "Social/Social.h"
#import "User.h"

@implementation StartScene

+(CCScene *) scene
{
	CCScene *scene          = [CCScene node];
	StartScene *current     = [StartScene node];
	[scene addChild:current];
	return scene;
}

-(id) init
{
	if( (self=[super init]) ) 
    {
		CGSize screenSize = [[CCDirector sharedDirector] winSize];      
        user = [[User alloc] init];
        [user reset];
        
        CCSprite *bg                    = [CCSprite spriteWithFile:@"bg-home.png"];
        CCMenuItem *btn_start           = [CCMenuItemImage itemWithNormalImage:@"btn-start.png"         selectedImage:@"btn-start.png"      target:self selector:@selector(tap_start)];
        CCMenuItem *btn_leaderboard     = [CCMenuItemImage itemWithNormalImage:@"btn-gamecenter.png"    selectedImage:@"btn-gamecenter.png" target:self selector:@selector(tap_leaderboard)];
        CCMenuItem *btn_facebooksignin  = [CCMenuItemImage itemWithNormalImage:@"btn-fb.png"            selectedImage:@"btn-fb.png"         target:self selector:@selector(tap_facebook)];
        btn_mute                        = [CCMenuItemImage itemWithNormalImage:@"btn-muted.png"          selectedImage:@"btn-muted.png"       target:self selector:@selector(tap_mute)];
        btn_muted                       = [CCMenuItemImage itemWithNormalImage:@"btn-mute.png"         selectedImage:@"btn-mute.png"      target:self selector:@selector(tap_mute)];
        CCMenu *menu_start              = [CCMenu menuWithItems:btn_start, nil];
        CCMenu *menu_social             = [CCMenu menuWithItems:btn_leaderboard, btn_facebooksignin, nil];
        CCMenu *menu_mute               = [CCMenu menuWithItems:btn_mute, btn_muted, nil];
        
        [bg setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        [menu_start setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        [menu_mute setPosition:ccp(25, 25)];
        [menu_social setPosition:ccp(screenSize.width - 60, 25)];
        [menu_social alignItemsHorizontallyWithPadding:10];
        
        [self addChild:bg];
        [self addChild:menu_start];
        [self addChild:menu_social];
        [self addChild:menu_mute];
        
        [self setMute];
    }
	return self;    
}

- (void) setMute
{
    [SimpleAudioEngine sharedEngine].mute = [user.udata boolForKey:@"MUTED"];
    if ( [SimpleAudioEngine sharedEngine].mute )   btn_muted.visible    = YES;
    else                                           btn_mute.visible     = YES;
}

#pragma mark TAPS

- (void) tap_start
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[WorldSelectScene scene]]];
}

- (void) tap_leaderboard
{
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    leaderboardViewController.leaderboardDelegate = self;
    
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    
    [[app navController] presentModalViewController:leaderboardViewController animated:YES];
}

- (void) tap_achievements
{
    GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
    achivementViewController.achievementDelegate = self;
    
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    
    [[app navController] presentModalViewController:achivementViewController animated:YES];
}

- (void) tap_mute
{
    bool current_mute_status = [user.udata boolForKey:@"MUTED"];
    
    if ( current_mute_status == 0 )
    {
        btn_mute.visible = NO;
        btn_muted.visible = YES;
        [SimpleAudioEngine sharedEngine].mute = YES;
        [user.udata setBool:TRUE forKey:@"MUTED"];
    }
    else
    {
        btn_mute.visible = YES;
        btn_muted.visible = NO;
        [SimpleAudioEngine sharedEngine].mute = NO;
        [user.udata setBool:FALSE forKey:@"MUTED"];
    }
    
    [user.udata synchronize];
}

- (void) tap_facebook
{
    // STUFF WITH THINGS
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

@end
