//
//  LevelSelectScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "cocos2d.h"
#import "GameCenterConstants.h"

#import "ShopScene.h"
#import "GameScene.h"

#import "User.h"

@class WorldSelectScene;
@interface LevelSelectScene : CCLayer
{
    User *user;
    CCLabelTTF *lbl_user_collected;
}

+(CCScene *) sceneWithWorld:(int)world;
- (id) initWithWorld:(int)world;

@end
