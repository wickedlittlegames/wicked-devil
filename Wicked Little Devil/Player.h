//
//  Player.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

@interface Player : CCSprite {}

@property (nonatomic, assign) float health, damage;
@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, retain) NSUserDefaults *stats;
@property (nonatomic, assign) int collected;

- (BOOL) isAlive;
- (void) bounce;
- (void) halt;
- (void) update:(float)threshhold withGravity:(float)gravity;

@end
