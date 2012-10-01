//
//  GameScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

@class User, Game, BGLayer, FXLayer, PlayerLayer, UILayer, GameLayer, GameOverScene;
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
    CCMotionStreak *streak;
}

@property (nonatomic, assign) float threshold;

+(CCScene *) sceneWithWorld:(int)w andLevel:(int)l isRestart:(BOOL)restart restartMusic:(BOOL)restartMusic;
- (id) initWithWorld:(int)w andLevel:(int)l withRestart:(BOOL)restart restartMusic:(BOOL)restartMusic;

@end
