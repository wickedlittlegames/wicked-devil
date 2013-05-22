//
//  WorldSelectScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 11/09/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "WorldSelectScene.h"
#import "LevelSelectScene.h"
#import "StartScene.h"
#import "StatsScene.h"
#import "ShopScene.h"
#import "EquipMenuScene.h"
#import "User.h"
#import "SimpleTableCell.h"
#import "GameOverFacebookScene.h"
#import "Game.h"

@implementation WorldSelectScene

+(CCScene *) scene
{
	CCScene *scene              = [CCScene node];
	WorldSelectScene *current   = [WorldSelectScene node];
	[scene addChild:current];
	return scene;
}

-(id) init
{
	if( (self=[super init]) )
    {
        // 	Useable variables for this scene
        gkHelper = [GameKitHelper sharedGameKitHelper];
        gkHelper.delegate = self;

        app = (AppController*) [[UIApplication sharedApplication] delegate];
        
        if ( [user isOnline] )
        {
            PHPublisherContentRequest *request = [PHPublisherContentRequest requestForApp:(NSString *)WDPHToken secret:(NSString *)WDPHSecret placement:(NSString *)@"world_select" delegate:(id)self];
            request.showsOverlayImmediately = YES;
            [request send];
        }
        
        user            = [[User alloc] init];
        screenSize      = [CCDirector sharedDirector].winSize;
        font            = @"CrashLanding BB";
        fontsize        = 36;
        worlds          = [NSMutableArray arrayWithCapacity:100];
        int big_collectables_total  = (LEVELS_PER_WORLD * CURRENT_WORLDS_PER_GAME) * 3;
        int big_collectables_player = [user getSoulsforAll];
      
        
        
        // Object creation area
        CCSprite *icon_bigcollectable   = [CCSprite spriteWithFile:@"icon-bigcollectable-med.png"];
        CCSprite *icon_collectable      = [CCSprite spriteWithFile:@"ui-collectable.png"]; 
        CCLabelTTF *label_bigcollected  = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i/%i", big_collectables_player, big_collectables_total] dimensions:CGSizeMake(screenSize.width - 80, 30) hAlignment:kCCTextAlignmentRight fontName:font fontSize:32];
        CCLabelTTF *label_collected     = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", user.collected] dimensions:CGSizeMake(screenSize.width - 80, 30) hAlignment:kCCTextAlignmentRight fontName:font fontSize:32];
        CCMenu *menu_back               = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-back.png"    selectedImage:@"btn-back.png"       target:self selector:@selector(tap_back:)], nil];
        CCMenu *menu_equip              = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-powerup.png" selectedImage:@"btn-powerup.png"    target:self selector:@selector(tap_equip:)],nil];
        CCMenu *menu_store              = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-store-world.png" selectedImage:@"btn-store-world.png"    target:self selector:@selector(tap_store:)],nil];
        CCMenuItem *btn_moregames    = [CCMenuItemImage itemWithNormalImage:@"btn-more-games.png"    selectedImage:@"btn-more-games.png" target:self selector:@selector(tap_moregames)];
        CCMenuItem *btn_achievements    = [CCMenuItemImage itemWithNormalImage:@"btn-achievements.png"    selectedImage:@"btn-achievements.png" target:self selector:@selector(tap_achievements)];
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
        [icon_bigcollectable    setPosition:ccp(screenSize.width - 20, screenSize.height - 20)];
        [icon_collectable       setPosition:ccp(screenSize.width - 20, icon_bigcollectable.position.y - 26)];
        [label_bigcollected     setPosition:ccp(screenSize.width/2, screenSize.height - 22)];
        [label_collected        setPosition:ccp(screenSize.width/2, label_bigcollected.position.y - 24)];
        
        // Add world layers to the scroller
//        [worlds addObject:[self updates]];
        [worlds addObject:[self hell]];
        [worlds addObject:[self underground]];
        [worlds addObject:[self ocean]];
        [worlds addObject:[self earth]];
        [worlds addObject:[self comingsoon]];
        scroller = [[CCScrollLayer alloc] initWithLayers:worlds widthOffset: 0];
        [scroller selectPage:user.cache_current_world-1];
        [scroller setPagesIndicatorNormalColor:ccc4(253, 217, 183, 255)];
        [scroller setPagesIndicatorSelectedColor:ccc4(248, 152, 39, 255)];
        
        // Put the children to the screen
        [self addChild:scroller];
        [self addChild:menu_equip];
        [self addChild:menu_back];
        [self addChild:icon_bigcollectable];
        [self addChild:icon_collectable];
        [self addChild:label_bigcollected];
        [self addChild:label_collected];
        [self addChild:behind_fb];
        [self addChild:menu_social];
        
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
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[GameOverFacebookScene sceneWithGame:tmpgame fromScene:2]]];
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
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:0.5f scene:[StatsScene scene]]];
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
    
    user.cache_current_world = sender.tag;
    [user sync_cache_current_world];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[LevelSelectScene sceneWithWorld:sender.tag]]];
}

- (void) tap_equip:(id)sender
{
    [notificationView clear];
    
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:0.5f scene:[EquipMenuScene scene]]];
}

