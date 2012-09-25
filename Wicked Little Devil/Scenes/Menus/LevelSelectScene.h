//
//  LevelSelectScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

@class WorldSelectScene, ShopScene, GameScene, User;
@interface LevelSelectScene : CCLayer {}

+(CCScene *) sceneWithWorld:(int)world;
- (id) initWithWorld:(int)world;

@end
