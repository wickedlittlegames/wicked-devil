//
//  LevelSelectScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "AppDelegate.h"
#import "cocos2d.h"

@class WorldSelectScene, ShopScene, GameScene, User;
@interface LevelSelectScene : CCLayer {
    User *user;
    int tmp_collectables, tmp_collectable_increment;
    CCLabelTTF *label_collected;
    AppController *app;
}

+(CCScene *) sceneWithWorld:(int)world;
- (id) initWithWorld:(int)world;

@end
