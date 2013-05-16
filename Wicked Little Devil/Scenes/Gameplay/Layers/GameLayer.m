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

- (id) init
{
	if( (self=[super init]) ) {}
	return self;
}

- (void) createWorldWithObjects:(CCArray*)gameObjects
{
    self.platforms       = [CCArray arrayWithCapacity:100];
    self.collectables    = [CCArray arrayWithCapacity:500];
    self.bigcollectables = [CCArray arrayWithCapacity:3];
    self.halocollectables = [CCArray arrayWithCapacity:3];
    self.enemies         = [CCArray arrayWithCapacity:100];
    self.triggers        = [CCArray arrayWithCapacity:100];
    self.emitters        = [CCArray arrayWithCapacity:100];
    self.tips            = [CCArray arrayWithCapacity:100];
    
    for (CCNode* node in self.children)
    {
        if ([node isKindOfClass: [Platform class]])
        {
            [self.platforms addObject:node];
            if ( node.tag == 52 ) node.visible = NO;
        }
        if ([node isKindOfClass: [CCNode class]])
        {
            for (Collectable *collectable_tmp in node.children)
            {
                [self.collectables addObject:collectable_tmp];
            }
        }
        if ([node isKindOfClass: [BigCollectable class]])
        {
            [self.bigcollectables addObject:node];
        }
        if ([node isKindOfClass: [HaloCollectable class]])
        {
            if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
            {
                [self.halocollectables addObject:node];
            }
            else
            {
                node.visible = NO;
            }
        }
        if ([node isKindOfClass: [Enemy class]])
        {
            [self.enemies addObject:node];
        }
        if ([node isKindOfClass: [Trigger class]])
        {
            [self.triggers addObject:node]; 
            node.visible = NO;
        }
        if ([node isKindOfClass: [Tip class]])
        {
            [self.tips addObject:node];
            node.visible = NO;
        }
    }
    
    CCARRAY_FOREACH(self.collectables, collectable)
    {
        collectable.visible = ( [collectable worldBoundingBox].origin.y < [[CCDirector sharedDirector] winSize].height && [collectable worldBoundingBox].origin.y > -20 );
    }
    CCARRAY_FOREACH(self.bigcollectables, bigcollectable)
    {
        bigcollectable.visible = ( [bigcollectable worldBoundingBox].origin.y < [[CCDirector sharedDirector] winSize].height && [bigcollectable worldBoundingBox].origin.y > -20 );
    }
    CCARRAY_FOREACH(self.halocollectables, halocollectable)
    {
        halocollectable.visible = ( [halocollectable worldBoundingBox].origin.y < [[CCDirector sharedDirector] winSize].height && [halocollectable worldBoundingBox].origin.y > -20);
    }
    CCARRAY_FOREACH(self.platforms, platform)
    {
        platform.visible = ( [platform worldBoundingBox].origin.y < [[CCDirector sharedDirector] winSize].height && [platform worldBoundingBox].origin.y > -20 );
        if ( !platform.animating ) [platform move];
    }
    CCARRAY_FOREACH(self.enemies, enemy)
    {
        enemy.visible = ( [enemy worldBoundingBox].origin.y < [[CCDirector sharedDirector] winSize].height && [enemy worldBoundingBox].origin.y > -20 );
        if ( !enemy.animating ) [enemy setupAnimations];
    }
}

