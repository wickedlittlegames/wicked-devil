//
//  LevelDetailLayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 12/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "LevelDetailLayer.h"

@implementation LevelDetailLayer

- (void) setupDetailsForWorld:(int)world level:(int)level withUserData:(User*)user;
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    self.position = ccp ( screenSize.width*2, 0 );

    // Background for the slide-in
    CCSprite *background = [CCSprite spriteWithFile:@"slide-in.png"];
    [self addChild:background];
    
    // Labels and titles
    NSString *font = @"Arial";
    NSString *title_world = [NSString stringWithFormat:@"World %d - Level %d",world, level];
    NSString *title_scores = @"Your Top Score";
    NSString *title_facebook = @"Your Facebook Friends";
    NSString *title_compare  = @"Share Options";
    NSString *text_score = [NSString stringWithFormat:@"%d",user.collected];
    
    CCLabelTTF *label_world = [CCLabelTTF labelWithString:title_world fontName:font fontSize:20];
    CCLabelTTF *label_scores = [CCLabelTTF labelWithString:title_scores fontName:font fontSize:20];
    CCLabelTTF *label_facebook = [CCLabelTTF labelWithString:title_facebook fontName:font fontSize:20];
    CCLabelTTF *label_compare = [CCLabelTTF labelWithString:title_compare fontName:font fontSize:20];
    CCLabelTTF *label_text_score = [CCLabelTTF labelWithString:text_score fontName:font fontSize:20];
    
    label_world.position = ccp ( 0, 460 );
    label_scores.position = ccp ( 0, 200 );
    label_facebook.position = ccp ( 0, 100 );
    label_compare.position = ccp ( 0, 30 );
    label_text_score.position = ccp ( 0, 160 );

    [self addChild:label_world];
    [self addChild:label_scores];
    [self addChild:label_facebook];
    [self addChild:label_compare];
    [self addChild:label_text_score];
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

@end
