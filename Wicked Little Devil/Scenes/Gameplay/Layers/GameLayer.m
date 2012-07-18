//
//  GameLayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "GameLayer.h"
#import "GameScene.h"

@implementation GameLayer
@synthesize platforms, collectables, bigcollectables, enemies, triggers;

- (id) init
{
	if( (self=[super init]) ) {
        
    }
	return self;
}

- (void) createWorldWithObjects:(CCArray*)gameObjects
{
    platforms       = [NSMutableArray arrayWithCapacity:100];
    collectables    = [NSMutableArray arrayWithCapacity:100];
    bigcollectables = [NSMutableArray arrayWithCapacity:3];
    enemies         = [NSMutableArray arrayWithCapacity:100];
    triggers        = [NSMutableArray arrayWithCapacity:100];
    
    for (CCNode* node in self.children)
    {
        if ([node isKindOfClass: [Platform class]])
        {
            node.tag = 0;
            [platforms addObject:node];
        }
        if ([node isKindOfClass: [Collectable class]])
        {
            [collectables addObject:node];
        }
        if ([node isKindOfClass: [BigCollectable class]])
        {
            [bigcollectables addObject:node];
        }
        if ([node isKindOfClass: [Enemy class]])
        {
            [enemies addObject:node];
        }
        if ([node isKindOfClass: [Trigger class]])
        {
            [triggers addObject:node];
        }
    }
}

- (void) update:(Player*)player threshold:(float)levelThreshold
{       
    for (Platform *platform in platforms)
    {       
        if ([platform worldBoundingBox].origin.y < -20 )
        {
            platform.visible = NO; platform.active = NO;
        }
        [platform intersectionCheck:player];
    }
    
    for (Collectable *collectable in collectables)
    {
        if ( [collectable isIntersectingPlayer:player] ) 
        {
            player.collected++;
            player.score++;
        }
    }
    
    for (BigCollectable *bigcollectable in bigcollectables)
    {
        if ( [bigcollectable isIntersectingPlayer:player] )
        {
            player.bigcollected++;
            player.score += 500;
        }
    }
    
    for (Trigger *trigger in triggers)
    {
        if ( [trigger isIntersectingPlayer:player] )
        {
            switch (trigger.tag)
            {
                default:
                    [[GameScene sharedGameScene] end];
                    break;
            }
        }
    }
    
    //if ( levelThreshold < 0 ) self.position = ccp (self.position.x, self.position.y + levelThreshold);
}

@end