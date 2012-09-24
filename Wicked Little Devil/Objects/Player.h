//
//  Player.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

@interface Player : CCSprite {}

@property (nonatomic, assign) float health, damage, jumpspeed, modifier_gravity;
@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, retain) NSUserDefaults *stats;
@property (nonatomic, assign) int collected, bigcollected, score;
@property (nonatomic, retain) id last_platform_touched;
@property (nonatomic, assign) BOOL controllable, toggled_platform, animating, falling;
@property (nonatomic, retain) CCAnimation *jumpAction, *fallAction, *fallFarAction, *explodeAction;

- (BOOL) isAlive;
- (void) dieAnimation;
- (void) jump:(float)speed;
- (void) movementwithGravity:(float)gravity;
- (void) setupPowerup:(int)powerup;
- (void) animationRunner:(int)which;

@end
