//
//  GameOverScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 13/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "User.h"
#import "LevelSelectScene.h"
#import "LevelScene.h"

@interface GameOverScene : CCLayer {
    User *user;
}
@property (nonatomic, assign) int score, timebonus, bigs, world, level;

+(CCScene *) sceneWithScore:(int)_score timebonus:(int)_timebonus bigs:(int)_bigs forWorld:(int)_world andLevel:(int)_level;

@end
