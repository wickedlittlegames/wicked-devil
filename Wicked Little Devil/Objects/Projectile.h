//
//  Trigger.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 06/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "CCNode+CoordHelpers.h"

@class Player;
@interface Projectile : CCSprite {}
- (BOOL) isIntersectingPlayer:(Player*)player;

@end

@class Player;
@interface EnemyFX : CCParticleSystemQuad {}
- (BOOL) isIntersectingPlayer:(Player*)player;
@end
