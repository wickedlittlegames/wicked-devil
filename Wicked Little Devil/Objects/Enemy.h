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
@interface Enemy : CCSprite {
    CCRenderTexture *_rt;
}

@property (nonatomic, assign) bool animating, running, dead, floating;
@property (nonatomic, retain) CCAnimation *anim_flap;
@property (nonatomic, retain) CCArray *projectiles, *fx;

- (void) isIntersectingPlayer:(Game*)game;
- (void) isIntersectingTouch:(Game*)game;
- (void) move;
- (void) action:(int)action_id game:(Game*)game;
- (void) setupAnimations;

@end
