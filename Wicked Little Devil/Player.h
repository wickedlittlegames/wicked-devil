//
//  Player.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

@interface Player : CCSprite {}

@property (nonatomic, assign) float health;
@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, retain) NSUserDefaults *stats;

- (BOOL) isAlive;

@end
