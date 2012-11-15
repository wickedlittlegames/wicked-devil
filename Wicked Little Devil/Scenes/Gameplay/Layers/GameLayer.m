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
@synthesize platforms, collectables, bigcollectables, enemies, triggers, emitters,  world, level, tips;

- (id) init
{
	if( (self=[super init]) ) {}
	return self;
}

- (void) createWorldWithObjects:(CCArray*)gameObjects
{
    platforms       = [CCArray arrayWithCapacity:100];
    collectables    = [CCArray arrayWithCapacity:500];
    bigcollectables = [CCArray arrayWithCapacity:3];
    enemies         = [CCArray arrayWithCapacity:100];
    triggers        = [CCArray arrayWithCapacity:100];
    emitters        = [CCArray arrayWithCapacity:100];
    tips            = [CCArray arrayWithCapacity:100];
    
    for (CCNode* node in self.children)
    {
        if ([node isKindOfClass: [Platform class]])
        {
            [platforms addObject:node];
            if ( node.tag == 52 ) node.visible = NO;
        }
        if ([node isKindOfClass: [CCNode class]])
        {
            for (Collectable *collectable_tmp in node.children)
            {
                [collectables addObject:collectable_tmp];
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
            node.visible = NO;
        }
        if ([node isKindOfClass: [Tip class]])
        {
            [tips addObject:node];
            node.visible = NO;
        }
    }
    
    CCARRAY_FOREACH(collectables, collectable)
    {
        collectable.visible = ( [collectable worldBoundingBox].origin.y < [[CCDirector sharedDirector] winSize].height && [collectable worldBoundingBox].origin.y > -20 );
    }
    CCARRAY_FOREACH(bigcollectables, bigcollectable)
    {
        bigcollectable.visible = ( [bigcollectable worldBoundingBox].origin.y < [[CCDirector sharedDirector] winSize].height && [bigcollectable worldBoundingBox].origin.y > -20 );
    }
    CCARRAY_FOREACH(platforms, platform)
    {
        platform.visible = ( [platform worldBoundingBox].origin.y < [[CCDirector sharedDirector] winSize].height && [platform worldBoundingBox].origin.y > -20 );
        if ( !platform.animating ) [platform move];
    }
    CCARRAY_FOREACH(enemies, enemy)
    {
        enemy.visible = ( [enemy worldBoundingBox].origin.y < [[CCDirector sharedDirector] winSize].height && [enemy worldBoundingBox].origin.y > -20 );
        if ( !enemy.animating ) [enemy setupAnimations];
    }
}

- (void) update:(Game *)game
{       
    [self gameoverCheck:game];
    
    CCARRAY_FOREACH(platforms, platform)
    {
        if ( !game.isIntro )
        {
            if ([platform worldBoundingBox].origin.y < -80 && !game.user.powerup == 100 )
            {
                platform.visible = NO;
                platform.dead = YES;
                [platforms removeObject:platform];
                [platform removeFromParentAndCleanup:YES];
            }
        }
        
        if ( game.user.powerup == 100 )
        {
            platform.visible = ( !platform.dead && [platform worldBoundingBox].origin.y < [[CCDirector sharedDirector] winSize].height );
        }
        else
        {
            platform.visible = ( [platform worldBoundingBox].origin.y < [[CCDirector sharedDirector] winSize].height && [platform worldBoundingBox].origin.y > -20 && !platform.dead);
        }
        
        if (  platform.visible )
        {
            if ( game.player.controllable )
            {
                [platform isIntersectingPlayer:game platforms:platforms];
            }
        }
    }
    
    CCARRAY_FOREACH(collectables, collectable)
    {
        if ( !game.isIntro )
        {
            if ([collectable worldBoundingBox].origin.y < -80)
            {
                collectable.visible = NO;
                collectable.dead = YES;
                [collectables removeObject:collectable];
                [collectable removeFromParentAndCleanup:YES];
            }
        }
        
        collectable.visible = ( [collectable worldBoundingBox].origin.y < [[CCDirector sharedDirector] winSize].height && [collectable worldBoundingBox].origin.y > -20 && !collectable.dead );
        
        if ( collectable.visible )
        {
            if ( game.user.powerup == 102 )
            {
                if ( [collectable isClosetoPlayer:game.player] )
                {
                    [collectable moveTowardsPlayer:game.player];
                }
            }
            
            if ( [collectable isIntersectingPlayer:game.player] )
            {
                if ( ![SimpleAudioEngine sharedEngine].mute )
                {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"collect-small.caf" pitch:1 pan:1 gain:0.2];
                }
                collectable.visible = FALSE;
                collectable.dead = YES;
                [collectables removeObject:collectable];
                [collectable removeFromParentAndCleanup:YES];
                
                game.player.collected +=  (1 * game.player.collectable_multiplier);
            }
        }
    }
    
    CCARRAY_FOREACH(bigcollectables, bigcollectable)
    {
        if ( !game.isIntro )
        {
            if ( [bigcollectable worldBoundingBox].origin.y < -200 )
            {
                bigcollectable.visible = NO;
                bigcollectable.dead = YES;
                [bigcollectables removeObject:bigcollectable];
                [bigcollectable removeFromParentAndCleanup:YES];
            }
        }

        bigcollectable.visible = ( [bigcollectable worldBoundingBox].origin.y < [[CCDirector sharedDirector] winSize].height && [bigcollectable worldBoundingBox].origin.y > -20 && !bigcollectable.dead );
        
        if ( bigcollectable.visible )
        {
            if ( [bigcollectable isIntersectingPlayer:game.player] )
            {
                game.player.bigcollected++;                
                if ( ![SimpleAudioEngine sharedEngine].mute )
                {
                    [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"collect%i.caf",game.player.bigcollected]];
                }

                [game.fx start:1 position:ccp([bigcollectable worldBoundingBox].origin.x + [bigcollectable contentSize].width/2, [bigcollectable worldBoundingBox].origin.y)];

                bigcollectable.visible = NO;
                [bigcollectables removeObject:bigcollectable];
                [bigcollectable removeFromParentAndCleanup:YES];
            }
        }
    }
        
    CCARRAY_FOREACH(enemies, enemy)
    {
        enemy.visible = ( [enemy worldBoundingBox].origin.y < [[CCDirector sharedDirector] winSize].height && [enemy worldBoundingBox].origin.y > -70 && !enemy.dead );
        
        if ( enemy.visible )
        {
            if ( !game.isIntro )
            {
                if ([enemy worldBoundingBox].origin.y < -80)
                {
                    enemy.visible = NO;
                    enemy.dead = YES;
                }
            }
            [enemy isIntersectingTouch:game];
            [enemy isIntersectingPlayer:game];
            [enemy move];
            
            // Projectile movement
            if ( enemy.projectiles.count >= 1 )
            {
                CCARRAY_FOREACH(enemy.projectiles, projectile)
                {
                    if ( [projectile isIntersectingPlayer:game.player] )
                    {
                        [game.fx start:1 position:[game.player worldBoundingBox].origin];
                        projectile.visible = NO;
                        [enemy removeChildByTag:1111 cleanup:YES];
                        game.player.health--;
                    }
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
                if ( ![SimpleAudioEngine sharedEngine].mute ) [[SimpleAudioEngine sharedEngine] playEffect:@"player-hit.caf"];
                game.user.deaths++;
            }
            game.user.jumps     += game.player.jumps;
            [game.user sync];            
            [self end:game];
        }
    }
    else 
    {
        if ( !game.player.isAlive ) game.player.deaths++;
        game.user.jumps     += game.player.jumps;
        [game.user sync];
        [self end:game];
    }
}

- (void) end:(Game*)game
{
    if (game.didWin)
    {
        [[CCDirector sharedDirector] replaceScene:[GameOverScene sceneWithGame:game]];
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
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCDirector sharedDirector] replaceScene:[GameScene sceneWithWorld:self.world andLevel:self.level isRestart:TRUE restartMusic:NO]];
}

@end