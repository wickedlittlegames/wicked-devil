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
#import "GameOverFacebookScene.h"
#import "GameScene.h"
#import "MBProgressHUD.h"
#import "Game.h"
#import "User.h"

#import "FlurryAnalytics.h"

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
        gkHelper = [GameKitHelper sharedGameKitHelper];
        gkHelper.delegate = self;
        [gkHelper authenticateLocalPlayer];
        
        [self reportLeaderboardHighscores];
        
        app = (AppController*) [[UIApplication sharedApplication] delegate];
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        user = [[User alloc] init];
        
        if ( ![user.udata boolForKey:@"MUTED"] && ![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying])
        {
            [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bg-main.aifc" loop:YES];
        }       
        
        CCSprite *bg                    = [CCSprite spriteWithFile:(IS_IPHONE5 ? @"bg-home-iphone5.png" : @"bg-home.png")];
        CCMenuItem *btn_start           = [CCMenuItemImage itemWithNormalImage:@"btn-start.png"         selectedImage:@"btn-start.png"      target:self selector:@selector(tap_start)];
        CCMenuItem *btn_achievements    = [CCMenuItemImage itemWithNormalImage:@"btn-achievements.png"    selectedImage:@"btn-achievements.png" target:self selector:@selector(tap_achievements)];
        CCMenuItem *btn_leaderboard     = [CCMenuItemImage itemWithNormalImage:@"btn-leaderboard.png"    selectedImage:@"btn-leaderboard.png" target:self selector:@selector(tap_leaderboard)];
        prompt_facebook                 = [CCSprite spriteWithFile:@"ui-prompt-facebook.png"];
        btn_facebooksignin              = [CCMenuItemImage itemWithNormalImage:@"btn-fb.png"            selectedImage:@"btn-fb.png"         target:self selector:@selector(tap_facebook)];
        btn_mute                        = [CCMenuItemImage itemWithNormalImage:@"btn-muted.png"          selectedImage:@"btn-muted.png"       target:self selector:@selector(tap_mute)];
        btn_muted                       = [CCMenuItemImage itemWithNormalImage:@"btn-mute.png"         selectedImage:@"btn-mute.png"      target:self selector:@selector(tap_mute)];
        CCMenu *menu_start              = [CCMenu menuWithItems:btn_start, nil];
        CCMenu *menu_social             = [CCMenu menuWithItems:btn_leaderboard, btn_achievements, btn_facebooksignin, nil];
        CCMenu *menu_mute               = [CCMenu menuWithItems:btn_mute, btn_muted, nil];
        CCParticleSystemQuad *homeFX    = [CCParticleSystemQuad particleWithFile:@"StartScreenFX.plist"];
        CCSprite *behind_fb             = [CCSprite spriteWithFile:@"btn-behind-fb.png"];
        
        [bg setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        [homeFX setPosition:ccp(screenSize.width/2, 0)];
        [menu_start setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        [menu_mute setPosition:ccp(25, 25)];
        [menu_social setPosition:ccp(screenSize.width - 63, 25)];
        [menu_social alignItemsHorizontallyWithPadding:5];
        [behind_fb setPosition:ccp(screenSize.width - 23, 25)];
        [prompt_facebook setPosition:ccp(screenSize.width - 90, 80)];
        
        [self addChild:bg];
        [self addChild:homeFX];
        [self addChild:menu_start];
        [self addChild:behind_fb];
        [self addChild:menu_social];
        [self addChild:menu_mute];
        [self addChild:prompt_facebook];
        
        [self setMute];
        [self setFacebookImage];
        
        CCSprite *bg_secret = [CCSprite spriteWithFile:@"bg-pulldown.png"];
        [bg_secret setPosition:ccp(0, screenSize.height)];
        [bg_secret setAnchorPoint:ccp(0,0)];
        
        CCMenuItemImage *btn_secret = [CCMenuItemImage itemWithNormalImage:@"btn-secret-like.png" selectedImage:@"btn-secret-like.png" block:^(id sender){
            
            CCMenuItemImage *tmp_btn_secret = (CCMenuItemImage*)sender;
            
            // first check udata
            if ( [user.udata boolForKey:@"FACEBOOK_LIKED"] )
            {
                // PLAY THE LEVEL
                if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
                [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameScene sceneWithWorld:11 andLevel:1 isRestart:NO restartMusic:YES]]];
            }
            else
            {
                [user.udata setBool:TRUE forKey:@"FACEBOOK_LIKED"];
                [user.udata synchronize];
                
                [tmp_btn_secret setNormalImage:[CCSprite spriteWithFile:@"btn-secret-play.png"]];
                [tmp_btn_secret setSelectedImage:[CCSprite spriteWithFile:@"btn-secret-play.png"]];
                
                NSURL *fanPageURL = [NSURL URLWithString:@"fb://profile/128944673829884"];
                if (![[UIApplication sharedApplication] openURL: fanPageURL])
                {
                    NSURL *webURL = [NSURL URLWithString:@"http://www.facebook.com/wickedlittlegames"];
                    [[UIApplication sharedApplication] openURL: webURL];
                }
            }
        }];
        
        if ( [user.udata boolForKey:@"FACEBOOK_LIKED"] )
        {
            [btn_secret setNormalImage:[CCSprite spriteWithFile:@"btn-secret-play.png"]];
            [btn_secret setSelectedImage:[CCSprite spriteWithFile:@"btn-secret-play.png"]];
            
            int souls = [user getSoulsforWorld:11 level:1];
            
            int soul_x = 13;
            for (int s = 1; s <= souls; s++ )
            {
                CCSprite *soul = [CCSprite spriteWithFile:@"icon-level-bigcollectable.png"];
                
                soul.position = ccp(btn_secret.position.x + soul_x, btn_secret.position.y - 2);
                [btn_secret addChild:soul];
                soul_x += 27;
            }
        }
        
        CCMenu *menu_secret_level = [CCMenu menuWithItems:btn_secret, nil];
        [menu_secret_level setAnchorPoint:ccp(0,0)];
        [menu_secret_level setPosition:ccp(bg_secret.contentSize.width - btn_secret.contentSize.width + 30,bg_secret.contentSize.height/2)];
        [bg_secret addChild:menu_secret_level];
        
        CCMenuItemImage *button_menu_secret = [CCMenuItemImage itemWithNormalImage:@"ui-btn-home-flag.png" selectedImage:@"ui-btn-home-flag.png" block:^(id sender) {
            [bg_secret stopAllActions];
            
            CCMenuItemImage *tmp_btn = (CCMenuItemImage*)sender;
            if ( secret_visible )
            {
                [bg_secret runAction:[CCMoveTo actionWithDuration:0.2f position:ccp(bg_secret.position.x,bg_secret.position.y + bg_secret.contentSize.height)]];
                [tmp_btn runAction:[CCMoveTo actionWithDuration:0.2f position:ccp(tmp_btn.position.x, tmp_btn.position.y + 70)]];
            }
            else
            {
                [bg_secret runAction:[CCMoveTo actionWithDuration:0.2f position:ccp(bg_secret.position.x,screenSize.height - bg_secret.contentSize.height)]];
                [tmp_btn runAction:[CCMoveTo actionWithDuration:0.2f position:ccp(tmp_btn.position.x, tmp_btn.position.y - 70)]];
            }
            secret_visible = !secret_visible;
        }];
        
        // TODO: CLICKABLE (SHOWABLE) PANEL WITH FACEBOOK LIKE BUTTON THAT THEN PLAYS A FUN LEVEL
        CCMenu *menu_secret = [CCMenu menuWithItems:button_menu_secret, nil];
        [menu_secret setPosition:ccp(screenSize.width - 30, screenSize.height - 21)];

        [self addChild:menu_secret];
        [self addChild:bg_secret];
    }
	return self;
}


