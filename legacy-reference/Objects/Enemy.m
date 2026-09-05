//
//  Enemy.m
//  Wicked Little Devil
// 
//  Created by Andrew Girvan on 30/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
// 1  = Bat
// 2  = Mine
// 3  = Bubble
// 4  = Rockets
// 5  = blackholes
// 6  = Angel Laser of Death (from the top and sides and bottom)

#import "Game.h"
#import "FXLayer.h"

@implementation Enemy

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        self.projectiles    = [CCArray arrayWithCapacity:100];
        self.fx             = [CCArray arrayWithCapacity:100];
    }
    return self;
}

- (void) move
{
    switch (self.tag)
    {
        default: break;
        case 1: // BAT: moving right
			self.position = ccp(self.position.x + 1, self.position.y);
            if (self.position.x > [[CCDirector sharedDirector] winSize].width+40) self.position = ccp(-50, self.position.y);
            break;
        case 101: // BAT: moving left
			self.position = ccp(self.position.x - 1, self.position.y);
            if (self.position.x > -50) self.position = ccp([[CCDirector sharedDirector] winSize].width+40, self.position.y);
            break;
    }
}

- (void) isIntersectingPlayer:(Game*)game
{
    if ( self.visible && !self.running && !self.dead )
    {
        switch (self.tag)
        {
            default: // simple interaction, kill player
                if ( [self intersectCheck:game] && !self.dead )   [self action:self.tag game:game];
                break;
            case 4:  // rocket blast
                if ( [self radiusCheck:game] ) [self action:self.tag game:game];
                break;
            case 5: // black hole, add drag to the controls
                if ( [self intersectCheck:game]) [self action:self.tag game:game];
                break;
        }
    }
}

- (void) isIntersectingTouch:(Game*)game
{
    if ( self.visible && self.floating && self.tag == 3 )
    {
        if ( CGRectContainsPoint([self worldBoundingBox], [[CCDirector sharedDirector] convertToGL:game.touch] ))
        {
            [self action_bubble_pop:game];
        }
    }
}

- (void) action:(int)action_id game:(Game*)game
{
    if ( !self.dead )
    {
        switch(action_id)
        {
            case 1: // BAT: Jump ontop, or die below
                [self action_bat_hit:game];
                break;
            case 101: // BAT: Jump ontop, or die below
                [self action_bat_hit:game];
                break;
            case 2: // MINE: Any time touched, blows up
                [self action_mine_explode:game];
            case 22:
                [self action_mine_explode:game];
                break;
            case 223:
                [self action_mine_explode:game];
                break;
            case 3: // BUBBLE: Floats the player up
                if ( game.player.floating == NO ) [self action_bubble_float:game];
                break;
            case 4: // ROCKET: Shoots rocket at target player area
                if ( !(game.user.powerup == 104) ) [self action_shoot_rocket:game];
                break;
            case 5: // SPACE: Blackhole draws player in and transports player to a new location
                [self action_teleport_player:game];
                break;
            default: break;
        }
    }
}

- (void) action_bat_hit:(Game*)game
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) [[SimpleAudioEngine sharedEngine] playEffect:@"bat-hit.caf"];
    
    if ( game.player.velocity.y > 0 ) // If player is jumping INTO the bat
    {
        game.player.health--;
        
        if ( game.player.health <= 0 )
        {
            game.player.animating = NO;
            [game.player animate:4];
        }
    }
    else // if player is jumping ONTO the bat
    {
        [game.player jump:game.player.jumpspeed];
    }
    
    self.dead = YES;
    
    id up   = [CCEaseExponentialOut actionWithAction:[CCMoveBy actionWithDuration:0.5 position:ccp(0,30)]];
    id down = [CCEaseExponentialIn actionWithAction:[CCMoveBy actionWithDuration:0.5 position:ccp(0,-250)]];
    id end  = [CCCallBlock actionWithBlock:^(void) { self.visible = NO; [self removeFromParentAndCleanup:YES]; }];
    
    [self runAction:[CCSequence actions:up,down,end, nil]];
}

- (void) action_mine_explode:(Game*)game
{
    if ( !self.dead )
    {
        if ( ![SimpleAudioEngine sharedEngine].mute ) [[SimpleAudioEngine sharedEngine] playEffect:@"boom.caf"];
        [game.fx start:0 position:ccp([self worldBoundingBox].origin.x + [self contentSize].width/2, [self worldBoundingBox].origin.y)];
        
        self.dead = YES;
        self.visible = NO;
        game.player.health--;
        if ( game.player.health <= 0 )
        {
            game.player.animating = NO;
            [game.player animate:4];
        }
    }
}

