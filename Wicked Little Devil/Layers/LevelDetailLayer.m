//
//  LevelDetailLayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 12/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "LevelDetailLayer.h"
#import "LevelScene.h"


@implementation LevelDetailLayer

- (void) setupDetailsForWorld:(int)world level:(int)level withUserData:(User*)user;
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    self.position = ccp ( screenSize.width*2, 0 );

    // Background for the slide-in
    CCSprite *background = [CCSprite spriteWithFile:@"slide-in.png"];
    [self addChild:background];
    
    // Labels and titles
    int fontsize = 16;
    NSString *font = @"Marker Felt";
    NSString *title_world = [NSString stringWithFormat:@"World %i - Level %i",world, level];
    NSString *title_scores = [NSString stringWithFormat:@"Highscore: %i", [user getHighscoreforWorld:world level:level]];
    NSString *title_bigcollected = @"Souls Captured:";
    NSString *title_facebook = @"Your Facebook Friends";
    NSString *title_compare  = @"Share Options";
    
    CCLabelTTF *label_world = [CCLabelTTF labelWithString:title_world fontName:font fontSize:fontsize];
    CCLabelTTF *label_scores = [CCLabelTTF labelWithString:title_scores fontName:font fontSize:fontsize];
    CCLabelTTF *label_facebook = [CCLabelTTF labelWithString:title_facebook fontName:font fontSize:fontsize];
    CCLabelTTF *label_compare = [CCLabelTTF labelWithString:title_compare fontName:font fontSize:fontsize];
    CCLabelTTF *label_big_collected = [CCLabelTTF labelWithString:title_bigcollected fontName:font fontSize:fontsize];
    
    label_world.position = ccp ( 0, 460 );
    label_scores.position = ccp ( 0, 200 );
    label_big_collected.position = ccp ( 0, 180 );
    label_facebook.position = ccp ( 0, 100 );
    label_compare.position = ccp ( 0, 30 );
    
    for (int i = 0; i < [user getSoulsforWorld:world level:level]; i++)
    {
        CCSprite *bigcollected = [CCSprite spriteWithFile:@"bigcollectable.png"];
        bigcollected.position = ccp ( 0+(80*i), 130);
        [self addChild:bigcollected z:100];        
    }
    
    CCMenuItem *play = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"PLAY" fontName:@"Marker Felt" fontSize:20] target:self selector:@selector(tap_play:)];
    play.tag = level;
    play.userData = (int*)world;
    CCMenuItem *close = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"CLOSE" fontName:@"Marker Felt" fontSize:20] target:self selector:@selector(tap_close:)];
    
    CCMenu *menu = [CCMenu menuWithItems:play,close, nil];
    [menu alignItemsVerticallyWithPadding:20];
    menu.position = ccp ( 0, 400 );
    
    [self addChild:menu];

    [self addChild:label_world];
    [self addChild:label_scores];
    [self addChild:label_facebook];
    [self addChild:label_compare];
    [self addChild:label_big_collected];
    [self slideIn];
}

- (void) slideIn
{
    id moveAction = [CCMoveTo actionWithDuration:0.2 position:ccp(320/2,self.position.y)];
    [self runAction:[CCSequence actions:moveAction,nil]];
}

- (void) slideOut
{
    id moveAction = [CCMoveTo actionWithDuration:0.2 position:ccp(320*2,self.position.y)];
    [self runAction:[CCSequence actions:moveAction,nil]];    
}


- (void) tap_play:(CCMenuItem*)sender
{
    [[CCDirector sharedDirector] replaceScene:[LevelScene sceneWithWorldNum:(int)sender.userData LevelNum:sender.tag]];
}


- (void) tap_close:(id)sender
{
    [self slideOut];
    [self removeAllChildrenWithCleanup:YES];
}

@end
