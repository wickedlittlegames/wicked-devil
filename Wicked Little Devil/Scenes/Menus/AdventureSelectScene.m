//
//  WorldSelectScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 11/09/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "AdventureSelectScene.h"
#import "WorldSelectScene.h"
#import "DetectiveLevelSelectScene.h"
#import "StartScene.h"
#import "ShopScene.h"
#import "StatsScene.h"
#import "EquipMenuScene.h"
#import "User.h"
#import "SimpleTableCell.h"
#import "GameOverFacebookScene.h"
#import "Game.h"

@implementation AdventureSelectScene

+(CCScene *) scene
{
	CCScene *scene              = [CCScene node];
	AdventureSelectScene *current   = [AdventureSelectScene node];
	[scene addChild:current];
	return scene;
}

-(id) init
{
	if( (self=[super init]) )
    {
        gkHelper = [GameKitHelper sharedGameKitHelper];
        gkHelper.delegate = self;
        
        app = (AppController*) [[UIApplication sharedApplication] delegate];
        
        user            = [[User alloc] init];
        screenSize      = [CCDirector sharedDirector].winSize;
        font            = @"CrashLanding BB";
        fontsize        = 36;
        worlds          = [NSMutableArray arrayWithCapacity:100];
                
        if ( ![user.udata boolForKey:@"SEEN_ADVENTURES"] )
        {
            [user.udata setBool:TRUE forKey:@"SEEN_ADVENTURES"];
            [user sync];
        }

        if ( ![SimpleAudioEngine sharedEngine].mute )
        {
            [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"detective-music.aifc" loop:YES];
        }
        
        CCMenu *menu_back               = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-back.png"    selectedImage:@"btn-back.png"       target:self selector:@selector(tap_back:)], nil];
        CCMenu *menu_equip              = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-powerup.png" selectedImage:@"btn-powerup.png"    target:self selector:@selector(tap_equip:)],nil];
        CCMenu *menu_store              = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-store-world.png" selectedImage:@"btn-store-world.png"    target:self selector:@selector(tap_store:)],nil];
        CCMenuItem *btn_achievements    = [CCMenuItemImage itemWithNormalImage:@"btn-achievements.png"    selectedImage:@"btn-achievements.png" target:self selector:@selector(tap_achievements)];
        CCMenuItem *btn_moregames    = [CCMenuItemImage itemWithNormalImage:@"btn-more-games.png"    selectedImage:@"btn-more-games.png" target:self selector:@selector(tap_moregames)];
        CCMenuItem *btn_leaderboard     = [CCMenuItemImage itemWithNormalImage:@"btn-leaderboard.png"    selectedImage:@"btn-leaderboard.png" target:self selector:@selector(tap_leaderboard)];
        btn_facebooksignin              = [CCMenuItemImage itemWithNormalImage:@"btn-fb.png"            selectedImage:@"btn-fb.png"         target:self selector:@selector(tap_facebook)];
        CCMenu *menu_social             = [CCMenu menuWithItems:btn_moregames,btn_leaderboard, btn_achievements, btn_facebooksignin, nil];
        [menu_social alignItemsHorizontallyWithPadding:5];
        
        
        CCSprite *behind_fb             = [CCSprite spriteWithFile:@"btn-behind-fb.png"];
        [behind_fb setPosition:ccp(screenSize.width - 23, 25)];
        
        // Positioning
        [menu_back              setPosition:ccp(25, 25)];
        [menu_social setPosition:ccp(screenSize.width - 118, 25)];
        [menu_equip             setPosition:ccp(25, screenSize.height - 25)];
        [menu_store             setPosition:ccp(70, screenSize.height - 25)];
        
        // Add world layers to the scroller
        [self addChild:[self detectivedevil]];
        [self addChild:menu_equip];
        [self addChild:menu_back];
        [self addChild:behind_fb];
        [self addChild:menu_social];

        CCSprite *icon_collectable      = [CCSprite spriteWithFile:@"ui-collectable.png"];
        label_collected     = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", user.collected] dimensions:CGSizeMake(screenSize.width - 80, 30) hAlignment:kCCTextAlignmentRight fontName:font fontSize:32];
        [label_collected     setPosition:ccp(screenSize.width/2, screenSize.height - 22)];
        [icon_collectable        setPosition:ccp(screenSize.width - 20, screenSize.height - 20)];
        [self addChild:icon_collectable];
        [self addChild:label_collected];
        
        [self addChild:menu_store];
        
        [self setFacebookImage];
        
        notificationView = [[PHNotificationView alloc] initWithApp:WDPHToken secret:WDPHSecret placement:@"more_games"];
        [[app navController].view addSubview:notificationView];
        notificationView.center = CGPointMake(screenSize.width/2-70,screenSize.height-35);
        [notificationView refresh];
        
        
        CCMenu *menu_stats              = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-stats.png" selectedImage:@"btn-stats.png"    target:self selector:@selector(tap_stats:)],nil];
        [menu_stats             setPosition:ccp(115, screenSize.height - 25)];
        [self addChild:menu_stats];

    }
	return self;
}