- (void) action_bubble_float:(Game*)game
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) [[SimpleAudioEngine sharedEngine] playEffect:@"bubble.caf"];
    
    self.running = YES;
    self.floating = YES;
    game.player.floating = YES;
    game.player.position = self.position;
    self.zOrder = 10000;
    game.player.controllable = NO;
    game.player.velocity = ccp ( 0, 0 );
    game.touch = ccp ( game.player.position.x, game.touch.y );
    
    id floatup_player           = [CCMoveBy actionWithDuration:3 position:ccp(0,(IS_IPHONE5 ? 295 : 250))];
    id floatup_bubble           = [CCMoveBy actionWithDuration:3 position:ccp(0,(IS_IPHONE5 ? 295 : 250))];
    id end_action_bubblefloat   = [CCCallBlock actionWithBlock:^(void) { self.dead = YES; self.running = NO; self.floating = NO; }];
    id end_action_player        = [CCCallBlock actionWithBlock:^(void) { game.player.controllable = YES; game.player.floating = NO; }];
    
    [self runAction:[CCSequence actions:floatup_bubble, end_action_bubblefloat, nil]];
    [game.player runAction:[CCSequence actions:floatup_player, end_action_player, nil]];
}

- (void) action_bubble_pop:(Game*)game
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) [[SimpleAudioEngine sharedEngine] playEffect:@"bubble.caf"];
    
    [self stopAllActions];
    [game.player stopAllActions];
    game.player.controllable = YES;
    game.player.floating = NO;
    self.dead = YES; self.running = NO;
}

- (void) action_shoot_rocket:(Game*)game
{
    self.running = YES;
    NSString *rocketimg = @"rocket.png";
    
    if ( game.world == 20 )
    {
        rocketimg = @"rocket-bw.png";
    }
    
    // SHOOT A ROCKET AT THE PLAYER
    Projectile *projectile = [Projectile spriteWithFile:rocketimg];
    [projectile setPosition:ccp(27, [self worldBoundingBox].origin.y + (IS_IPHONE5 ? 355 : 300))];
    
    // Rocket trail
    EnemyFX *rocket_fx = [EnemyFX particleWithFile:@"RocketBlast.plist"];
    [rocket_fx setPosition:ccp(projectile.position.x, projectile.position.y + 15)];
    rocket_fx.tag = 1111;
    
    [self addChild:rocket_fx];
    [self addChild:projectile];
    [self.projectiles addObject:projectile];
    
    // Determine offset of location to projectile
    int offX = projectile.position.x;
    int offY = [game.player worldBoundingBox].origin.y - projectile.position.y;
    
    // Determine where we wish to shoot the projectile to
    int realX = [[CCDirector sharedDirector] winSize].width + (projectile.contentSize.width/2);
    float ratio = (float) offY / (float) offX;
    int realY = (realX * ratio) + projectile.position.y;
    CGPoint realDest = ccp(0, realY);
    
    // Determine the length of how far we're shooting
    int offRealX = realX - projectile.position.x;
    int offRealY = realY - projectile.position.y;
    float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
    float velocity = (IS_IPHONE5 ? 473/1 : 400/1 );
    float realMoveDuration = length/velocity;
    
    id action_end = [CCCallBlock actionWithBlock:^(void) { projectile.visible = NO; }];
    id fx_end     = [CCCallBlock actionWithBlock:^(void) { [rocket_fx stopSystem]; [rocket_fx removeFromParentAndCleanup:YES]; }];
    
    // Move projectile to actual endpoint
    [projectile runAction:[CCSequence actions:
                           [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
                           action_end,
                           nil]];
    [rocket_fx runAction:[CCSequence actions:
                          [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
                          fx_end,
                          nil]];
}

- (void) action_teleport_player:(Game*)game
{
    game.player.velocity = ccp ( 0, 0 );
    
    CCSprite *blackhole_child = (CCSprite *)[self getChildByTag:1000];
    [game.player setPosition:[blackhole_child worldBoundingBox].origin];
    
    game.touch = ccp ( game.player.position.x, game.touch.y );
}

- (void) setupAnimations
{
    if ( self.tag == 1 )
    {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"BatAnim.plist"];
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"BatAnim.png"];
        [self addChild:spriteSheet];
        
        NSMutableArray *arr_anim_flap = [NSMutableArray array];
        for(int i = 1; i <= 7; ++i)
        {
            [arr_anim_flap addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"bat-flap%i.png", i]]];
        }
        
        self.anim_flap = [CCAnimation animationWithSpriteFrames:arr_anim_flap  delay:0.5f];
        CCAction *repeater = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:self.anim_flap]];
        
        [self runAction:repeater];
        self.animating = YES;
    }
    if ( self.tag == 22 )
    {
        id horizontalmove = [CCMoveBy actionWithDuration:2 position:ccp(-100,0)];
        id horizontalmove_opposite = [CCMoveBy actionWithDuration:2 position:ccp(100,0)];
        
        CCAction *repeater = [CCRepeatForever actionWithAction:[CCSequence actions:horizontalmove,horizontalmove_opposite,nil]];
        [self runAction:repeater];
        
        self.animating = YES;
    }
    if ( self.tag == 223 )
    {
        id verticalmove = [CCMoveBy actionWithDuration:2 position:ccp(100,0)];
        id verticalmove_opposite = [CCMoveBy actionWithDuration:2 position:ccp(-100,0)];
        
        CCAction *repeater = [CCRepeatForever actionWithAction:[CCSequence actions:verticalmove,verticalmove_opposite,nil]];
        [self runAction:repeater];
        
        self.animating = TRUE;
    }

    if ( self.tag == 6 )
    {
        EnemyFX *tmp_fx = [EnemyFX particleWithFile:@"AngelBlast.plist"];
        id anim_angel_blast = [CCCallBlock actionWithBlock:^(void)
                               {
                                   [tmp_fx setPosition:self.position];
                                   [self.fx addObject:tmp_fx];
                                   
                                   if ( ![self getChildByTag:1234] )
                                   {
                                       [self addChild:tmp_fx z:10 tag:1234];
                                   }
                                   else
                                   {
                                       [tmp_fx resetSystem];
                                   }
                                   
                               }];
        id anim_angel_blast_stop = [CCCallBlock actionWithBlock:^(void)
                                    {
                                        [tmp_fx stopSystem];
                                    }];
        id anim_angel_blast_delay = [CCDelayTime actionWithDuration:4];
        id anim_angel = [CCRepeatForever actionWithAction:[CCSequence actions:anim_angel_blast, anim_angel_blast_delay, anim_angel_blast_stop, anim_angel_blast_delay, nil]];
        
        [self runAction:anim_angel];
        self.animating = YES;
    }
}

