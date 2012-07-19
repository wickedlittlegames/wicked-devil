//
//  Game.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 19/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Player.h"
#import "User.h"

@interface Game : NSObject {}

@property (nonatomic, assign) int world, level;
@property (nonatomic, assign) float threshold;
@property (nonatomic, assign) bool isGameover, didWin, isStarted, isIntro;
@property (nonatomic, retain) Player *player;
@property (nonatomic, retain) User *user;
@end
