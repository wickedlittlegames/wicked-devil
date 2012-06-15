//
//  GameplayUILayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 14/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "GameplayUILayer.h"
#import "LevelScene.h"


@implementation GameplayUILayer
@synthesize lbl_player_health, lbl_gametime, lbl_collected, lbl_gameover, lbl_gameover_bigcollected, lbl_gameover_collected, lbl_gameover_score, lbl_gameover_highscore, lbl_gameover_timebonus, menu_gameover;

-(id) init
{
	if( (self=[super init]) ) {
        
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
        NSString *font = @"Arial";
        int fontsize = 18;
        
        lbl_collected = [CCLabelTTF labelWithString:@"Collected: " fontName:font fontSize:fontsize];
        lbl_collected.position = ccp (screenSize.width - 100, screenSize.height - 20);
        [self addChild:lbl_collected];
        
        lbl_gametime = [CCLabelTTF labelWithString:@"100" fontName:font fontSize:fontsize];
        lbl_gametime.position = ccp ( 20, screenSize.height - 20);
        [self addChild:lbl_gametime];
        
        lbl_gameover = [CCLabelTTF labelWithString:@"GAME OVER" fontName:font fontSize:fontsize];
        lbl_gameover.position = ccp ( screenSize.width/2, screenSize.height/2);
        [self addChild:lbl_gameover];
        lbl_gameover.visible = FALSE;
        
        lbl_gameover_bigcollected = [CCLabelTTF labelWithString:@"BIG COLLECTED: " fontName:font fontSize:fontsize];
        lbl_gameover_bigcollected.position = ccp ( lbl_gameover.position.x, lbl_gameover.position.y + 30);
        [self addChild:lbl_gameover_bigcollected];
        lbl_gameover_bigcollected.visible = FALSE;
        
        lbl_gameover_collected = [CCLabelTTF labelWithString:@"COLLECTED: " fontName:font fontSize:fontsize];
        lbl_gameover_collected.position = ccp ( lbl_gameover_bigcollected.position.x, lbl_gameover_bigcollected.position.y + 30);
        [self addChild:lbl_gameover_collected];
        lbl_gameover_collected.visible = FALSE;
        
        lbl_gameover_timebonus = [CCLabelTTF labelWithString:@"TIME BONUS: " fontName:font fontSize:fontsize];
        lbl_gameover_timebonus.position = ccp ( lbl_gameover.position.x, lbl_gameover.position.y - 30);
        [self addChild:lbl_gameover_timebonus];
        lbl_gameover_timebonus.visible = FALSE;
        
        lbl_gameover_score = [CCLabelTTF labelWithString:@"SCORE: " fontName:font fontSize:fontsize];
        lbl_gameover_score.position = ccp ( lbl_gameover_timebonus.position.x, lbl_gameover_timebonus.position.y - 30);
        [self addChild:lbl_gameover_score];
        lbl_gameover_score.visible = FALSE;
        
        lbl_gameover_highscore = [CCLabelTTF labelWithString:@"CURRENT HIGH SCORE: " fontName:font fontSize:fontsize];
        lbl_gameover_highscore.position = ccp ( lbl_gameover_score.position.x, lbl_gameover_score.position.y - 30);
        [self addChild:lbl_gameover_highscore];
        lbl_gameover_highscore.visible = FALSE;
    }
	return self;    
}

@end
