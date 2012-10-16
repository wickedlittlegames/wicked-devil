//
//  GameLayer.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

@class Game, Platform, Collectable, BigCollectable, Enemy, Tip, Trigger, Projectile, EnemyFX;
@interface GameLayer : CCLayer
{
    Platform *platform;
    Collectable *collectable;
    BigCollectable *bigcollectable;
    Enemy *enemy;
    Projectile *projectile;
    EnemyFX *fx;
    Tip *tip;

}
@property (nonatomic, retain) CCArray *platforms, *collectables, *bigcollectables, *enemies, *triggers, *emitters, *tips;
@property (nonatomic, assign) int world, level;

- (void) createWorldWithObjects:(CCArray*)gameObjects;

- (void) update:(Game *)game;
- (void) gameoverCheck:(Game*)game;
- (void) end:(Game*)game;

@end
