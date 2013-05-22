//
//  GameOverScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 13/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"
#import "StartScene.h"
#import "LevelSelectScene.h"
#import "DetectiveLevelSelectScene.h"
#import "GameOverFacebookScene.h"
#import "EquipMenuScene.h"
#import "MKInfoPanel.h"
#import "AppDelegate.h"

#import <Twitter/Twitter.h>

#import "Game.h"

@implementation GameOverScene

#pragma mark === Initialization ===

+ (CCScene*) sceneWithGame:(Game *)game
{
    CCScene *scene = [CCScene node];
    GameOverScene *current = [[GameOverScene alloc] initWithGame:game];
    [scene addChild:current];
	return scene;
}

- (id) initWithGame:(Game*)game
 {
     if( (self=[super init]) )
     {

         CGSize screenSize = [CCDirector sharedDirector].winSize;
         self.isTouchEnabled    = YES; self.moved = NO; self.runningAnims = YES;
         self.tmp_game          = game;
         
         self.isBonusLevel  = (game.world == 11 && game.level == 1);
         souls              = game.player.bigcollected;
         souls_score        = souls * 1000;
         collected          = game.player.collected;
         timebonus          = (game.timelimit - game.player.time);
         timebonus_score    = (timebonus * 100);
         final_score        = (souls_score + timebonus_score) + (collected * game.player.per_collectable);
         next_world         = 1;
         next_level         = 1;
         
         
         if ( [game.user isOnline] )
         {
             PHPublisherContentRequest *request = [PHPublisherContentRequest requestForApp:(NSString *)WDPHToken secret:(NSString *)WDPHSecret placement:(NSString *)@"game_over" delegate:(id)self];
             request.showsOverlayImmediately = YES;
             [request send];
         }
         
         game.user.collected += collected;
         [game.user setHighscore:final_score world:game.world level:game.level];
         [game.user setSouls:souls world:game.world level:game.level];
         if ( !(game.world == 20) )
         {
             [game.user setHalos:game.player.halocollected world:game.world level:game.level];
         }
         
         bool restartAudioToggle = FALSE;
         CCMenuItemImage *btn_next          = [CCMenuItemImage itemWithNormalImage:@"btn-nextlevel.png"     selectedImage:@"btn-nextlevel.png"      block:^(id sender) {[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameScene sceneWithWorld:next_world andLevel:next_level isRestart:NO restartMusic:restartAudioToggle]]]; if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];} }];
         
         if ( !self.isBonusLevel || !(game.world == 20) )
         {
             if ( game.world == game.user.worldprogress && game.level == game.user.levelprogress )
             {
                 if ( game.level == LEVELS_PER_WORLD )
                 {
                     next_level = 1;
                     next_world = game.world + 1;
                     
                     if ( next_world > CURRENT_WORLDS_PER_GAME )
                     {
                         restartAudioToggle = TRUE;
                         btn_next.visible = FALSE;
                     }
                 }
                 else
                 {
                     next_level = game.level + 1;
                     next_world = game.world;
                 }

                 game.user.worldprogress = next_world;
                 game.user.levelprogress = next_level;
                 
                 [game.user setGameProgressforWorld:next_world level:next_level];
                 [game.user sync];
                 
                 // This is where it should sent off to Facebook Open Graph for Score
                 // Andy just completed Hell Level 19 on Wicked Devil
                 NSMutableDictionary<FBGraphObject> *action = [FBGraphObject graphObject];
                 action[@"level"] = [NSString stringWithFormat:@"http://www.wickedlittlegames.com/opengraph/wickeddevil/world-level.php?og:world=%i&og:level=%i&og:score=%i&og:bigsouls=%i", game.world, game.level, final_score, souls];
                 
                 [FBRequestConnection startForPostWithGraphPath:@"me/wickeddevil:completed"
                                                    graphObject:action
                                              completionHandler:^(FBRequestConnection *connection,
                                                                  id result,
                                                                  NSError *error) {

                                              }];
             }
             else
             {
                 if ( game.level == LEVELS_PER_WORLD )
                 {
                     next_level = 1;
                     next_world = game.world + 1;
                     
                     if ( next_world > CURRENT_WORLDS_PER_GAME )
                     {
                         restartAudioToggle = TRUE;
                         btn_next.visible = FALSE;                     
                     }
                 }
                 else
                 {
                     next_level = game.level + 1;
                     next_world = game.world;
                 }
             }
             
             game.user.cache_current_world = next_world;
             [game.user sync_cache_current_world];
             [game.user check_achiements];
         }
         [game.user sync];
         
         CCSprite *bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"bg-gameover-%i.png",game.player.bigcollected]];
         [bg setPosition:ccp(screenSize.width/2, screenSize.height/2)];
         [self addChild:bg];         
         
         CCMenuItemImage *btn_replay        = [CCMenuItemImage itemWithNormalImage:@"btn-reply.png"         selectedImage:@"btn-reply.png"          block:^(id sender) { [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameScene sceneWithWorld:game.world andLevel:game.level isRestart:YES restartMusic:NO]]]; if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];} }];
         CCMenuItemImage *btn_mainmenu      = [CCMenuItemImage itemWithNormalImage:@"btn-levelselect.png"   selectedImage:@"btn-levelselect.png"    block:^(id sender) { [self restartAudio]; }];
         label_score                        = [CCLabelTTF labelWithString:@"SCORE: 0" dimensions:CGSizeMake(screenSize.width, 100) hAlignment:kCCTextAlignmentLeft fontName:@"Crashlanding BB" fontSize:70];
         label_subscore                     = [CCLabelTTF labelWithString:@"SOUL BONUS: 0" dimensions:CGSizeMake(screenSize.width, 100) hAlignment:kCCTextAlignmentLeft fontName:@"Crashlanding BB" fontSize:32];
         CCMenuItemImage *share_twitter     = [CCMenuItemImage itemWithNormalImage:@"btn-tweet-score.png" selectedImage:@"btn-tweet-score.png" block:^(id sender){ [self tap_twitter]; }];
         CCMenuItemImage *share_facebook    = [CCMenuItemImage itemWithNormalImage:@"btn-fb-score.png" selectedImage:@"btn-fb-score.png" block:^(id sender){ [self tap_facebook]; }];
         share_menu                 = [CCMenu menuWithItems:share_twitter, share_facebook, nil];
         share_facebook.visible = NO;
         [share_menu alignItemsHorizontallyWithPadding:10];
         
         btn_next.anchorPoint               = ccp(0,0.5f);
         btn_replay.anchorPoint             = ccp(0,0.5f);
         btn_mainmenu.anchorPoint           = ccp(0,0.5f);
         label_score.anchorPoint            = ccp(0,0);
         label_subscore.anchorPoint         = ccp(0,0);
         
         menu = [CCMenu menuWithItems:btn_next, btn_replay, btn_mainmenu, nil];
         [menu alignItemsVerticallyWithPadding:10];
         
         [menu  setPosition:ccp ( 20, screenSize.height/2 - 130)];
         [label_score setPosition:ccp(10, screenSize.height - 220)];
         [label_subscore setPosition:ccp(10, label_score.position.y - 60)];
         [share_menu setPosition:ccp(screenSize.width/2, 20)];
         share_menu.visible = NO;
    
         [label_score setColor:ccc3(205, 51, 51)];
         [label_subscore setColor:ccc3(24, 107, 18)];
         label_subscore.opacity = 0;
         menu.opacity = 0;
         
         [self addChild:label_score];
         [self addChild:label_subscore];
         
         tmp_score = 0;
         tmp_score_increment = souls_score;
         
         [label_subscore runAction:[CCSequence actions:
                                    [CCDelayTime actionWithDuration:0.2f],
                                    [CCFadeIn actionWithDuration:0.2f],
                                    [CCCallBlock actionWithBlock:^(void)
                                     {
                                         [self schedule: @selector(soul_bonus_tick) interval: 1.0f/60.0f];
                                     }],nil]];

         if ( self.isBonusLevel ) btn_next.visible = NO;
     
         if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
         {
             share_facebook.visible = YES;
         }
     }
     return self;
 }