- (bool) intersectCheck:(Game*)game
{
    BOOL isCollision = NO;
    if ( self.visible && !self.running )
    {
        CGRect intersection = CGRectIntersection([self worldBoundingBox], [game.player worldBoundingBox]);
        
        // Look for simple bounding box collision
        if (!CGRectIsEmpty(intersection))
        {
            // Get intersection info
            unsigned int x = intersection.origin.x;
            unsigned int y = intersection.origin.y;
            unsigned int w = intersection.size.width;
            unsigned int h = intersection.size.height;
            unsigned int numPixels = w * h;
            
            // Draw into the RenderTexture
            [_rt beginWithClear:0 g:0 b:0 a:0];
            
            // Render both sprites: first one in RED and second one in GREEN
            glColorMask(1, 0, 0, 1);
            [self visit];
            glColorMask(0, 1, 0, 1);
            [game.player visit];
            glColorMask(1, 1, 1, 1);
            
            // Read pixels
            ccColor4B *buffer = malloc( sizeof(ccColor4B) * numPixels );
            glReadPixels(x, y, w, h, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
            
            [_rt end];
            
            // Read buffer
            unsigned int step = 1;
            for(unsigned int i=0; i<numPixels; i+=step)
            {
                ccColor4B color = buffer[i];
                
                if (color.r > 0 && color.g > 0)
                {
                    isCollision = YES;
                    break;
                }
            }
            
            // Free buffer memory
            free(buffer);
        }
    }
    return isCollision;
}

- (bool) radiusCheck:(Game*)game
{
    float xdif = self.position.x - game.player.position.x;
    float ydif = self.position.y - game.player.position.y;
    float radius = 30;
    float radiusTwo = 1;
    
    float distance = sqrt(xdif*xdif+ydif*ydif);
    
    return (distance <= radius+radiusTwo);
}

- (void) action_end_item
{
    self.visible = NO;
    self.running = NO;
}

@end