#pragma mark FACEBOOK STUFF

- (void) tap_facebook
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        Game *tmpgame = [[Game alloc] init];
        tmpgame.user = user;
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.2f scene:[GameOverFacebookScene sceneWithGame:tmpgame fromScene:2]]];
    }
    else
    {
        NSArray *permissions        = [NSArray arrayWithObjects:@"publish_actions",@"user_games_activity", nil];
        
        [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *pfuser, NSError *error) {
            if (!pfuser)
            {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else if (pfuser.isNew) {
                user.collected += 500;
                [user sync];
                [self getFacebookImage];
            }
            else
            {
                NSLog(@"User logged in through Facebook!");
                [self getFacebookImage];
            }
        }];
    }
}

- (void) setFacebookImage
{
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        if ( user.facebook_image == NULL ) [self getFacebookImage];
        else
        {
            CCSprite *fbimage = [CCSprite spriteWithCGImage:[UIImage imageWithData:user.facebook_image].CGImage key:@"facebook_image"];
            CCSprite *fbimage2 = [CCSprite spriteWithCGImage:[UIImage imageWithData:user.facebook_image].CGImage key:@"facebook_image"];
            [btn_facebooksignin setNormalImage:fbimage];
            [btn_facebooksignin setSelectedImage:fbimage2];
        }
    }
}

- (void) getFacebookImage
{
    [FBRequestConnection startWithGraphPath:@"me/?fields=name,location,gender,picture" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
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
    }];
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

#pragma mark TAPS

- (void) tap_stats:(id)sender
{
    [notificationView clear];
    
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:0.2f scene:[StatsScene scene]]];
}

- (void) tap_moregames
{
    [notificationView clear];
    
    PHPublisherContentRequest *request = [PHPublisherContentRequest requestForApp:(NSString *)WDPHToken secret:(NSString *)WDPHSecret placement:(NSString *)@"more_games" delegate:(id)self];
    request.showsOverlayImmediately = YES; //optional, see next.
    [request send];
}



- (void) tap_world:(CCMenuItemFont*)sender
{
    [notificationView clear];
    
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
        [[CCDirector sharedDirector] replaceScene:[CCTransitionRotoZoom transitionWithDuration:1.5f scene:[DetectiveLevelSelectScene sceneWithWorld:20]]];
}

- (void) tap_equip:(id)sender
{
    [notificationView clear];
    
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:0.2f scene:[EquipMenuScene scene]]];
}

- (void) tap_store:(id)sender
{
    [notificationView clear];
    
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:0.2f scene:[ShopScene scene]]];
}

- (void) tap_back:(CCMenuItem*)sender
{
    [notificationView clear];
    
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.2f scene:[StartScene scene]]];
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
    
//    [self reportAchievements];
    
    GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
    achivementViewController.achievementDelegate = self;
    [[app navController] presentModalViewController:achivementViewController animated:YES];
}

#pragma mark WORLDS