- (void) setMute
{
    [SimpleAudioEngine sharedEngine].mute          = [user.udata boolForKey:@"MUTED"];
    if ( [SimpleAudioEngine sharedEngine].mute )   { btn_muted.visible    = YES; btn_mute.visible = NO; }
    else                                           { btn_mute.visible     = YES; btn_muted.visible = NO; }
}

- (void) setFacebookImage
{
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        if ( user.facebook_image == NULL ) [self getFacebookImage];
        else
        {
            if ( user.facebook_id == NULL )
            {
                PF_FBRequest *request = [PF_FBRequest requestForMe];
                [request startWithCompletionHandler:^(PF_FBRequestConnection *connection,
                                                      id result,
                                                      NSError *error) {
                    if (!error) {
                        user.facebook_id = [result objectForKey:@"id"];
                        [user sync_facebook];
                    }
                }];
            }
            prompt_facebook.visible = FALSE;
            CCSprite *fbimage = [CCSprite spriteWithCGImage:[UIImage imageWithData:user.facebook_image].CGImage key:@"facebook_image"];
            CCSprite *fbimage2 = [CCSprite spriteWithCGImage:[UIImage imageWithData:user.facebook_image].CGImage key:@"facebook_image"];
            [btn_facebooksignin setNormalImage:fbimage];
            [btn_facebooksignin setSelectedImage:fbimage2];
        }
    }
}

