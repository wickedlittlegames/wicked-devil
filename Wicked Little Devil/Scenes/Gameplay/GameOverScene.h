//
//  GameOverScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 13/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import <Parse/Parse.h>

@class LevelSelectScene, GameScene, Game, AppController, GameOverFacebookScene;
@interface GameOverScene : CCLayer <PF_FBRequestDelegate>
{
    int souls, souls_score, collected, timebonus, timebonus_score, final_score, next_world, next_level, tmp_score_increment, tmp_score;

    CCLabelTTF *label_score, *label_subscore;
    CCMenu *menu;
}

@property (nonatomic, assign) Game *tmp_game;
@property (nonatomic, assign) BOOL runningAnims, moved;

+(CCScene *) sceneWithGame:(Game*)game;
- (id) initWithGame:(Game*)game;

@end
