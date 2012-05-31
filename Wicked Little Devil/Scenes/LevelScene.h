//
//  LevelScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "CCBReader.h"
#import "cocos2d.h"
#import "Player.h"
#import "Platform.h"
#import "Collectable.h"
#import "Enemy.h"

@interface LevelScene : CCLayer {
    Player *player;
    Platform *floor;
    float levelThreshold;
    CGPoint touchLocation;
    NSMutableArray *platforms, *collectables, *bigcollectables, *enemies;
    CCArray *gameObjectsArray;
    CCLayer *gameObjectsLayer;
    CCLayer *background;
    
    // tidy
    CCMenuItem *launch;
    CCMenu *menu;
}

@property (nonatomic, assign) bool started;

+(CCScene *) sceneWithWorldNum:(int)worldNum LevelNum:(int)levelNum;

@end