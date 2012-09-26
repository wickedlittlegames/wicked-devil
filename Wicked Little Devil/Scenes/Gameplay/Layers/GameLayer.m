//
//  GameLayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "GameLayer.h"
#import "GameOverScene.h"
#import "GameScene.h"

#import "Game.h"

@implementation GameLayer
@synthesize platforms, collectables, bigcollectables, enemies, triggers, emitters,  world, level;

- (id) init
{
	if( (self=[super init]) ) {}
	return self;
}

- (void) createWorldWithObjects:(CCArray*)gameObjects
{
    platforms       = [CCArray arrayWithCapacity:100];
    collectables    = [CCArray arrayWithCapacity:100];
    bigcollectables = [CCArray arrayWithCapacity:3];
    enemies         = [CCArray arrayWithCapacity:100];
    triggers        = [CCArray arrayWithCapacity:100];
    emitters        = [CCArray arrayWithCapacity:100];
    
    for (CCNode* node in self.children)
    {
        [node setPosition:ccp(node.position.x/2, node.position.y)];
        
        if ([node isKindOfClass: [Platform class]])
        {
            [platforms addObject:node];
            if ( node.tag == 52 ) node.visible = NO;
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
    [self gameoverCheck:game];
    
    Platform *platform = nil;
    Collectable *collectable = nil;
    BigCollectable *bigcollectable = nil;
    Trigger *trigger = nil;
    Enemy *enemy = nil;
    Projectile *projectile = nil;
    EnemyFX *fx = nil;
    
    CCARRAY_FOREACH(platforms, platform)
    {           
        if ([platform worldBoundingBox].origin.y < -80 && !game.isIntro)
        {
            platform.visible = NO;
            [platforms removeObject:platform];
            [platform removeFromParentAndCleanup:YES];
        }

        if ( game.player.controllable ) [platform isIntersectingPlayer:game platforms:platforms];
        [platform move];
    }
    
    CCARRAY_FOREACH(collectables, collectable)
    {
        if ( [collectable isIntersectingPlayer:game.player] )
        {
            game.player.collected++;
            game.player.score++;
        }
    }
    
    CCARRAY_FOREACH(bigcollectables, bigcollectable)
    {
        if ( [bigcollectable isIntersectingPlayer:game.player] )
        {
            game.player.bigcollected++;
            game.player.score += 500;
            // do effect of collecting AND going to the top left
            //[game.fx start:1 position:[bigcollectable worldBoundingBox].origin];
            //[game.fx start:2 position:[bigcollectable worldBoundingBox].origin];
        }
    }
    
    CCARRAY_FOREACH(triggers, trigger)
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
    
    CCARRAY_FOREACH(enemies, enemy)
    {
        if ( self.level == 2 )             enemy.tag = 1;
        if ( self.level == 3 )             enemy.tag = 2;
        if ( self.level == 4 )             enemy.tag = 3;
        if ( self.level == 5 )             enemy.tag = 4; enemy.opacity = 0;
        if ( self.level == 6 )             enemy.tag = 5;
        if ( self.level == 7 )             enemy.tag = 6;

        if ( !enemy.animating ) [enemy setupAnimations];
        if ([enemy worldBoundingBox].origin.y < -80 && enemy.visible && !game.isIntro )
        {
            enemy.visible = NO;
        }
        
        [enemy isIntersectingPlayer:game];
        [enemy move];
        
        // Projectile movement
        if ( enemy.visible && enemy.projectiles.count >= 1 )
        {
            CCARRAY_FOREACH(enemy.projectiles, projectile)
            {
                if ( [projectile isIntersectingPlayer:game.player] )
                {
                    [game.fx start:1 position:[projectile worldBoundingBox].origin];
                    projectile.visible = NO;
                    [enemy removeChildByTag:1111 cleanup:YES];
                    game.player.health--;
                }
            }   
        }
        
        // FX check
        if ( !enemy.visible && enemy.fx.count >= 1 )
        {
            CCARRAY_FOREACH(enemy.fx, fx)
            {
                if ( [fx isIntersectingPlayer:game.player] )
                {
                    game.player.health--;
                }
            }
        }
    }
}

- (void) gameoverCheck:(Game*)game
{
    if ( !game.isGameover )
    {   
        game.isGameover = ( game.player.isAlive ? FALSE : TRUE );
        
        if ( game.player.isAlive )
        {
            game.isGameover = ( game.player.position.y < -80 ? TRUE : FALSE);
        }
        
        if ( game.isGameover ) 
        {
            if ( !game.player.isAlive )
            {
                [game.player animate:4];
            }
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
        
        id delay = [CCDelayTime actionWithDuration:1.0];
        
        CCAction *endfunc = [CCCallFunc actionWithTarget:self selector:@selector(gotogameover)];
        
        [self runAction:[CCSequence actions:delay, endfunc, nil]];
    }
}

- (void) gotogameover
{
    [[CCDirector sharedDirector] replaceScene:[GameScene sceneWithWorld:self.world andLevel:self.level isRestart:TRUE]];
}

@end