//#pragma mark === Score Animation Steps ===

- (void) soul_bonus_tick
{
    if ( tmp_score_increment > 0 )
    {
        tmp_score_increment -= 200;
        tmp_score += 200;
        
        [label_score setString:[NSString stringWithFormat:@"SCORE: %i",tmp_score]];
        [label_subscore setString:[NSString stringWithFormat:@"SOUL BONUS: %i", tmp_score_increment]];
    }
    else
    {
        [self unschedule: @selector(soul_bonus_tick)];
        
        tmp_score = souls_score;
        tmp_score_increment = timebonus;
        
        if ( timebonus > 0 )
        {
            [label_subscore runAction:[CCSequence actions:
                                       [CCDelayTime actionWithDuration:0.2f],
                                       [CCFadeOut actionWithDuration:0.2f],
                                       [CCCallBlock actionWithBlock:^(void)
                                        {
                                            NSString *str_timebonus = [NSString stringWithFormat:@"TIME BONUS: %i secs", timebonus];
                                            [label_subscore setString:str_timebonus];
                                        }],
                                       [CCFadeIn actionWithDuration:0.2f],
                                       [CCCallBlock actionWithBlock:^(void)
                                        {
                                            [self schedule: @selector(time_bonus_tick) interval: 1.0f/60.0f];
                                        }],nil]];
        }
        else
        {
            tmp_score = souls_score + timebonus_score;
            tmp_score_increment = self.tmp_game.player.collected;
            
            if ( collected > 0 )
            {
                [label_subscore runAction:[CCSequence actions:
                                           [CCDelayTime actionWithDuration:0.2f],
                                           [CCFadeOut actionWithDuration:0.2f],
                                           [CCCallBlock actionWithBlock:^(void)
                                            {
                                                NSString *str_timebonus = [NSString stringWithFormat:@"COLLECTED BONUS: %i", collected];
                                                [label_subscore setString:str_timebonus];
                                            }],
                                           [CCFadeIn actionWithDuration:0.2f],
                                           [CCCallBlock actionWithBlock:^(void)
                                            {
                                                [self schedule: @selector(collectable_bonus_tick) interval: 1.0f/60.0f];
                                            }],nil]];
            }
            else
            {
                // GO TO LAST STEP
                [label_subscore runAction:[CCSequence actions:
                                           [CCDelayTime actionWithDuration:0.2f],
                                           [CCFadeOut actionWithDuration:0.2f],
                                           [CCCallBlock actionWithBlock:^(void) { [self showHighscorePanelwithAnim:YES]; }],
                                           [CCDelayTime actionWithDuration:0.2f],
                                           [CCCallBlock actionWithBlock:^(void)
                                            {
                                                self.runningAnims = NO;
                                                [self showMenuPanelwithAnim:YES];
                                            }],nil]];
            }
        }
    }
}

