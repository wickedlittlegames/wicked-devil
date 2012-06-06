//
//  Enemy.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 30/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "Player.h"

@interface Enemy : CCSprite {}

@property (nonatomic,assign) bool active;
@property (nonatomic,retain) NSString *type;
@property (nonatomic,assign) float speed_x, speed_y, health, damage;

- (void) movementWithThreshold:(float)levelThreshold;
- (void) activateNearPlayerPoint:(Player*)player;
- (BOOL) isIntersectingPlayer:(Player*)player;
- (BOOL) isAlive;

@end
