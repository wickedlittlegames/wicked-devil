//
//  Platform.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "CCNode+CoordHelpers.h"

#import "Player.h"

@interface Platform : CCSprite {}
@property (nonatomic, assign) float health;
@property (nonatomic, assign) NSString *type;
@property (nonatomic, assign) BOOL animating, active, flipped;
@property (nonatomic, assign) CGPoint original_position;

- (void) intersectionCheck:(Player*)player;
- (void) setupHVMovement;


@end