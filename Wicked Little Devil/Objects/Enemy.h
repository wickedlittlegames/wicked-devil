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

@property (nonatomic,assign) bool active, attacking, animating;
@property (nonatomic,retain) NSString *type;
@property (nonatomic,assign) float speed_x, speed_y, health, damage, base_y;
@property (nonatomic, retain) CCAnimation *batFlap;

- (void) isIntersectingPlayer:(Game*)game;
- (void) doMovement;

@end
