//
//  Player.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

@interface Player : CCSprite {}

@property (nonatomic, assign) float health, damage, jumpspeed, gravity, modifier_gravity, drag;
@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, assign) int collected, bigcollected, score, time, jumps, deaths, per_collectable, collectable_multiplier;
@property (nonatomic, retain) id last_platform_touched;
@property (nonatomic, assign) BOOL controllable, toggled_platform, animating, falling, floating;
@property (nonatomic, retain) CCAnimation *anim_jump, *anim_fall, *anim_fallfar, *anim_die;

- (void) jump:(float)speed;
- (void) move;
- (void) animate:(int)animation_id;
- (bool) isAlive;
- (bool) isControllable;
- (void) setupPowerup:(int)powerup;

@end
