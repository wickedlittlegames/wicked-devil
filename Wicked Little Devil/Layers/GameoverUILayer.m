//
//  GameoverUILayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 18/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "GameoverUILayer.h"
#import "LevelSelectScene.h"

@implementation GameoverUILayer {}
@synthesize lbl_gameover, lbl_gameover_bigcollected, lbl_gameover_collected, lbl_gameover_score, lbl_gameover_highscore, lbl_gameover_timebonus;

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
        
        lbl_gameover_timebonus = [CCLabelTTF labelWithString:@"TIME BONUS: xxsecs left" fontName:font fontSize:fontsize];
        lbl_gameover_timebonus.position = ccp ( lbl_gameover.position.x, lbl_gameover.position.y - 90);
        [self addChild:lbl_gameover_timebonus];
        
        lbl_gameover_score = [CCLabelTTF labelWithString:@"TOTAL SCORE: xx" fontName:font fontSize:fontsize];
        lbl_gameover_score.position = ccp ( lbl_gameover.position.x, lbl_gameover.position.y - 120);
        [self addChild:lbl_gameover_score];
        
        lbl_gameover_highscore = [CCLabelTTF labelWithString:@"HIGH SCORE: xx" fontName:font fontSize:fontsize];
        lbl_gameover_highscore.position = ccp ( lbl_gameover.position.x, lbl_gameover.position.y - 150);
        [self addChild:lbl_gameover_highscore];
        
        CCMenuItem *next = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"NEXT" fontName:@"Marker Felt" fontSize:20] target:self selector:@selector(tap_next:)];
        CCMenuItem *restart = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"RESTART" fontName:@"Marker Felt" fontSize:20] target:self selector:@selector(tap_restart:)];
        CCMenuItem *mainmenu = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"BACK" fontName:@"Marker Felt" fontSize:20] target:self selector:@selector(tap_mainmenu:)];
        
        CCMenu *menu_gameover = [CCMenu menuWithItems:next, restart, mainmenu, nil];
        [menu_gameover alignItemsVerticallyWithPadding:20];
        menu_gameover.position = ccp ( screenSize.width/2, 400 );
        [self addChild:menu_gameover];
    }
	return self;    
}

- (void) tap_next:(id)sender
{
    [self removeAllChildrenWithCleanup:YES];
}


- (void) tap_restart:(id)sender
{
    
}

- (void) tap_mainmenu:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene]];    
}

@end
