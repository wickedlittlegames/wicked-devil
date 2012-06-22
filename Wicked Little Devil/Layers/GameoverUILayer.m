//
//  GameoverUILayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 18/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "GameoverUILayer.h"
#import "LevelSelectScene.h"
#import "LevelScene.h"

@implementation GameoverUILayer {}
@synthesize lbl_gameover, lbl_gameover_bigcollected, lbl_gameover_collected, lbl_gameover_score;
@synthesize menu_failed, menu_success, world, level, next_world, next_level, score;
-(id) init
{
	if( (self=[super init]) ) {
        
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
        NSString *font = @"Arial";
        int fontsize = 18;
                
        CCSprite *background = [CCSprite spriteWithFile:@"slide-in.png"];
        background.position = ccp (screenSize.width/2, screenSize.height/2);
        [self addChild:background];

        lbl_gameover = [CCLabelTTF labelWithString:@"GAME OVER" fontName:font fontSize:fontsize];
        lbl_gameover.position = ccp ( screenSize.width/2, screenSize.height/2);
        [self addChild:lbl_gameover];
        
        lbl_gameover_bigcollected = [CCLabelTTF labelWithString:@"BIG COLLECTED: xx" fontName:font fontSize:fontsize];
        lbl_gameover_bigcollected.position = ccp ( lbl_gameover.position.x, lbl_gameover.position.y - 30);
        [self addChild:lbl_gameover_bigcollected];
        
        lbl_gameover_collected = [CCLabelTTF labelWithString:@"COLLECTED: xx" fontName:font fontSize:fontsize];
        lbl_gameover_collected.position = ccp ( lbl_gameover.position.x, lbl_gameover.position.y - 60);
        [self addChild:lbl_gameover_collected];
        
        lbl_gameover_score = [CCLabelTTF labelWithString:@"TOTAL SCORE: xx" fontName:font fontSize:fontsize];
        lbl_gameover_score.position = ccp ( lbl_gameover.position.x, lbl_gameover.position.y - 120);
        [self addChild:lbl_gameover_score];
        
        CCMenuItem *next = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"NEXT" fontName:@"Marker Felt" fontSize:20] target:self selector:@selector(tap_next:)];
        CCMenuItem *restart = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"RESTART" fontName:@"Marker Felt" fontSize:20] target:self selector:@selector(tap_restart:)];
        CCMenuItem *mainmenu = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"BACK" fontName:@"Marker Felt" fontSize:20] target:self selector:@selector(tap_mainmenu:)];
        
        CCMenuItem *fail_restart = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"RESTART" fontName:@"Marker Felt" fontSize:20] target:self selector:@selector(tap_restart:)];
        CCMenuItem *fail_mainmenu = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"BACK" fontName:@"Marker Felt" fontSize:20] target:self selector:@selector(tap_mainmenu:)];
                
        menu_success = [CCMenu menuWithItems:next, restart, mainmenu, nil];
        [menu_success alignItemsVerticallyWithPadding:20];
        menu_success.position = ccp ( screenSize.width/2, 300 );
        menu_success.opacity = 0.0; 
        [self addChild:menu_success];

        menu_failed = [CCMenu menuWithItems:fail_restart, fail_mainmenu, nil];
        [menu_failed alignItemsVerticallyWithPadding:20];
        menu_failed.position = ccp ( screenSize.width/2, 400 );
        menu_failed.visible = FALSE;
        [self addChild:menu_failed];
    }
	return self;    
}

- (void) doFinalScoreAnimationsforUser:(User*)user andPlayer:(Player*)player
{
    [lbl_gameover_collected setString:[NSString stringWithFormat:@"Collected: %i",player.collected]];
    [lbl_gameover_score setString:@"Score: 0"];
    
    tmp_player_score = 0;
    score_multiplier_check = 1;
    tmp_player_bigcollected = player.bigcollected;
    
    tmp_score_increment = player.score;
    NSLog(@"WORLD: %i, LEVEL: %i", world, level);
    tmp_user_highscore = [user getScoreForWorld:world andLevel:level];

    lbl_gameover_score.scale = 1.0;
    [self schedule: @selector(tick_score) interval: 1.0f/60.0f];
}

