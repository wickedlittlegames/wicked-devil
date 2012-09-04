//
//  Enemy.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 30/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "CCNode+CoordHelpers.h"

#import "Player.h"

@interface Enemy : CCSprite 
{
    Enemy *projectile;
    CCSprite *projectile_info;
}

@property (nonatomic,assign) bool active, attacking;
@property (nonatomic,retain) NSString *type;
@property (nonatomic,assign) float speed_x, speed_y, health, damage, base_y;

- (void) isIntersectingPlayer:(Player*)player;
- (void) doMovement;

@end
