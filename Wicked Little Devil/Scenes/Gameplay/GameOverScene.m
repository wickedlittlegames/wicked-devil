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
         self.isTouchEnabled = YES;
         self.tmp_game = game;
         basicscore = (game.player.bigcollected * 1000);
         timebonus = 0;
         self.moved = NO;
         collectedbonus = (game.player.collected * 10);
         if ( game.player.time < 30 )
         {
             timebonus = (30 - game.player.time) * 100;
         }
         self.runningAnims = YES;
         
         totalscore = (basicscore + timebonus);
         
         CCSprite *bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"bg-gameover-%i.png",game.player.bigcollected]];
         [bg setPosition:ccp(screenSize.width/2, screenSize.height/2)];
         [self addChild:bg];
         
         CCMenuItemImage *btn_replay = [CCMenuItemImage itemWithNormalImage:@"btn-reply.png" selectedImage:@"btn-reply.png" block:^(id sender) {
             [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameScene sceneWithWorld:game.world andLevel:game.level isRestart:YES restartMusic:NO]]];
         }];

         CCMenuItemImage *btn_next = [CCMenuItemImage itemWithNormalImage:@"btn-nextlevel.png" selectedImage:@"btn-nextlevel.png" block:^(id sender) {
             int decider_world = 1;
             int decider_level = 1;
             if ( game.user.worldprogress == WORLDS_PER_GAME && game.user.levelprogress == LEVELS_PER_WORLD )
             {
                 // show credits!, beat the game!
             }
             else
             {
                 if ( game.user.levelprogress == LEVELS_PER_WORLD )
                 {
                     decider_level = 1;
                     decider_world = game.world+1;
                 }
                 else
                 {
                     decider_world = game.world;
                     decider_level = game.level + 1;
                 }
                 if ( decider_world > game.world )
                 {
                    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameScene sceneWithWorld:decider_world andLevel:decider_level isRestart:NO restartMusic:YES]]];
                 }
                 else
                 {
                     [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameScene sceneWithWorld:decider_world andLevel:decider_level isRestart:NO restartMusic:NO]]];
                 }
             }
         }];
         btn_next.tag = 2;
         
         CCMenuItemImage *btn_mainmenu = [CCMenuItemImage itemWithNormalImage:@"btn-levelselect.png" selectedImage:@"btn-levelselect.png" block:^(id sender) {
             if ( ![SimpleAudioEngine sharedEngine].mute )
             {
                 [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
                 [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bg-main.wav" loop:YES];
             }
             [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[LevelSelectScene sceneWithWorld:game.world]]];
         }];
         
         btn_next.anchorPoint = ccp(0,0.5f);
         btn_replay.anchorPoint = ccp(0,0.5f);
         btn_mainmenu.anchorPoint = ccp(0,0.5f);         
         menu = [CCMenu menuWithItems:btn_next, btn_replay, btn_mainmenu, nil];
         [menu alignItemsVerticallyWithPadding:10];
         [menu setPosition:ccp ( 20, screenSize.height/2 - 140)];

         label_score = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"SCORE: %i",basicscore] dimensions:CGSizeMake(screenSize.width, 100) hAlignment:kCCTextAlignmentLeft fontName:@"Crashlanding BB" fontSize:74];
         [label_score setPosition:ccp(10, screenSize.height - 220)];
         label_score.anchorPoint = ccp(0,0);
         [label_score setColor:ccc3(205, 51, 51)];
         [self addChild:label_score];

         label_subscore = [CCLabelTTF labelWithString:@" " dimensions:CGSizeMake(screenSize.width, 100) hAlignment:kCCTextAlignmentLeft fontName:@"Crashlanding BB" fontSize:32];
         [label_subscore setPosition:ccp(10, label_score.position.y - 60)];
         label_subscore.anchorPoint = ccp(0,0);
         [label_subscore setColor:ccc3(24, 107, 18)];
         [self addChild:label_subscore];
         label_subscore.opacity = 0;
         
         if ( game.player.bigcollected >= 1 )
         {
            tmp_player_score = 0;
            tmp_score_increment = basicscore;
            [self schedule: @selector(general_tick) interval: 1.0f/60.0f];
         }
         else
         {
             [self didnt_win];
         }
     }
     return self;
 }


//#pragma mark === Score Animation Steps ===

- (void) didnt_win
{
    [menu removeChildByTag:2 cleanup:YES];
    [menu runAction:[CCFadeIn actionWithDuration:1.0f]];
}

