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
    
    Player      *player;
    User        *user;
    
    CGPoint location_touch;
    
    CCMenu *menu; // temp
}

@property (nonatomic, assign) int world, level;
@property (nonatomic, assign) float threshold;
@property (nonatomic, assign) bool started, won;

+(CCScene *) sceneWithWorld:(int)w andLevel:(int)l;
+(GameScene *) sharedGameScene;
- (id) initWithWorld:(int)w andLevel:(int)l;
- (void) end;

@end