- (void) time_bonus_tick
{
    if ( tmp_score_increment > 0 )
    {
        tmp_score_increment -= 1;
        tmp_score += 100;
        
        NSString *tmp_str_timebonus = [NSString stringWithFormat:@"TIME BONUS: %i secs", tmp_score_increment];

        [label_score    setString:[NSString stringWithFormat:@"SCORE: %i",tmp_score]];
        [label_subscore setString:tmp_str_timebonus];
    }
    else
    {
        [self unschedule:@selector(time_bonus_tick)];

        tmp_score = souls_score + timebonus_score;
        tmp_score_increment = self.tmp_game.player.collected;
        
        if ( collected > 0 )
        {
            [label_subscore runAction:[CCSequence actions:
                                       [CCDelayTime actionWithDuration:0.2f],
                                       [CCFadeOut actionWithDuration:0.2f],
                                       [CCCallBlock actionWithBlock:^(void)
                                        {
                                            NSString *str_timebonus = [NSString stringWithFormat:@"COLLECTED BONUS: %i", collected];
                                            [label_subscore setString:str_timebonus];
                                        }],
                                       [CCFadeIn actionWithDuration:0.2f],
                                       [CCCallBlock actionWithBlock:^(void)
                                        {
                                            [self schedule: @selector(collectable_bonus_tick) interval: 1.0f/60.0f];
                                        }],nil]];
        }
        else
        {
            // GO TO LAST STEP
            [label_subscore runAction:[CCSequence actions:
                                       [CCDelayTime actionWithDuration:0.2f],
                                       [CCFadeOut actionWithDuration:0.2f],
                                       [CCCallBlock actionWithBlock:^(void) { [self showHighscorePanelwithAnim:YES]; }],
                                       [CCDelayTime actionWithDuration:0.2f],
                                       [CCCallBlock actionWithBlock:^(void)
                                        {
                                            self.runningAnims = NO;
                                            [self showMenuPanelwithAnim:YES];
                                        }],nil]];
        }
    }
}   

- (void) collectable_bonus_tick
{
    if ( tmp_score_increment > 0 )
    {
        tmp_score_increment -= 1;
        tmp_score += self.tmp_game.player.per_collectable;
        
        NSString *tmp_str_timebonus = [NSString stringWithFormat:@"COLLECTED BONUS: %i", tmp_score_increment];
        
        [label_score    setString:[NSString stringWithFormat:@"SCORE: %i",tmp_score]];
        [label_subscore setString:tmp_str_timebonus];
    }
    else
    {
        [self unschedule:@selector(collectable_bonus_tick)];
        
        [label_subscore runAction:[CCSequence actions:
                                   [CCDelayTime actionWithDuration:0.2f],
                                   [CCFadeOut actionWithDuration:0.2f],
                                   [CCCallBlock actionWithBlock:^(void) { [self showHighscorePanelwithAnim:YES]; }],
                                   [CCDelayTime actionWithDuration:0.2f],
                                   [CCCallBlock actionWithBlock:^(void)
                                    {
                                        self.runningAnims = NO;
                                        [self showMenuPanelwithAnim:YES];
                                    }],nil]];
    }
}


