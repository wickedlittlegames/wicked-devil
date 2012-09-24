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

@implementation StartScene

+(CCScene *) scene
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    // Grab the layers
	StartScene *current = [StartScene node];
    
    // Fill the scene
	[scene addChild:current];
    
    // Show the scene
	return scene;
}

-(id) init
{
	if( (self=[super init]) ) 
    {
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
        user = [[User alloc] init];
        
        CCSprite *bg = [CCSprite spriteWithFile:@"bg-home.png"];
        [bg setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        [self addChild:bg];

        CCMenu *menu_start = [CCMenu menuWithItems:nil];
        CCMenu *menu_others = [CCMenu menuWithItems:nil];
        
        CCMenuItem *btn_start = [CCMenuItemImage 
                                 itemWithNormalImage:@"btn-start.png"
                                 selectedImage:@"btn-start.png"
                                 disabledImage:@"btn-start.png"
                                 target:self 
                                 selector:@selector(tap_start)];
        [menu_start addChild:btn_start];
        [menu_start setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        [self addChild:menu_start];
        
        
        // ACHIEVEMENTS BUTTON
        CCMenuItem *btn_achievements = [CCMenuItemImage itemWithNormalImage:@"btn-gamecenter.png" selectedImage:@"btn-gamecenter.png" block:^(id sender) {
			
            // upload achievements - TODO
            
			GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
			achivementViewController.achievementDelegate = self;
			
			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
			
			[[app navController] presentModalViewController:achivementViewController animated:YES];
			
		}];
        
        // LEADERBOARD BUTTON
        CCMenuItem *btn_leaderboard = [CCMenuItemImage itemWithNormalImage:@"btn-gamecenter.png" selectedImage:@"btn-gamecenter.png" block:^(id sender) {
			
            // upload leaderboard - TODO
            GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
			leaderboardViewController.leaderboardDelegate = self;
			
			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
			
			[[app navController] presentModalViewController:leaderboardViewController animated:YES];
			
		}];

        // FACEBOOK BUTTON
        CCMenuItem *btn_facebooksignin = [CCMenuItemImage
                                      itemWithNormalImage:@"btn-fb.png"
                                      selectedImage:@"btn-fb.png"
                                      disabledImage:@"btn-fb.png"
                                      target:self
                                      selector:@selector(tap_facebook)];
        [menu_others addChild:btn_achievements];
        [menu_others addChild:btn_leaderboard];
        [menu_others addChild:btn_facebooksignin];
        [menu_others alignItemsHorizontallyWithPadding:5];
        [menu_others setPosition:ccp(screenSize.width - 60, 25)];
        [self addChild:menu_others];
        
        // MUTE
        CCMenu *menu_mute = [CCMenu menuWithItems:nil];
        btn_mute = [CCMenuItemImage
                                          itemWithNormalImage:@"btn-mute.png"
                                          selectedImage:@"btn-mute.png"
                                          disabledImage:@"btn-mute.png"
                                          target:self
                                          selector:@selector(tap_mute)];
        btn_muted = [CCMenuItemImage
                    itemWithNormalImage:@"btn-muted.png"
                    selectedImage:@"btn-muted.png"
                    disabledImage:@"btn-muted.png"
                    target:self
                    selector:@selector(tap_mute)];
        [menu_mute addChild:btn_mute];
        [menu_mute addChild:btn_muted];
        [menu_mute setPosition:ccp(25, 25)];
        
        if ( ![SimpleAudioEngine sharedEngine].isBackgroundMusicPlaying )
        {
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bg-main.wav" loop:YES];
        }
        [SimpleAudioEngine sharedEngine].mute = [user.udata boolForKey:@"MUTED"];
        if ( [SimpleAudioEngine sharedEngine].mute )
        {
            btn_muted.visible = YES;
        }
        else
        {
            btn_mute.visible = YES;
        }
        [self addChild:menu_mute];
    }
	return self;    
}

- (void) tap_start
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[WorldSelectScene scene]]];
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
    SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            
            [fbController dismissViewControllerAnimated:YES completion:nil];
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    NSLog(@"Cancelled.....");
                    
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    NSLog(@"Posted....");
                }
                    break;
            }};
        
//        [fbController addImage:[UIImage imageNamed:@"1.jpg"]];
        [fbController setInitialText:@"Check out this article."];
        [fbController addURL:[NSURL URLWithString:@"http://soulwithmobiletechnology.blogspot.com/"]];
        [fbController setCompletionHandler:completionHandler];
        AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
        
        [[app navController] presentViewController:fbController animated:YES completion:nil];
    }
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