- (void) update:(Game *)game
{       
    [self gameoverCheck:game];
    
    CCARRAY_FOREACH(self.platforms, platform)
    {
        if ( !game.isIntro )
        {
            if ([platform worldBoundingBox].origin.y < -80 )
            {
                if (  !(game.user.powerup == 100) )
                {
                    platform.visible = NO;
                    platform.dead = YES;
                    [self.platforms removeObject:platform];
                    [platform removeFromParentAndCleanup:YES];
                }
            }
        }
        
        if ( game.user.powerup == 100 )
        {
            platform.visible = ( !platform.dead && [platform worldBoundingBox].origin.y < [[CCDirector sharedDirector] winSize].height );
        }
        else
        {
            if ( platform.tag == 51 || platform.tag == 52 )
            {
                platform.visible = ( [platform worldBoundingBox].origin.y < [[CCDirector sharedDirector] winSize].height && [platform worldBoundingBox].origin.y > -20 );
            }
            else
            {
                platform.visible = ( [platform worldBoundingBox].origin.y < [[CCDirector sharedDirector] winSize].height && [platform worldBoundingBox].origin.y > -20 && !platform.dead);
            }
        }
        
        if (  platform.visible )
        {
            if ( game.player.controllable )
            {
                if ( platform.tag == 51 || platform.tag == 52 )
                {
                    if ( !platform.dead )
                    {
                        [platform isIntersectingPlayer:game platforms:self.platforms];
                    }
                }
                else
                {
                    [platform isIntersectingPlayer:game platforms:self.platforms];                    
                }
            }
        }
    }
    
    CCARRAY_FOREACH(self.collectables, collectable)
    {
        if ( !game.isIntro )
        {
            if ([collectable worldBoundingBox].origin.y < -80)
            {
                collectable.visible = NO;
                collectable.dead = YES;
                [self.collectables removeObject:collectable];
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
            
            if ( game.user.powerup == 103 )
            {
                if ( [collectable isClosertoPlayer:game.player] )
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
                [self.collectables removeObject:collectable];
                [collectable removeFromParentAndCleanup:YES];
                
                game.player.collected +=  (1 * game.player.collectable_multiplier);
            }
        }
    }
    
    CCARRAY_FOREACH(self.bigcollectables, bigcollectable)
    {
        if ( !game.isIntro )
        {
            if ( [bigcollectable worldBoundingBox].origin.y < -200 )
            {
                bigcollectable.visible = NO;
                bigcollectable.dead = YES;
                [self.bigcollectables removeObject:bigcollectable];
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
                [self.bigcollectables removeObject:bigcollectable];
                [bigcollectable removeFromParentAndCleanup:YES];
            }
        }
    }
    
    CCARRAY_FOREACH(self.halocollectables, halocollectable)
    {
        if ( !game.isIntro )
        {
            if ( [bigcollectable worldBoundingBox].origin.y < -200 )
            {
                halocollectable.visible = NO;
                halocollectable.dead = YES;
                [self.halocollectables removeObject:halocollectable];
                [halocollectable removeFromParentAndCleanup:YES];
            }
        }
        
        halocollectable.visible = ( [halocollectable worldBoundingBox].origin.y < [[CCDirector sharedDirector] winSize].height && [halocollectable worldBoundingBox].origin.y > -20 && !halocollectable.dead );
        
        if ( halocollectable.visible )
        {
            if ( [halocollectable isIntersectingPlayer:game.player] )
            {
                game.player.halocollected++;
                if ( ![SimpleAudioEngine sharedEngine].mute )
                {
//                    [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"collect_halo.caf",game.player.bigcollected]];
                }
                
                [game.fx start:2 position:ccp([halocollectable worldBoundingBox].origin.x + [halocollectable contentSize].width/2, [halocollectable worldBoundingBox].origin.y)];
                
                halocollectable.visible = NO;
                [self.halocollectables removeObject:halocollectable];
                [halocollectable removeFromParentAndCleanup:YES];
            }
        }
    }
        
    CCARRAY_FOREACH(self.enemies, enemy)
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
            
            if ( enemy.projectiles.count >= 1 )
            {
                CCARRAY_FOREACH(enemy.projectiles, projectile)
                {
                    if ( [projectile isIntersectingPlayer:game.player] && projectile.visible )
                    {
                        if ( ![SimpleAudioEngine sharedEngine].mute ) [[SimpleAudioEngine sharedEngine] playEffect:@"boom.caf"];
                        [game.fx start:0 position:[game.player worldBoundingBox].origin];
                        projectile.visible = NO;
                        [enemy removeChildByTag:1111 cleanup:YES];
                        game.player.health--;
                        if ( --game.player.health <= 0 )
                        {
                            game.player.animating = NO;
                            [game.player animate:4];
                        }
                    }
                    
                    if ( [projectile isIntersectingParent:enemy] && enemy.visible )
                    {
                        if ( ![SimpleAudioEngine sharedEngine].mute ) [[SimpleAudioEngine sharedEngine] playEffect:@"boom.caf"];                        
                        [game.fx start:0 position:[enemy worldBoundingBox].origin];
                        enemy.visible = FALSE;
                        enemy.dead = TRUE;
                        projectile.visible = NO;
                        [enemy removeChildByTag:1111 cleanup:YES];
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