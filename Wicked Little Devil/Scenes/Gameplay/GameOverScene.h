//
//  GameOverScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 13/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

@class LevelSelectScene, GameScene, Game;
@interface GameOverScene : CCLayer
{
    int timebonus, totalscore, tmp_player_score, tmp_score_increment, collectedbonus, basicscore;
    CCLabelTTF *label_score, *label_subscore;
    CCMenu *menu;
}

@property (nonatomic, assign) Game *tmp_game;

+(CCScene *) sceneWithGame:(Game*)game;
- (id) initWithGame:(Game*)game;

@end