- (void)tick_score
{
    if ( tmp_score_increment > 0 )
    {
        if (tmp_score_increment > 100)
		{
            tmp_score_increment -= 50;
            tmp_player_score += 50;
            [lbl_gameover_score setString:[NSString stringWithFormat:@"Score: %i",tmp_player_score]];
        }
        if (tmp_score_increment > 10)
		{
            tmp_score_increment -= 10;
            tmp_player_score += 10;
            [lbl_gameover_score setString:[NSString stringWithFormat:@"Score: %i",tmp_player_score]];
        }
        else
		{
            tmp_score_increment --;
            tmp_player_score ++;
            [lbl_gameover_score setString:[NSString stringWithFormat:@"Score: %i",tmp_player_score]];
        }
    }
    else 
    {
        lbl_gameover_score.scale = 1.0;
        [self unschedule: @selector(tick_score)];
        if ( tmp_player_bigcollected > 0 )
        {
            CGSize screenSize = [[CCDirector sharedDirector] winSize];            
            
            int padding = 80;
            for ( int i = 0; i < tmp_player_bigcollected; i++)
            {
                CCSprite *bigcollected = [CCSprite spriteWithFile:@"bigcollectable.png"];
                bigcollected.position = ccp ( screenSize.width/2 - 100 + padding*i, 430);
                bigcollected.scale = 0.01;
                [self addChild:bigcollected];
                
                id showBigCollected = [CCScaleTo actionWithDuration:0.1 scale:1.0];
                id delay = [CCDelayTime actionWithDuration:0.5*i];
                id delay_set = [CCDelayTime actionWithDuration:1];
                id updateScore = [CCCallFunc actionWithTarget:self selector:@selector(updateScoreWithMultiplier)];
                id showFinalScore = [CCCallFunc actionWithTarget:self selector:@selector(showFinalScore)];
                if ( i == tmp_player_bigcollected - 1)
                {
                [bigcollected runAction:[CCSequence actions:delay,showBigCollected,updateScore,delay_set,showFinalScore,nil]];
                }
                else 
                {
                [bigcollected runAction:[CCSequence actions:delay,showBigCollected,updateScore,nil]];    
                }
            }
            
            if (score > tmp_user_highscore) 
            {
                CCLabelTTF *new_highscore = [CCLabelTTF labelWithString:@"NEW HIGHSCORE" fontName:@"Arial" fontSize:18];
                new_highscore.position = ccp ( lbl_gameover_score.position.x + 100, lbl_gameover_score.position.y + 40 );
                [self addChild:new_highscore];
            }
            
            id fade_in_menu = [CCFadeIn actionWithDuration:0.5];
            id delay = [CCDelayTime actionWithDuration:tmp_player_bigcollected*0.5];
            [menu_success runAction:[CCSequence actions:delay, fade_in_menu, nil]];
        }
    }
}

- (void) updateScoreWithMultiplier
{
    if ( score_multiplier_check == 2 )
    {
        [lbl_gameover_score setString:[NSString stringWithFormat:@"Score: %i x2",tmp_player_score*2]];
    }
    if ( score_multiplier_check == 3 )
    {
        [lbl_gameover_score setString:[NSString stringWithFormat:@"Score: %i x3",tmp_player_score*3]];        
    }
    score_multiplier_check++;
}

- (void) showFinalScore
{
    [lbl_gameover_score setString:[NSString stringWithFormat:@"Score: %i",score]];        
}

- (void) tap_next:(id)sender
{
    [self removeAllChildrenWithCleanup:YES];
    NSLog(@"%i %i",next_world, next_level);
    [[CCDirector sharedDirector] replaceScene:[LevelScene sceneWithWorldNum:next_world LevelNum:next_level]];    
}


- (void) tap_restart:(id)sender
{
    [self removeAllChildrenWithCleanup:YES];
    [[CCDirector sharedDirector] replaceScene:[LevelScene sceneWithWorldNum:world LevelNum:level]];
}

- (void) tap_mainmenu:(id)sender
{
    [self removeAllChildrenWithCleanup:YES];
    [[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene]];    
}

@end
