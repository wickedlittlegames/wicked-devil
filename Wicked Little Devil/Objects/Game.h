//
//  Game.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 19/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "User.h"
#import "Player.h"
#import "Platform.h"
#import "Collectable.h"
#import "Enemy.h"
#import "Projectile.h"
#import "Trigger.h"
#import "FXLayer.h"
#import "SimpleAudioEngine.h"

@interface Game : NSObject{}

@property (nonatomic, assign) int world, level, pastScore, timelimit;
@property (nonatomic, assign) bool isGameover, didWin, isStarted, isIntro;
@property (nonatomic, retain) Player *player;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) FXLayer *fx;
@property (nonatomic, assign) CGPoint touch;
@end
