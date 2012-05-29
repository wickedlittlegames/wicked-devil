//
//  LevelScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "Player.h"
#import "Platform.h"
#import "Collectable.h"

@interface LevelScene : CCLayer {
    Player *player;
    Platform *floor;
    float levelThreshold;
    CGPoint touchLocation;
    NSMutableArray *platforms, *collectables, *enemies;
    CCLayer *background;
    
    // tidy
    CCMenuItem *launch;
    CCMenu *menu;
}
@property (nonatomic, assign) int level;
@property (nonatomic, assign) NSString *world;
@property (nonatomic, assign) float gravity;
@property (nonatomic, assign) bool started;

+(CCScene *) sceneWithLevelNum:(int)levelNum;
- (id)initWithLevelNum:(int)levelNum;

@end