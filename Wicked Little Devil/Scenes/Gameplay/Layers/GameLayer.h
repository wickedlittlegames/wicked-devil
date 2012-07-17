//
//  GameLayer.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

#import "Player.h"
#import "Platform.h"
#import "Collectable.h"
#import "Enemy.h"
#import "Trigger.h"

@interface GameLayer : CCLayer 
{

}
@property (nonatomic, retain) NSMutableArray *platforms, *collectables, *bigcollectables, *enemies, *triggers;

- (void) createWorldWithObjects:(CCArray*)gameObjects;
- (void) update:(Player*)player threshold:(float)levelThreshold;

@end