- (void) tap_store:(id)sender
{
    [notificationView clear];
    
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:0.5f scene:[ShopScene scene]]];
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
    
//    [self reportAchievements];
    
    GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
    achivementViewController.achievementDelegate = self;
    [[app navController] presentModalViewController:achivementViewController animated:YES];
}


#pragma mark WORLDS

- (CCLayer*) hell
{
    CCLayer *layer          = [CCLayer node];
    CCSprite *bg            = [CCSprite spriteWithFile:@"bg-world-hell-new.png"];
    CCMenuItemImage *button = [CCMenuItemImage itemWithNormalImage:@"btn-start.png" selectedImage:@"btn-start.png" disabledImage:@"btn-start.png" target:self selector:@selector(tap_world:)];
    CCMenu *menu            = [CCMenu menuWithItems:button, nil]; button.tag = 1; button.opacity = 0; button.scale *= 3; button.isEnabled = ( user.worldprogress >= button.tag ); button.isEnabled = ( button.tag <= CURRENT_WORLDS_PER_GAME );
    
    [bg   setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    [menu setPosition:ccp(screenSize.width/2, screenSize.height/2)];

    [layer addChild:bg];
    [layer addChild:menu];
    
    return layer;
}

- (CCLayer*) underground
{
    CCLayer *layer          = [CCLayer node];
    CCSprite *bg            = [CCSprite spriteWithFile:@"bg-world-underground-new.png"];
    CCMenuItemImage *button = [CCMenuItemImage itemWithNormalImage:@"btn-start.png" selectedImage:@"btn-start.png" disabledImage:@"btn-start.png" target:self selector:@selector(tap_world:)];
    CCMenu *menu            = [CCMenu menuWithItems:button, nil]; button.tag = 2; button.opacity = 0; button.scale *= 3; button.isEnabled = ( button.tag <= CURRENT_WORLDS_PER_GAME ); button.isEnabled = ( user.worldprogress >= button.tag ); 
    
    [bg   setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    [menu setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    
    [layer addChild:bg];
    [layer addChild:menu];
    
    if ( DEVDEBUG ) { button.isEnabled = TRUE; }    

    if ( !button.isEnabled )
    {
        CCSprite *locked_sprite = [CCSprite spriteWithFile:@"bg-locked.png"];
        locked_sprite.position = ccp(screenSize.width/2,screenSize.height/2);
        [layer addChild:locked_sprite];
    }
    
    return layer;
}

- (CCLayer*) ocean
{
    CCLayer *layer          = [CCLayer node];
    CCSprite *bg            = [CCSprite spriteWithFile:@"bg-world-ocean.png"];
    CCMenuItemImage *button = [CCMenuItemImage itemWithNormalImage:@"btn-start.png" selectedImage:@"btn-start.png" disabledImage:@"btn-start.png" target:self selector:@selector(tap_world:)];
    CCMenu *menu            = [CCMenu menuWithItems:button, nil]; button.tag = 3; button.opacity = 0; button.scale *= 3; button.isEnabled = ( button.tag <= CURRENT_WORLDS_PER_GAME ); button.isEnabled = ( user.worldprogress >= button.tag );
        
    [bg   setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    [menu setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    
    [layer addChild:bg];
    [layer addChild:menu];
    
    if ( DEVDEBUG ) { button.isEnabled = TRUE; }    

    if ( !button.isEnabled )
    {
        CCSprite *locked_sprite = [CCSprite spriteWithFile:@"bg-locked.png"];
        locked_sprite.position = ccp(screenSize.width/2,screenSize.height/2);
        [layer addChild:locked_sprite];
    }
    
    return layer;
}

- (CCLayer*) earth
{
    CCLayer *layer          = [CCLayer node];
    CCSprite *bg            = [CCSprite spriteWithFile:@"bg-world-land.png"];
    CCMenuItemImage *button = [CCMenuItemImage itemWithNormalImage:@"btn-start.png" selectedImage:@"btn-start.png" disabledImage:@"btn-start.png" target:self selector:@selector(tap_world:)];
    CCMenu *menu            = [CCMenu menuWithItems:button, nil]; button.tag = 4; button.opacity = 0; button.scale *= 3; button.isEnabled = ( button.tag <= CURRENT_WORLDS_PER_GAME ); button.isEnabled = ( user.worldprogress >= button.tag );
    
    [bg   setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    [menu setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    
    [layer addChild:bg];
    [layer addChild:menu];
    
    if ( DEVDEBUG ) { button.isEnabled = TRUE; }    
    

    if ( !button.isEnabled )
    {
        CCSprite *locked_sprite = [CCSprite spriteWithFile:@"bg-locked.png"];
        locked_sprite.position = ccp(screenSize.width/2,screenSize.height/2);
        [layer addChild:locked_sprite];
    }
    
    return layer;
}

- (CCLayer*) comingsoon
{
    CCLayer *layer          = [CCLayer node];
    CCSprite *bg            = [CCSprite spriteWithFile:@"bg-coming-soon.png"];
    
    [bg   setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    
    [layer addChild:bg];
    
    return layer;
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