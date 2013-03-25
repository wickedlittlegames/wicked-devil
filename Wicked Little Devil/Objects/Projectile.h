//
//  Trigger.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 06/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "CCNode+CoordHelpers.h"

@class Player, Enemy;
@interface Projectile : CCSprite {}
- (BOOL) isIntersectingPlayer:(Player*)player;
- (BOOL) isIntersectingParent:(Enemy*)enemy;

@end

@class Player;
@interface EnemyFX : CCParticleSystemQuad {}
- (BOOL) isIntersectingPlayer:(Player*)player;
@end
