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
@property (nonatomic, assign) BOOL animating, toggled, active;
@property (nonatomic, retain) CCAction *action_vertical_repeat, *action_horizontal_repeat, *action_fall;

- (void) intersectionCheck:(Player*)player platforms:(CCArray*)platforms;
- (void) setupHVMovement;


@end