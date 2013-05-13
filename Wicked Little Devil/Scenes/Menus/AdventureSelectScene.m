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

        if ( ![user.udata boolForKey:@"MUTED"] && ![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying])
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

    }
	return self;
}

#pragma mark FACEBOOK SETS

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
    // This goes off and calls the request delegate method
    [[PFFacebookUtils facebook] requestWithGraphPath:@"me/?fields=name,location,gender,picture" andDelegate:self];
}

#pragma mark TAPS


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
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[DetectiveLevelSelectScene sceneWithWorld:20]]];
}

- (void) tap_escapefromhell:(CCMenuItemFont*)sender
{
    [notificationView clear];
    
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[WorldSelectScene scene]]];
}


- (void) tap_equip:(id)sender
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[EquipMenuScene scene]]];
}

- (void) tap_store:(id)sender
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[ShopScene scene]]];
}

- (void) tap_back:(CCMenuItem*)sender
{
    [notificationView clear];
    
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[StartScene scene]]];
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

- (void) tap_facebook
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        Game *tmpgame = [[Game alloc] init];
        tmpgame.user = user;
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[GameOverFacebookScene sceneWithGame:tmpgame fromScene:2]]];
    }
    else
    {
        //[MBProgressHUD showHUDAddedTo:[app navController].view animated:YES];
        NSArray *permissionsArray        = [NSArray arrayWithObjects:@"publish_actions",@"offline_access", nil];
        [PFFacebookUtils logInWithPermissions:permissionsArray
                                        block:^(PFUser *pfuser, NSError *error) {
                                            if (!pfuser) {
                                                if (!error)
                                                {
                                                }
                                                else
                                                {
                                                    NSLog(@"Uh oh. An error occurred: %@", error);
                                                }
                                            }
                                            else if (pfuser.isNew)
                                            {
                                                [self getFacebookImage];
                                                user.collected += 500;
                                                //                                                prompt_facebook.visible = FALSE;
                                                [user sync];
                                                //                                                [MBProgressHUD hideHUDForView:[app navController].view animated:YES];
                                            }
                                            else
                                            {                                               
                                                //                                                prompt_facebook.visible = FALSE;
                                                [self getFacebookImage];
                                                //                                                [MBProgressHUD hideHUDForView:[app navController].view animated:YES];
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

#pragma mark WORLDS

- (CCLayer*) detectivedevil
{
    CCLayer *layer          = [CCLayer node];
    CCSprite *bg            = [CCSprite spriteWithFile: @"adventure-2.png"];
    CCSprite *bgfx          = [CCSprite spriteWithFile:@"ui-spinner-fx.png"];
    CCMenuItemImage *button = [CCMenuItemImage itemWithNormalImage:@"btn-start.png" selectedImage:@"btn-start.png" disabledImage:@"btn-start.png" target:self selector:@selector(tap_world:)];
    CCMenu *menu            = [CCMenu menuWithItems:button, nil]; button.tag = 1; button.opacity = 0; button.scale *= 3; button.isEnabled = ( user.worldprogress >= button.tag ); button.isEnabled = ( button.tag <= CURRENT_WORLDS_PER_GAME );
    
    [bg   setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    [bgfx   setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    [menu setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    
    [layer addChild:bg];
    [layer addChild:bgfx];
    [layer addChild:menu];
    
    [bgfx runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:120.0 angle:360.f]]];
    
    if ( !user.unlocked_detective )
    {
        locked_sprite = [CCSprite spriteWithFile:@"bg-locked.png"];
        locked_sprite.position = ccp(screenSize.width/2,screenSize.height/2);
        [layer addChild:locked_sprite];
        
        CCMenuItemImage *unlock_button = [CCMenuItemImage itemWithNormalImage:@"btn-start.png" selectedImage:@"btn-start.png" disabledImage:@"btn-start.png" target:self selector:@selector(tap_unlock_detective)];
        unlock_menu            = [CCMenu menuWithItems:unlock_button, nil];
        
        [unlock_menu setPosition:ccp(screenSize.width/2,screenSize.height/2)];
        [layer addChild:unlock_menu];
    }   
    
    return layer;
}

- (void) tap_unlock_detective
{
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
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Not Enough Souls!"
                                  message:@"You don't have enough souls! Would you like to buy some?"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:@"Buy Souls", nil];
        [alertView show];
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
        [self unschedule: @selector(collectable_remove_tick)];
    }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[ShopScene scene]]];
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