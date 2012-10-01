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
@synthesize tmp_game;

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
         self.tmp_game = game;
         basicscore = (game.player.bigcollected * 1000);
         timebonus = 0;
         collectedbonus = (game.player.collected * 10);
         if ( game.player.time < 30 )
         {
             timebonus = (30 - game.player.time) * 100;
         }
         
         totalscore = (basicscore + timebonus) + collectedbonus;
         
         CCSprite *bg = [CCSprite spriteWithFile:@"bg-endoflevel.png"];
         [bg setPosition:ccp(screenSize.width/2, screenSize.height/2)];
         [self addChild:bg];
         
         //CCSprite *title = [CCSprite spriteWithFile:@"btn-start.png"];
         //[title setPosition:ccp(screenSize.width/2, screenSize.height - 100)];
         //[self addChild:title];
         
         CCMenuItemImage *btn_replay = [CCMenuItemImage itemWithNormalImage:@"btn-reply.png" selectedImage:@"btn-reply.png" block:^(id sender) {
             [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameScene sceneWithWorld:game.world andLevel:game.level isRestart:YES]]];
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
                 [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameScene sceneWithWorld:decider_world andLevel:decider_level isRestart:NO]]];
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
         
         menu = [CCMenu menuWithItems:btn_next, btn_replay, btn_mainmenu, nil];
         [menu alignItemsVerticallyWithPadding:10];
         [menu setPosition:ccp ( screenSize.width/2, screenSize.height/2 -100)];
         [self addChild:menu];
         [menu setOpacity:0.0f];
         
//         for (int i = 1; i <= game.player.bigcollected; i++)
//         {
//             CCSprite *icon_bigcollected = [CCSprite spriteWithFile:@"ingame-big-collectable.png"];
//             [icon_bigcollected setPosition:ccp(40 * i, screenSize.height - 200)];
//             [self addChild:icon_bigcollected];
//             [icon_bigcollected setScale:1.5];
//         }
         
         label_score = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"SCORE: %i",basicscore] dimensions:CGSizeMake(screenSize.width, 100) hAlignment:kCCTextAlignmentCenter fontName:@"Crashlanding BB" fontSize:30];
         [label_score setPosition:ccp(screenSize.width/2, screenSize.height/2)];
         [self addChild:label_score];

         label_subscore = [CCLabelTTF labelWithString:@" " dimensions:CGSizeMake(screenSize.width, 100) hAlignment:kCCTextAlignmentCenter fontName:@"Crashlanding BB" fontSize:24];
         [label_subscore setPosition:ccp(screenSize.width/2, screenSize.height/2 - 60)];
         [self addChild:label_subscore];
         
         if ( game.player.bigcollected >= 1 )
         {
            [self do_scores];
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
    CCLabelTTF *label_didntwin = [CCLabelTTF labelWithString:@"Didn't collect any" dimensions:CGSizeMake([[CCDirector sharedDirector] winSize].width, 100) hAlignment:kCCTextAlignmentCenter fontName:@"Crashlanding BB" fontSize:30];
    [label_didntwin setPosition:ccp([[CCDirector sharedDirector] winSize].width/2, [[CCDirector sharedDirector] winSize].height/2)];
    [self addChild:label_didntwin];

    [menu removeChildByTag:2 cleanup:YES];
    [menu runAction:[CCFadeIn actionWithDuration:1.0f]];
}


- (void) do_scores
{
    tmp_player_score = basicscore;
    tmp_score_increment = timebonus;

    [label_subscore setString:[NSString stringWithFormat:@"TIME BONUS: %i",timebonus]];
    
    [self schedule: @selector(tick) interval: 1.0f/60.0f];
}

