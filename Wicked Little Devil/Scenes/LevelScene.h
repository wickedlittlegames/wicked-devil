//
//  LevelScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "CCBReader.h"
#import "cocos2d.h"
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
    CCArray *gameObjectsArray;
    CCLayer *gameObjectsLayer;
    CCLayer *background;
    CCLabelTTF *lbl_collected, *lbl_time, *lbl_player_health;
    
    // tidy
    CCMenuItem *launch;
    CCMenu *menu;
}

@property (nonatomic, assign) bool started;
@property (nonatomic, retain) Player *player;
@property (nonatomic, assign) int worldNumber, levelNumber, levelTimer;
@property (nonatomic, assign) CGPoint touchLocation;
@property (nonatomic, assign) UILayer *ui;

+(CCScene *) sceneWithWorldNum:(int)worldNum LevelNum:(int)levelNum;

@end