- (void) showHighscorePanelwithAnim:(BOOL)doAnim
{
    if ( self.tmp_game.pastScore != 0 )
    {
        if ( final_score > self.tmp_game.pastScore )
        {
            CCSprite *highscoreSprite   = [CCSprite spriteWithFile:@"ui-newhighscore.png"];
            highscoreSprite.position    = ccp ( [[CCDirector sharedDirector] winSize].width/2, [[CCDirector sharedDirector] winSize].height - 225 );
            if (doAnim) highscoreSprite.scale = 5;
            [self addChild:highscoreSprite];
            
            if ( doAnim )
            {
                [highscoreSprite runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2f],[CCScaleTo actionWithDuration:0.2f scale:1], nil]];
            }
        }
    }
}

- (void) showMenuPanelwithAnim:(BOOL)doAnim
{
    [self addChild:menu];
    [self addChild:share_menu];
    if ( doAnim )
    {
        if ( [self.tmp_game.user isOnline] )
        {
            share_menu.visible = YES;
        }
        [menu runAction:[CCFadeIn actionWithDuration:0.2f]];
        [share_menu runAction:[CCFadeIn actionWithDuration:0.2f]];        
    }
    else
    {
        // Stop anim checker
        self.runningAnims = NO;
        
        // Stop all actions
        [self unschedule:@selector(soul_bonus_tick)];
        [self unschedule:@selector(time_bonus_tick)];
        [self unschedule:@selector(collectable_bonus_tick)];        
        [menu stopAllActions];
        [label_subscore stopAllActions];
        [label_score stopAllActions];
        label_subscore.visible = NO;
        
        // show highscore
        [self showHighscorePanelwithAnim:NO];
        
        // Set all the strings
        [label_score setString:[NSString stringWithFormat:@"SCORE: %i",final_score]];
        menu.opacity = 225;
        
        if ( [self.tmp_game.user isOnline] )
        {
            share_menu.visible = YES;
        }
    }
    
    if ( self.tmp_game.user.collected >= 2000 && ![self.tmp_game.user.udata boolForKey:@"TIP-POWERUP-SEEN"] )
    {
        BlockAlertView* alert = [BlockAlertView alertWithTitle:@"Good News!" message:@"You can now afford your first Devil Upgrade!"];
        [alert addButtonWithTitle:@"Visit Shop" block:^{
            [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:1.0f scene:[EquipMenuScene  scene]]];
        }];
        [alert setCancelButtonWithTitle:@"Not yet, I'm saving up!" block:^{}];
        [alert show];
        [self.tmp_game.user.udata setBool:YES forKey:@"TIP-POWERUP-SEEN"];        
    }
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { self.moved = YES; }
- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event { if (self.runningAnims && self.moved) { [self showMenuPanelwithAnim:NO]; }}

- (void) restartAudio
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    if ( !(self.tmp_game.world == 20) )
    {
        if ( ![SimpleAudioEngine sharedEngine].mute )
        {
            [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bg-main.aifc" loop:YES];
        }
    }
    
    if ( self.isBonusLevel )
    {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[StartScene scene]]];
    }
    else if ( self.tmp_game.world == 20 )
    {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[DetectiveLevelSelectScene sceneWithWorld:self.tmp_game.world]]];
    }
    else
    {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[LevelSelectScene sceneWithWorld:self.tmp_game.world]]];
    }
}

- (void) tap_twitter
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];

    if ( [TWTweetComposeViewController canSendTweet] )
    {
        // Create the view controller
        TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
        [twitter setInitialText:[NSString stringWithFormat:@"I just scored %i on World %i, Level %i on Wicked Devil for iOS http://bit.ly/wickeddevil", final_score,self.tmp_game.world, self.tmp_game.level]];
        twitter.completionHandler = ^(TWTweetComposeViewControllerResult res) {
            if (TWTweetComposeViewControllerResultDone) {
                // Add in a cool UI effect to show tweet causing collectables to increase!
                // tmp_game.user.collected += 50;
                // [tmp_game.user sync];
            } else if (TWTweetComposeViewControllerResultCancelled) {
                // Cancelled
            }
            [[app navController] dismissModalViewControllerAnimated:YES];
        };
        [[app navController] presentModalViewController:twitter animated:YES];
    }
    else
    {
        BlockAlertView* alert = [BlockAlertView alertWithTitle:@"Sorry!" message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup."];
        [alert setCancelButtonWithTitle:@"OK" block:^{}];
        [alert show];
    }
}

- (void) tap_facebook
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameOverFacebookScene sceneWithGame:self.tmp_game fromScene:3]]];
}

@end