- (void) getFacebookImage
{
    [[PFFacebookUtils facebook] requestWithGraphPath:@"me/?fields=name,location,gender,picture" andDelegate:self];
}

#pragma mark TAPS

- (void) tap_start
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[WorldSelectScene scene]]];
}

- (void) tap_leaderboard
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}

    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    leaderboardViewController.leaderboardDelegate = self;
    [[app navController] presentModalViewController:leaderboardViewController animated:YES];
}

- (void) tap_achievements
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [self reportAchievements];
    
    GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
    achivementViewController.achievementDelegate = self;
    [[app navController] presentModalViewController:achivementViewController animated:YES];
}

- (void) tap_mute
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
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
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        Game *tmpgame = [[Game alloc] init];
        tmpgame.user = user;

        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[GameOverFacebookScene sceneWithGame:tmpgame fromScene:1]]];
    }
    else
    {
        [FlurryAnalytics logEvent:[NSString stringWithFormat:@"Player tried to sign up with Parse.com/Facebook"]];
        
        [MBProgressHUD showHUDAddedTo:[app navController].view animated:YES];
        NSArray *permissionsArray        = [NSArray arrayWithObjects:@"publish_actions",@"offline_access", nil];
        [PFFacebookUtils logInWithPermissions:permissionsArray
            block:^(PFUser *pfuser, NSError *error) {
                if (!pfuser) {
                    if (!error)
                    {
                        [FlurryAnalytics logEvent:[NSString stringWithFormat:@"Player cancelled the facebook signup process"]];
                    }
                    else
                    {
                        NSLog(@"Uh oh. An error occurred: %@", error);
                    }
                }
                else if (pfuser.isNew)
                {
                    [FlurryAnalytics logEvent:[NSString stringWithFormat:@"Player signed up, fresh!"]];
                    [self getFacebookImage];
                    user.collected += 500;
                    prompt_facebook.visible = FALSE;
                    [user sync];
                    
                    PF_FBRequest *request = [PF_FBRequest requestForMe];
                    [request startWithCompletionHandler:^(PF_FBRequestConnection *connection,
                                                          id result,
                                                          NSError *error) {
                        if (!error) {
                            // Store the current user's Facebook ID on the user
                            user.facebook_id = [result objectForKey:@"id"];
                            [user sync_facebook];
                        }
                    }];
                    
                    [MBProgressHUD hideHUDForView:[app navController].view animated:YES];
                }
                else
                {
                    [FlurryAnalytics logEvent:[NSString stringWithFormat:@"Player signed back in!"]];
                    
                    prompt_facebook.visible = FALSE;
                    [self getFacebookImage];
                    [MBProgressHUD hideHUDForView:[app navController].view animated:YES];
                }
            }
        ];
    }
}

#pragma mark Facebook Parse Stuff

