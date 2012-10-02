//
//  GameOverScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 13/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"
#import "LevelSelectScene.h"

#import "Game.h"

@implementation GameOverScene
@synthesize tmp_game, runningAnims, moved;

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
         
         souls              = game.player.bigcollected;
         souls_score        = souls * 1000;
         collected          = game.player.collected;
         timebonus          = (30 - game.player.time);
         timebonus_score    = (timebonus * 100);
         final_score        = souls_score + timebonus_score;
         next_world         = 1;
         next_level         = 1;
         
         [game.user setHighscore:final_score world:game.world level:game.level];
         [game.user setSouls:souls world:game.world level:game.level];
         game.user.collected += collected;
         
         if ( game.world == game.user.worldprogress && game.level == game.user.levelprogress )
         {
             if ( game.level == LEVELS_PER_WORLD )
             {
                 next_level = 1;
                 next_world = game.world + 1;
                 
                 if ( next_world > WORLDS_PER_GAME )
                 {
                     next_world = 1;
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
         }
         else
         {
             if ( game.level == LEVELS_PER_WORLD )
             {
                 next_level = 1;
                 next_world = game.world + 1;
                 
                 if ( next_world > WORLDS_PER_GAME )
                 {
                     next_world = 1;
                 }
             }
             else
             {
                 next_level = game.level + 1;
                 next_world = game.world;
             }
         }

         CCSprite *bg                       = [CCSprite spriteWithFile:[NSString stringWithFormat:@"bg-gameover-%i.png",game.player.bigcollected]];
         CCMenuItemImage *btn_replay        = [CCMenuItemImage itemWithNormalImage:@"btn-reply.png"         selectedImage:@"btn-reply.png"          block:^(id sender) { [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameScene sceneWithWorld:game.world andLevel:game.level isRestart:YES restartMusic:NO]]];}];
         CCMenuItemImage *btn_mainmenu      = [CCMenuItemImage itemWithNormalImage:@"btn-levelselect.png"   selectedImage:@"btn-levelselect.png"    block:^(id sender) { [self restartAudio]; }];
         CCMenuItemImage *btn_next          = [CCMenuItemImage itemWithNormalImage:@"btn-nextlevel.png"     selectedImage:@"btn-nextlevel.png"      block:^(id sender) {[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameScene sceneWithWorld:next_world andLevel:next_level isRestart:NO restartMusic:NO]]]; }];
         label_score                        = [CCLabelTTF labelWithString:@"SCORE: 0" dimensions:CGSizeMake(screenSize.width, 100) hAlignment:kCCTextAlignmentLeft fontName:@"Crashlanding BB" fontSize:74];
         label_subscore                     = [CCLabelTTF labelWithString:@"SOUL BONUS: 0" dimensions:CGSizeMake(screenSize.width, 100) hAlignment:kCCTextAlignmentLeft fontName:@"Crashlanding BB" fontSize:32];

         btn_next.anchorPoint               = ccp(0,0.5f);
         btn_replay.anchorPoint             = ccp(0,0.5f);
         btn_mainmenu.anchorPoint           = ccp(0,0.5f);
         label_score.anchorPoint            = ccp(0,0);
         label_subscore.anchorPoint         = ccp(0,0);
         
         menu = [CCMenu menuWithItems:btn_next, btn_replay, btn_mainmenu, nil];
         [menu alignItemsVerticallyWithPadding:10];

         [menu  setPosition:ccp ( 20, screenSize.height/2 - 130)];
         [bg    setPosition:ccp(screenSize.width/2, screenSize.height/2)];
         [label_score setPosition:ccp(10, screenSize.height - 220)];
         [label_subscore setPosition:ccp(10, label_score.position.y - 60)];
    
         [label_score setColor:ccc3(205, 51, 51)];
         [label_subscore setColor:ccc3(24, 107, 18)];
         label_subscore.opacity = 0;
         menu.opacity = 0;
         
         [self addChild:bg];
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
                                            NSString *str_timebonus = ( timebonus >= 10 ? [NSString stringWithFormat:@"TIME BONUS: 0:%i", timebonus] : [NSString stringWithFormat:@"TIME BONUS: 0:0%i",timebonus]);
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

- (void) time_bonus_tick
{
    if ( tmp_score_increment > 0 )
    {
        tmp_score_increment -= 1;
        tmp_score += 100;
        
        NSString *tmp_str_timebonus = ( tmp_score_increment >= 10 ? [NSString stringWithFormat:@"TIME BONUS: 0:%i", tmp_score_increment] : [NSString stringWithFormat:@"TIME BONUS: 0:0%i",tmp_score_increment]);

        [label_score    setString:[NSString stringWithFormat:@"SCORE: %i",tmp_score]];
        [label_subscore setString:tmp_str_timebonus];
    }
    else
    {
        [self unschedule:@selector(time_bonus_tick)];
        
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
    if ( tmp_game.pastScore != 0 )
    {
        if ( final_score > self.tmp_game.pastScore )
        {
            CCSprite *highscoreSprite   = [CCSprite spriteWithFile:@"ui-newhighscore.png"];
            highscoreSprite.position    = ccp ( [[CCDirector sharedDirector] winSize].width/2, [[CCDirector sharedDirector] winSize].height - 225 );
            [self addChild:highscoreSprite];
            
            if ( doAnim )
            {
                highscoreSprite.scale = 5;
                [highscoreSprite runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2f],[CCScaleTo actionWithDuration:0.2f scale:1], nil]];
            }
        }
    }
}

- (void) showMenuPanelwithAnim:(BOOL)doAnim
{
    [self addChild:menu];
    if ( doAnim )
    {
        [menu runAction:[CCFadeIn actionWithDuration:0.2f]];
    }
    else
    {
        // Stop anim checker
        self.runningAnims = NO;
        
        // Stop all actions
        [self unschedule:@selector(soul_bonus_tick)];
        [self unschedule:@selector(time_bonus_tick)];
        [menu stopAllActions];
        [label_subscore stopAllActions];
        [label_score stopAllActions];
        label_subscore.visible = NO;
        
        // show highscore
        [self showHighscorePanelwithAnim:NO];
        
        // Set all the strings
        [label_score setString:[NSString stringWithFormat:@"SCORE: %i",final_score]];
        menu.opacity = 225;
    }
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { self.moved = YES; }
- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event { if (self.runningAnims && self.moved) { [self showMenuPanelwithAnim:NO]; }}

- (void) restartAudio
{
    if ( ![SimpleAudioEngine sharedEngine].mute )
    {
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bg-main.wav" loop:YES];
    }
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[LevelSelectScene sceneWithWorld:self.tmp_game.world]]];
}

@end