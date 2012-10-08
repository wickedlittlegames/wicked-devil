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
            node.visible = NO;
        }
        if ([node isKindOfClass: [Tip class]])
        {
            [tips addObject:node];
        }
    }
}

- (void) update:(Game *)game
{       
    [self gameoverCheck:game];
    
    Platform *platform = nil;
    Collectable *collectable = nil;
    BigCollectable *bigcollectable = nil;
    Enemy *enemy = nil;
    Projectile *projectile = nil;
    EnemyFX *fx = nil;
    Tip *tip = nil;
    
    CCARRAY_FOREACH(tips, tip)
    {
        if (!tip.faded)
        {
            [tip runAction:[CCSequence actions:[CCFadeOut actionWithDuration:2.0f],[CCCallBlock actionWithBlock:^(void){
                tip.faded = YES;
            }],nil]];
        }
    }
    
    CCARRAY_FOREACH(platforms, platform)
    {
        if (!platform.end_fx_added && platform.tag == 100)
        {
            platform.end_fx_added = YES;
        }
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
        if ([collectable worldBoundingBox].origin.y < -80 && !game.isIntro)
        {
            collectable.visible = NO;
            [collectables removeObject:collectable];
            [collectable removeFromParentAndCleanup:YES];
        }
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
            game.player.score += 1000;
            [game.fx start:1 position:ccp([bigcollectable worldBoundingBox].origin.x + [bigcollectable contentSize].width/2, [bigcollectable worldBoundingBox].origin.y)];
            if ( ![SimpleAudioEngine sharedEngine].mute )
            {
                [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"collect%i.wav",game.player.bigcollected]];
            }            
        }
    }
        
    CCARRAY_FOREACH(enemies, enemy)
    {
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
                    [game.fx start:1 position:[game.player worldBoundingBox].origin];
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
            if ( !game.player.isAlive ) { game.user.deaths++; }
            game.user.jumps     += game.player.jumps;
            [game.user sync];            
            [self end:game];
        }
    }
    else 
    {
        if ( !game.player.isAlive ) { game.player.deaths++; }
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
    [[CCDirector sharedDirector] replaceScene:[GameScene sceneWithWorld:self.world andLevel:self.level isRestart:TRUE restartMusic:NO]];
}

@end