- (CCLayer*) detectivedevil
{
    CCLayer *layer          = [CCLayer node];
    CCSprite *bg            = [CCSprite spriteWithFile: @"adventure-2.png"];
    CCSprite *bgfx          = [CCSprite spriteWithFile:@"ui-spinner-fx.png"];
    button = [CCMenuItemImage itemWithNormalImage:@"btn-start.png" selectedImage:@"btn-start.png" disabledImage:@"btn-start.png" target:self selector:@selector(tap_world:)];
    CCMenu *menu            = [CCMenu menuWithItems:button, nil]; button.tag = 1; button.opacity = 0; button.scale *= 3; button.isEnabled = user.unlocked_detective;
    
    [bg   setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    [bgfx   setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    [menu setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    
    [layer addChild:bg];
    [layer addChild:bgfx];
    [layer addChild:menu];
    
    [bgfx runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:120.0 angle:360.f]]];
    
    if ( !user.unlocked_detective )
    {
        locked_sprite = [CCSprite spriteWithFile:@"bg-locked2.png"];
        locked_sprite.position = ccp(screenSize.width/2,screenSize.height/2);
        [layer addChild:locked_sprite];
        
        CCMenuItemImage *unlock_button = [CCMenuItemImage itemWithNormalImage:@"btn-unlockdevil.png" selectedImage:@"btn-unlockdevil.png" disabledImage:@"btn-unlockdevil.png" target:self selector:@selector(tap_unlock_detective)];
        unlock_menu            = [CCMenu menuWithItems:unlock_button, nil];
        
        [unlock_menu setPosition:ccp(screenSize.width/2,screenSize.height/2)];
        [layer addChild:unlock_menu];
    }   
    
    return layer;
}

- (void) tap_unlock_detective
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    if ( user.collected >= DETECTIVE_UNLOCK_COST )
    {
        [FlurryAnalytics logEvent:@"PLAYER UNLOCKED DETECTIVE"];
        unlock_menu.visible = FALSE;
        tmp_collectables = user.collected;
        user.collected -= DETECTIVE_UNLOCK_COST;
        user.unlocked_detective = TRUE;
        [user sync];
        tmp_collectable_increment = DETECTIVE_UNLOCK_COST;
        [self schedule: @selector(collectable_remove_tick) interval: 1.0f/60.0f];
    }
    else
    {
        [FlurryAnalytics logEvent:@"PLAYER TRIED TO UNLOCK DETECTIVE - NOT ENOUGH SOULS"];
        
        BlockAlertView* alert = [BlockAlertView alertWithTitle:@"Not Enough Souls!" message:@"You don't have enough souls! Would you like to buy some?"];
        [alert addButtonWithTitle:@"Buy Souls" block:^{
            [notificationView clear];
            [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:1.0f scene:[ShopScene scene]]];
        }];
        [alert setCancelButtonWithTitle:@"Cancel" block:^{}];
        [alert show];
    }
}

- (void) collectable_remove_tick
{
    if ( tmp_collectable_increment > 0 )
    {
        if (tmp_collectable_increment > 500)
		{
            tmp_collectable_increment -= 500;
            tmp_collectables -= 500;
            [label_collected setString:[NSString stringWithFormat:@"%i",tmp_collectables]];
        }
        
        if (tmp_collectable_increment > 100)
		{
            tmp_collectable_increment -= 100;
            tmp_collectables -= 100;
            [label_collected setString:[NSString stringWithFormat:@"%i",tmp_collectables]];
        }
        if (tmp_collectable_increment > 10)
		{
            tmp_collectable_increment -= 10;
            tmp_collectables -= 10;
            [label_collected setString:[NSString stringWithFormat:@"%i",tmp_collectables]];
        }
        else
		{
            tmp_collectable_increment --;
            tmp_collectables --;
            [label_collected setString:[NSString stringWithFormat:@"%i",tmp_collectables]];
        }
    }
    else
    {
        CCParticleSystemQuad *fx1 = [CCParticleSystemQuad particleWithFile:@"spendSouls.plist"];
        [self addChild:fx1];
        locked_sprite.visible = FALSE;
        button.isEnabled = TRUE;
        [self unschedule: @selector(collectable_remove_tick)];
    }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        
    }
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
    for (int i = 1; i <= CURRENT_WORLDS_PER_GAME; i++)
    {
        int tmp_highscore_for_world = [user getHighscoreforWorld:i];
        if (tmp_highscore_for_world > 0)
        {
            [gkHelper submitScore:tmp_highscore_for_world category:[NSString stringWithFormat:@"WLD_%i",i]];
        }
    }
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