//
//  Platform.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "CCNode+CoordHelpers.h"

@class Game;
@interface Platform : CCSprite {}

@property (nonatomic, assign) float health;
@property (nonatomic, assign) BOOL animating, toggled, end_fx_added;

- (void) isIntersectingPlayer:(Game*)game platforms:(CCArray*)platforms;
- (void) move;
- (void) action:(int)action_id game:(Game*)game platforms:(CCArray*)platforms;

@end