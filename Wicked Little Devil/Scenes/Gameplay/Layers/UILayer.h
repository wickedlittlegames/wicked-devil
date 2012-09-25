//
//  UILayer.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

@class Game, GameScene;
@interface UILayer : CCLayer 
{
    CCMenu *pause_screen;
    CCSprite *pause_bg;
    CCSprite *bigcollect_empty, *bigcollect;
}

@property (nonatomic, assign) int world, level;

- (void) setupItemsforGame:(Game*)game;
- (void) update:(Game*)game;

@end
