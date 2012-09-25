//
//  Enemy.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 30/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "CCNode+CoordHelpers.h"

@class Game;
@interface Enemy : CCSprite {}

// move enemy
// check for intersection
// if intersect, do an action

@property (nonatomic, assign) bool animating, running;
@property (nonatomic, retain) CCAnimation *anim_flap;

- (void) isIntersectingPlayer:(Game*)game;
- (void) move;
- (void) action:(int)action_id game:(Game*)game;

@end
