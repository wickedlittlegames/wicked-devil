//
//  GameLayer.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

#import "User.h"
#import "Player.h"
#import "Platform.h"
#import "Collectable.h"
#import "Enemy.h"
#import "Trigger.h"
#import "Game.h"

@interface GameLayer : CCLayer {}
@property (nonatomic, retain) CCArray *platforms, *collectables, *bigcollectables, *enemies, *triggers, *emitters;
@property (nonatomic, assign) int world, level;

- (void) createWorldWithObjects:(CCArray*)gameObjects;

- (void) update:(Game *)game;
- (void) gameoverCheck:(Game*)game;
- (void) end:(Game*)game;

@end
