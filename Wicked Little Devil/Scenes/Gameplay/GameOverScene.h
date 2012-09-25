//
//  GameOverScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 13/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import <Parse/Parse.h>

@class User, LevelSelectScene, GameScene;
@interface GameOverScene : CCLayer <PF_FBRequestDelegate> {
    User *user;
    int total;
    CCLabelTTF *label_score;
    CCLabelTTF *label_score_type;
    NSArray *friendUsers;
    NSMutableArray *friendIds;
}
@property (nonatomic, assign) int score, timebonus, bigs, world, level;

+(CCScene *) sceneWithScore:(int)_score timebonus:(int)_timebonus bigs:(int)_bigs forWorld:(int)_world andLevel:(int)_level;
- (void) do_scores;

@end