- (void) general_tick
{
    if ( tmp_score_increment > 0 )
    {
        tmp_score_increment -= 200;
        tmp_player_score += 200;
        
        [label_score setString:[NSString stringWithFormat:@"SCORE: %i",tmp_player_score]];
        [label_subscore setString:[NSString stringWithFormat:@"SOUL BONUS: %i", tmp_score_increment]];
    }
    else
    {
        [self unschedule: @selector(general_tick)];
        [label_subscore runAction:[CCSequence actions:[CCCallBlock actionWithBlock:^(void) {
            [self do_scores];
        }], nil]];
    }
}


- (void) do_scores
{
    tmp_player_score = basicscore;
    tmp_score_increment = (30 - self.tmp_game.player.time);
    
    [label_score runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2], [CCCallBlock actionWithBlock:^(void){
        if ( (30 - self.tmp_game.player.time) > 0 )
        {
            if ( tmp_score_increment >= 10 )
            {
                [label_subscore setString:[NSString stringWithFormat:@"TIME BONUS: 0:%i", tmp_score_increment]];
            }
            else
            {
                [label_subscore setString:[NSString stringWithFormat:@"TIME BONUS: 0:0%i", tmp_score_increment]];
            }
            [label_subscore runAction:[CCSequence actions:[CCFadeIn actionWithDuration:.2f], [CCDelayTime actionWithDuration:0.2f],[CCCallBlock actionWithBlock:^(void) {
                [self schedule: @selector(tick) interval: 1.0f/45.0f];
            }], nil]];
        }
        else
        {
            [self addChild:menu];
            [menu setOpacity:0.0f];
            [menu runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f],[CCFadeIn actionWithDuration:1.0f],nil]];
        }
    }], nil]];
}

- (void) tick
{
    if ( tmp_score_increment > 0 )
    {
        tmp_score_increment -= 1;
        tmp_player_score += 100;
        
        [label_score setString:[NSString stringWithFormat:@"SCORE: %i",tmp_player_score]];
        if ( tmp_score_increment >= 10 )
        {
            [label_subscore setString:[NSString stringWithFormat:@"TIME BONUS: 0:%i", tmp_score_increment]];
        }
        else
        {
            [label_subscore setString:[NSString stringWithFormat:@"TIME BONUS: 0:0%i", tmp_score_increment]];
        }
    }
    else
    {
        [self unschedule: @selector(tick)];
        [label_subscore runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f], [CCCallBlock actionWithBlock:^(void) {
            tmp_player_score = basicscore + timebonus;
            tmp_score_increment = collectedbonus;
            [label_subscore runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.2f], [CCDelayTime actionWithDuration:0.5f], nil]];

            if (totalscore > self.tmp_game.pastScore )
            {
                [self showHighscorePanel];
            }
            
            [self addChild:menu];
            [menu setOpacity:0.0f];
            [menu runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f],[CCFadeIn actionWithDuration:.2f],nil]];
            
            self.runningAnims = NO;
        }], nil]];
    }
}

- (void) showHighscorePanel
{
    if ( tmp_game.pastScore != 0 )
    {
        CCSprite *highscoreSprite = [CCSprite spriteWithFile:@"ui-newhighscore.png"];
        highscoreSprite.position = ccp ( [[CCDirector sharedDirector] winSize].width/2, [[CCDirector sharedDirector] winSize].height - 225 );
        highscoreSprite.scale = 5;
        [self addChild:highscoreSprite];
        [highscoreSprite runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.2f scale:1], nil]];
    }
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.moved = YES;
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.runningAnims && self.moved)
    {
        self.runningAnims = NO;
        [menu stopAllActions];
        [label_subscore stopAllActions];
        [label_score stopAllActions];
        [self unschedule:@selector(general_tick)];
        [self unschedule:@selector(tick)];
        label_subscore.visible = NO;
        [self stopAllActions];
        [label_score setString:[NSString stringWithFormat:@"Score: %i",totalscore]];
        if ( totalscore > self.tmp_game.pastScore && tmp_game.pastScore != 0)
        {
            CCSprite *highscoreSprite2 = [CCSprite spriteWithFile:@"ui-newhighscore.png"];
            highscoreSprite2.position = ccp ( [[CCDirector sharedDirector] winSize].width/2, [[CCDirector sharedDirector] winSize].height - 225 );
            [self addChild:highscoreSprite2];
        }
        [self addChild:menu];
        menu.opacity = 225;
    }
}

@end
