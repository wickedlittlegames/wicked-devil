//
//  GameLayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "GameLayer.h"
#import "GameOverScene.h"

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
            [platforms addObject:node];
        }
        if ([node isKindOfClass: [CCNode class]])
        {
            for (Collectable *collectable in node.children)
            {
                [collectables addObject:collectable];
            }
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

- (void) update:(Game *)game
{       
    for (Platform *platform in platforms)
    {       
        if ([platform worldBoundingBox].origin.y < -80 && platform.active && !game.isIntro)
        {
            platform.visible = NO;
            platform.active = NO;
        }

        if ( game.player.controllable ) [platform intersectionCheck:game.player platforms:platforms];
        [platform setupHVMovement];
    }
    
    for (Collectable *collectable in collectables)
    {
        if ( [collectable isIntersectingPlayer:game.player] ) 
        {
            game.player.collected++;
            game.player.score++;
        }
    }
    
    for (BigCollectable *bigcollectable in bigcollectables)
    {
        if ( [bigcollectable isIntersectingPlayer:game.player] )
        {
            game.player.bigcollected++;
            game.player.score += 500;
        }
    }
    
    for (Trigger *trigger in triggers)
    {
        if ( [trigger isIntersectingPlayer:game.player] )
        {
            switch (trigger.tag)
            {
                default:
                    game.isGameover = YES;
                    game.didWin = ( game.player.bigcollected >= 1 ? TRUE : FALSE );
                    break;
            }
        }
    }
    for (Enemy *enemy in enemies)
    {
        if ([enemy worldBoundingBox].origin.y < -80 && enemy.active && !game.isIntro )
        {
            enemy.visible = NO;
            enemy.active = NO;
        }
        
        [enemy isIntersectingPlayer:game.player];
        [enemy doMovement];
    }
}

- (void) gameoverCheck:(Game*)game
{
    if ( !game.isGameover )
    {   
        game.isGameover = ( game.player.isAlive ? FALSE : TRUE );
        game.isGameover = ( game.player.position.y < -80 ? TRUE : FALSE);
        
        if ( game.isGameover ) 
        {
            [self end:game];
        }
    }
    else 
    {
        [self end:game];
    }
}

- (void) end:(Game*)game
{
    if (game.didWin)
    {
        game.user.collected += game.player.collected;

        int score = game.player.score * game.player.bigcollected;
        int souls = game.player.bigcollected;
        
        [game.user setHighscore:score world:game.world level:game.level];
        [game.user setSouls:souls world:game.world level:game.level];
        
        if (game.level == game.user.levelprogress)
        {
            game.user.levelprogress = game.user.levelprogress + 1;
            if (game.user.levelprogress > LEVELS_PER_WORLD)
            {
                game.user.worldprogress = game.user.worldprogress + 1;
                game.user.levelprogress = 1;
            }
        }
        [game.user sync];

        [[CCDirector sharedDirector] replaceScene:[GameOverScene 
                                                   sceneWithScore:game.player.score 
                                                   timebonus:100 
                                                   bigs:game.player.bigcollected 
                                                   forWorld:game.world 
                                                   andLevel:game.level]];
    }
    else 
    {
        [[CCDirector sharedDirector] replaceScene:[GameOverScene 
                                                   sceneWithScore:0 
                                                   timebonus:0 
                                                   bigs:0 
                                                   forWorld:game.world 
                                                   andLevel:game.level]];
    }
}

@end