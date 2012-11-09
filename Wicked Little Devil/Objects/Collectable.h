//
//  Collectable.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 29/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "CCNode+CoordHelpers.h"

@class Player;
@interface Collectable : CCSprite {}
@property (nonatomic, assign) bool dead;

- (BOOL) isIntersectingPlayer:(Player*)player;
- (BOOL) isClosetoPlayer:(Player*)player;
- (void) moveTowardsPlayer:(Player*)player;

@end

@class Player;
@interface BigCollectable : CCSprite {} 
@property (nonatomic, assign) bool dead;

- (BOOL) isIntersectingPlayer:(Player*)player;

@end