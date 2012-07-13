//
//  Trigger.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 06/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

#import "Player.h"

@interface Trigger : CCSprite {}

@property (nonatomic, assign) bool isEffectActive;

- (BOOL) isIntersectingPlayer:(Player*)player;
- (void) toggleEffect;
- (void) damageToPlayer:(Player*)player;

@end
