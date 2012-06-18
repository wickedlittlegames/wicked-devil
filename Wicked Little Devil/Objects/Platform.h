//
//  Platform.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "CCNode+CoordHelpers.h"

#import "GameObject.h"
#import "Player.h"

@interface Platform : GameObject {}
@property (nonatomic, assign) float health;
@property (nonatomic, assign) NSString *type;
@property (nonatomic, assign) BOOL animating, active;
@property (nonatomic, assign) CGPoint original_position;

- (BOOL) isIntersectingPlayer:(Player*)player;
- (BOOL) isAlive;
- (void) takeDamagefromPlayer:(Player*)player;
- (void) setupHVMovement;
@end


