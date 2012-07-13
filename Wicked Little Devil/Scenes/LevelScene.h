//
//  LevelScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "CCBReader.h"
#import "LevelSelectScene.h"
#import "GameplayUILayer.h"
#import "GameoverUILayer.h"

#import "User.h"
#import "Player.h"
#import "Platform.h"
#import "Collectable.h"
#import "Enemy.h"
#import "Trigger.h"

@interface LevelScene : CCLayer {
    CCSprite *floor;
    float levelThreshold;
    NSMutableArray *platforms, *collectables, *bigcollectables, *enemies, *triggers;
    
    // tidy
    CCMenuItem *launch;
    CCMenu *menu;
}

@property (nonatomic, assign) bool started, complete;
@property (nonatomic, retain) Player *player;
@property (nonatomic, retain) User *user;
@property (nonatomic, assign) int worldNumber, levelNumber;
@property (nonatomic, assign) CGPoint touchLocation;
@property (nonatomic, assign) GameplayUILayer *ui;
@property (nonatomic, assign) GameoverUILayer *gameoverlayer;
@property (nonatomic, assign) CCSprite* background_front, *background_middle, *background_middle2, *background_back;

+(CCScene *) sceneWithWorldNum:(int)worldNum LevelNum:(int)levelNum;
@end