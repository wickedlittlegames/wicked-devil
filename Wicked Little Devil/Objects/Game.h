//
//  Game.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 19/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

@class FXLayer, Player, User;
@interface Game : NSObject {}

@property (nonatomic, assign) int world, level;
@property (nonatomic, assign) bool isGameover, didWin, isStarted, isIntro;
@property (nonatomic, retain) Player *player;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) FXLayer *fx;
@end
