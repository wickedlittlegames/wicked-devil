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

#import "User.h"
#import "Player.h"
#import "Platform.h"
#import "Collectable.h"
#import "Enemy.h"
#import "Trigger.h"

@interface LevelScene : CCLayer {
    User *user;
    Platform *floor;
    float levelThreshold;
    NSMutableArray *platforms, *collectables, *bigcollectables, *enemies, *triggers;
    
    // tidy
    CCMenuItem *launch;
    CCMenu *menu;
}

@property (nonatomic, assign) bool started, complete;
@property (nonatomic, retain) Player *player;
@property (nonatomic, assign) int worldNumber, levelNumber, timeLimit;
@property (nonatomic, assign) CGPoint touchLocation;
@property (nonatomic, assign) GameplayUILayer *ui;

+(CCScene *) sceneWithWorldNum:(int)worldNum LevelNum:(int)levelNum;
- (void) tap_nextlevel:(id)sender;
- (void) tap_restart:(id)sender;
- (void) tap_mainmenu:(id)sender;

@end