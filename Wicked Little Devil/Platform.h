//
//  Platform.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "Player.h"

@interface Platform : CCSprite {}
@property (nonatomic, assign) float health;

- (BOOL) isIntersectingPlayer:(Player*)player;
- (void) movementWithThreshold:(float)levelThreshold;

@end