- (void)request:(PF_FBRequest *)request didLoad:(id)result
{
    NSDictionary *userData = (NSDictionary *)result;
    imageData = [[NSMutableData alloc] init];
    
    if ( user.facebook_id == NULL )
    {
        user.facebook_id = [NSString stringWithFormat:@"%@",[userData objectForKey:@"id"]];
        [user sync_facebook];
    }

    NSString *pictureURL = [[[userData objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:pictureURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2];
    
    urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [imageData appendData:data];
    user.facebook_image = imageData;
    [user sync_facebook];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    CCSprite *fbimage = [CCSprite spriteWithCGImage:[UIImage imageWithData:user.facebook_image].CGImage key:@"facebook_image"];
    [btn_facebooksignin setNormalImage:fbimage];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	[[app navController] dismissModalViewControllerAnimated:YES];
}
-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[[app navController] dismissModalViewControllerAnimated:YES];
}
- (void) reportLeaderboardHighscores
{
    int totalhighscore = 0;
    for (int i = 1; i <= CURRENT_WORLDS_PER_GAME; i++)
    {
        int tmp_highscore_for_world = [user getHighscoreforWorld:i];
        totalhighscore += tmp_highscore_for_world;
        if (tmp_highscore_for_world > 0)
        {
            [gkHelper submitScore:tmp_highscore_for_world category:[NSString stringWithFormat:@"WLD_%i",i]];
        }
    }
    [gkHelper submitScore:totalhighscore category:@"WLD_GLOBAL"];
}
- (void) reportAchievements
{
    [gkHelper reportCachedAchievements];
    
    if ( user.ach_first_play && !user.sent_ach_first_play )
    {
        [gkHelper reportAchievementWithID:[NSString stringWithFormat:@"%i",ACV_FIRST_PLAY] percentComplete:100.0f];
        user.sent_ach_first_play = YES;
    }
    if ( user.ach_collected_666 && !user.sent_ach_collected_666 )
    {
        [gkHelper reportAchievementWithID:[NSString stringWithFormat:@"%i",ACV_COLLECTED_666_SOULS] percentComplete:100.0f];
        user.sent_ach_collected_666 = YES;
    }
    if ( user.ach_1000_souls && !user.sent_ach_1000_souls )
    {
        [gkHelper reportAchievementWithID:[NSString stringWithFormat:@"%i",ACV_THOUSAND_SOULS] percentComplete:100.0f];
        user.sent_ach_1000_souls = YES;
    }
    if ( user.ach_5000_souls && !user.sent_ach_5000_souls )
    {
        [gkHelper reportAchievementWithID:[NSString stringWithFormat:@"%i",ACV_5THOUSAND_SOULS] percentComplete:100.0f];
        user.sent_ach_5000_souls = YES;
    }
    if ( user.ach_10000_souls && !user.sent_ach_10000_souls )
    {
        [gkHelper reportAchievementWithID:[NSString stringWithFormat:@"%i",ACV_10THOUSAND_SOULS] percentComplete:100.0f];
        user.sent_ach_10000_souls = YES;
    }
    if ( user.ach_50000_souls && !user.sent_ach_50000_souls )
    {
        [gkHelper reportAchievementWithID:[NSString stringWithFormat:@"%i",ACV_50THOUSAND_SOULS] percentComplete:100.0f];
        user.sent_ach_50000_souls = YES;
    }
    if ( user.ach_beat_world_1 && !user.sent_ach_beat_world_1 )
    {
        [gkHelper reportAchievementWithID:[NSString stringWithFormat:@"%i",ACV_BEAT_WORLD_1] percentComplete:100.0f];
        user.sent_ach_beat_world_1 = YES;
    }
    if ( user.ach_beat_world_2 && !user.sent_ach_beat_world_2 )
    {
        [gkHelper reportAchievementWithID:[NSString stringWithFormat:@"%i",ACV_BEAT_WORLD_2] percentComplete:100.0f];
        user.sent_ach_beat_world_2 = YES;
    }
    if ( user.ach_beat_world_3 && !user.sent_ach_beat_world_3 )
    {
        [gkHelper reportAchievementWithID:[NSString stringWithFormat:@"%i",ACV_BEAT_WORLD_3] percentComplete:100.0f];
        user.sent_ach_beat_world_3 = YES;
    }
//    if ( user.ach_beat_world_4 && !user.sent_ach_beat_world_4 )
//    {
//        [gkHelper reportAchievementWithID:[NSString stringWithFormat:@"%i",ACV_BEAT_WORLD_4] percentComplete:100.0f];
//        user.sent_ach_beat_world_4 = YES;
//    }
    if ( user.ach_killed && !user.sent_ach_killed )
    {
        [gkHelper reportAchievementWithID:[NSString stringWithFormat:@"%i",ACV_KILLED_BY_DEATH] percentComplete:100.0f];
        user.sent_ach_killed = YES;
    }
    if ( user.ach_died_100 && !user.sent_ach_died_100 )
    {
        [gkHelper reportAchievementWithID:[NSString stringWithFormat:@"%i",ACV_DIED_100_TIMES] percentComplete:100.0f];
        user.sent_ach_died_100 = YES;
    }
    if ( user.ach_jumped_1000 && !user.sent_ach_jumped_1000 )
    {
        [gkHelper reportAchievementWithID:[NSString stringWithFormat:@"%i",ACV_1000JUMPSONPLATFORM] percentComplete:100.0f];
        user.sent_ach_jumped_1000 = YES;
    }
    [user sync];
    [user sync_achievements];
}
-(void) onLocalPlayerAuthenticationChanged
{
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    CCLOG(@"LocalPlayer isAuthenticated changed to: %@", localPlayer.authenticated ? @"YES" : @"NO");
    
    if (localPlayer.authenticated)
    {
        [gkHelper getLocalPlayerFriends];
    }
}
-(void) onFriendListReceived:(NSArray*)friends
{
    CCLOG(@"onFriendListReceived: %@", [friends description]);
    [gkHelper getPlayerInfo:friends];
}
-(void) onPlayerInfoReceived:(NSArray*)players
{
    CCLOG(@"onPlayerInfoReceived: %@", [players description]);
}
-(void) onScoresSubmitted:(bool)success
{
    CCLOG(@"onScoresSubmitted: %@", success ? @"YES" : @"NO");
}
-(void) onScoresReceived:(NSArray*)scores
{
    CCLOG(@"onScoresReceived: %@", [scores description]);
    [gkHelper showAchievements];
}
-(void) onAchievementReported:(GKAchievement*)achievement
{
    CCLOG(@"onAchievementReported: %@", achievement);
}
-(void) onAchievementsLoaded:(NSDictionary*)achievements
{
    CCLOG(@"onLocalPlayerAchievementsLoaded: %@", [achievements description]);
}
-(void) onResetAchievements:(bool)success
{
    CCLOG(@"onResetAchievements: %@", success ? @"YES" : @"NO");
}
-(void) onLeaderboardViewDismissed
{
    CCLOG(@"onLeaderboardViewDismissed");
    [gkHelper retrieveTopTenAllTimeGlobalScores];
}
-(void) onAchievementsViewDismissed
{
    CCLOG(@"onAchievementsViewDismissed");
}
-(void) onReceivedMatchmakingActivity:(NSInteger)activity
{
    CCLOG(@"receivedMatchmakingActivity: %i", activity);
}
-(void) onMatchFound:(GKMatch*)match
{
    CCLOG(@"onMatchFound: %@", match);
}
-(void) onPlayersAddedToMatch:(bool)success
{
    CCLOG(@"onPlayersAddedToMatch: %@", success ? @"YES" : @"NO");
}
-(void) onMatchmakingViewDismissed
{
    CCLOG(@"onMatchmakingViewDismissed");
}
-(void) onMatchmakingViewError
{
    CCLOG(@"onMatchmakingViewError");
}
-(void) onPlayerConnected:(NSString*)playerID
{
    CCLOG(@"onPlayerConnected: %@", playerID);
}
-(void) onPlayerDisconnected:(NSString*)playerID
{
    CCLOG(@"onPlayerDisconnected: %@", playerID);
}
-(void) onStartMatch
{
    CCLOG(@"onStartMatch");
}
-(void) onReceivedData:(NSData*)data fromPlayer:(NSString*)playerID
{
    CCLOG(@"onReceivedData: %@ fromPlayer: %@", data, playerID);
}
@end
