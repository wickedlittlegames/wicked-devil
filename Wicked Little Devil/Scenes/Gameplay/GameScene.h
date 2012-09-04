//
//  GameScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "CCBReader.h"
#import "GameOverScene.h"

#import "User.h"
#import "Game.h"
#import "BGLayer.h"
#import "FXLayer.h"
#import "PlayerLayer.h"
#import "UILayer.h"
#import "GameLayer.h"

@interface GameScene : CCLayer 
{
    BGLayer     *layer_bg;
    FXLayer     *layer_fx;
    PlayerLayer *layer_player;
    GameLayer   *layer_game;
    UILayer     *layer_ui;
    CCLayer     *collab;
    
    Game        *game;
    
    CGPoint location_touch;
    CGSize screenSize;
    
    CCMenu *menu; // temp
}

@property (nonatomic, assign) float threshold;

+(CCScene *) sceneWithWorld:(int)w andLevel:(int)l;
- (id) initWithWorld:(int)w andLevel:(int)l;

@end