- (void) tick
{
    if ( tmp_score_increment > 0 )
    {
        if (tmp_score_increment > 100)
		{
            tmp_score_increment -= 100;
            tmp_player_score += 100;
            [label_score setString:[NSString stringWithFormat:@"Score: %i",tmp_player_score]];
            [label_subscore setString:[NSString stringWithFormat:@"TIME BONUS: %i", tmp_score_increment]];
        }
        if (tmp_score_increment > 10)
		{
            tmp_score_increment -= 50;
            tmp_player_score += 50;
            [label_score setString:[NSString stringWithFormat:@"Score: %i",tmp_player_score]];
            [label_subscore setString:[NSString stringWithFormat:@"TIME BONUS: %i", tmp_score_increment]];            
        }
        else
		{
            tmp_score_increment --;
            tmp_player_score ++;
            [label_score setString:[NSString stringWithFormat:@"Score: %i",tmp_player_score]];
            [label_subscore setString:[NSString stringWithFormat:@"TIME BONUS: %i", tmp_score_increment]];            
        }
    }
    else
    {
        [self unschedule: @selector(tick)];
        [label_subscore runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0f], [CCCallBlock actionWithBlock:^(void) {
            tmp_player_score = basicscore + timebonus;
            tmp_score_increment = collectedbonus;
            [label_subscore runAction:[CCFadeOut actionWithDuration:0.5f]];
            [label_subscore setString:[NSString stringWithFormat:@"COLLECTED BONUS: %i",collectedbonus]];
            if ( self.tmp_game.player.collected > 0 ) [label_subscore runAction:[CCFadeIn actionWithDuration:0.5f]];
            
            [self schedule: @selector(tick2) interval: 1.0f/60.0f];
        }], nil]];
    }
}

- (void) tick2
{
    if ( tmp_score_increment > 0 && self.tmp_game.player.collected > 0 )
    {
        if (tmp_score_increment > 100)
		{
            tmp_score_increment -= 50;
            tmp_player_score += 50;
            [label_score setString:[NSString stringWithFormat:@"Score: %i",tmp_player_score]];
            [label_subscore setString:[NSString stringWithFormat:@"COLLECTED BONUS: %i", tmp_score_increment]];
        }
        if (tmp_score_increment > 10)
		{
            tmp_score_increment -= 10;
            tmp_player_score += 10;
            [label_score setString:[NSString stringWithFormat:@"Score: %i",tmp_player_score]];
            [label_subscore setString:[NSString stringWithFormat:@"COLLECTED BONUS: %i", tmp_score_increment]];
        }
        else
		{
            tmp_score_increment --;
            tmp_player_score ++;
            [label_score setString:[NSString stringWithFormat:@"Score: %i",tmp_player_score]];
            [label_subscore setString:[NSString stringWithFormat:@"TIME BONUS: %i", tmp_score_increment]];
        }
    }
    else
    {
        [self unschedule: @selector(tick2)];
        
        if (totalscore > [self.tmp_game.user getHighscoreforWorld:self.tmp_game.world level:self.tmp_game.level])
        {
            [self showHighscorePanel];
        }
        
        if ( self.tmp_game.player.collected > 0 )  [label_subscore runAction:[CCFadeOut actionWithDuration:1.0f]];
        [menu runAction:[CCFadeIn actionWithDuration:1.5f]];
    }
}

- (void) showHighscorePanel
{
    CCSprite *highscoreSprite = [CCSprite spriteWithFile:@"highscore-image.png"];
    highscoreSprite.position = ccp ( [[CCDirector sharedDirector] winSize].width + 100, [[CCDirector sharedDirector] winSize].height - 400 );
    [self addChild:highscoreSprite];
    [highscoreSprite runAction:[CCMoveTo actionWithDuration:2.0f position:ccp([[CCDirector sharedDirector] winSize].width - 100, highscoreSprite.position.y)]];
    
    CCMenu *tweet_menu = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-highscore-tweet.png" selectedImage:@"btn-highscore-tweet.png" block:^(id sender) {
        // tweet stuff
    }], nil];
    [tweet_menu setPosition:ccp( 80, -80 )];
    [self addChild:tweet_menu];

    [tweet_menu runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0f], [CCMoveTo actionWithDuration:0.5 position:ccp(tweet_menu.position.x, 80)], nil]];
}

@end
