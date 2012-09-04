//
//  Enemy.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 30/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//
//
//   -1 - Rat STATIC
//   0 - Bat
//   1 - Water
//   2 - Preist
//   3 - Meteors (take from little devil)
//   4 - Angels
//   101 - projectile at position

#import "Platform.h"
#import "Enemy.h"

@implementation Enemy
@synthesize type, active, speed_x, speed_y, health, damage, attacking;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        self.active = FALSE;
        
        // defaults
        self.health = 1;
        self.damage = 1;
        self.speed_x = 1;
        self.speed_y = 1;
        self.attacking = FALSE;
        self.active = YES;
        CCLOG(@"ENEMY");
    }
    return self;
}

- (void) doMovement
{
    switch (self.tag)
    {
        default: // just move down the screen
            break;
        case 0: // bat wobble
            self.position = ccp(self.position.x + 0.5, self.position.y + sin((self.position.x+1)/10) * 2); 
            if (self.position.x > [[CCDirector sharedDirector] winSize].width+70) self.position = ccp(-70, self.position.y);
            break;
    }
}

- (void) isIntersectingPlayer:(Player*)player
{
    switch (self.tag)
    {
        default: // all normal hit then die enemies
            if ( self.visible && self.health > 0)
            {
                CGSize enemy_size = self.contentSize;
                CGPoint enemy_pos = self.position;
                CGSize player_size     = player.contentSize; 
                CGPoint player_pos     = player.position;
                
                float max_x = enemy_pos.x - enemy_size.width/2 - 10;
                float min_x = enemy_pos.x + enemy_size.width/2 + 10;
                float min_y = enemy_pos.y + (enemy_size.height+player_size.height)/2 - 1;
                
                if(player_pos.x > max_x &&
                   player_pos.x < min_x &&
                   player_pos.y > enemy_pos.y &&
                   player_pos.y < min_y)
                {
                    [self doAction:self.tag player:player];
                }
            }
            break;
        case 2: // amish/preist, projectile
            if ( [self radiusCheck:self.position withRadius:70 collisionWithCircle:player.position collisionCircleRadius:1] && !self.attacking)
            {
                [self doAction:self.tag player:player];
            }
            break;
        case 3: // meteor trigger (shadow on the rock)
            if ( [self radiusCheck:self.position withRadius:70 collisionWithCircle:player.position collisionCircleRadius:1] && !self.attacking )
            {
                [self doAction:self.tag player:player];
            }
            break;
        case 4: // angels
            if ( !self.attacking )
            {
                [self doAction:self.tag player:player];
            }
            break;
    }
}

- (void) doAction:(int)tag player:(Player*)player
{
    Platform* target = player.last_platform_touched;
    
    switch (tag)
    {
        default: // rat, bat, meteors
            [self damageToPlayer:player];
            break;
        case 1: // move player up then pop (animation)
            if ( !self.attacking ) [self floatPlayer:player];
            break;
        case 2: // fire a projectile
            [self fireTowardPosition:[player worldBoundingBox].origin];
            break;
        case 3: 
            [self fireDownWithWarning:self.position];
            break;
        // stop intersections of angels
        case 4:
            [self fireTowardPosition:target.position];
            break;
    }
}

- (void) floatPlayer:(Player*)player
{
    CCLOG(@"FLOATING");
    self.attacking = TRUE;
    
    self.position = ccp(player.position.x, player.position.y);
    [self setZOrder:4];
    
    CGPoint saved_velocity = player.velocity;
    
    id movedownwobble = [CCMoveBy actionWithDuration:0.1 position:ccp(0,-10)];
    id moveupby = [CCMoveBy actionWithDuration:5 position:ccp(0,400)];
    id killfloat = [CCCallFuncND actionWithTarget:self selector:@selector(killFloat:data:) data:(void*)player];
    
    player.controllable = FALSE;
    
    [player runAction:[CCSequence actions:movedownwobble, moveupby, killfloat, nil]];
    player.velocity = saved_velocity;
}

- (void) killFloat:(id)sender data:(id)data
{
    Player *player = data;
    player.controllable = TRUE;
    self.visible = FALSE;
    self.active = FALSE;
    [self removeFromParentAndCleanup:YES];
}

- (void) fireDownWithWarning:(CGPoint)position
{
    self.attacking = TRUE;
    
    projectile = [Enemy spriteWithFile:@"bigcollectable.png"];
    [projectile setPosition:ccp(self.position.x, self.position.y + 2000)];
    projectile.tag = 102;
    [self addChild:projectile];
    
    id movetoposition = [CCMoveBy actionWithDuration:7 position:ccp(0,-5000)];
    id killattack     = [CCCallFunc actionWithTarget:self selector:@selector(killAttack)];
    
    [projectile runAction:[CCSequence actions:movetoposition, killattack, nil]];
}

- (void) fireTowardPosition:(CGPoint)position
{
    self.attacking = TRUE;
    
    // Create the projectile
    projectile = [Enemy spriteWithFile:@"collectable.png"];
    [projectile setPosition:ccp(self.position.x,self.position.y)];
    projectile.tag = 101;
    [self addChild:projectile];
    
    id movetoplayer = [CCMoveTo actionWithDuration:0.75 position:position];
    id delay       =  [CCDelayTime actionWithDuration:5];
    id resetAttack =  [CCCallFunc actionWithTarget:self selector:@selector(resetAttack)];
    
    [projectile runAction:[CCSequence actions:movetoplayer, delay, resetAttack, nil]];
}

- (void) resetAttack
{
    self.attacking = FALSE;
    [self removeChildByTag:101 cleanup:YES];
}

- (void) killAttack
{
    [self removeAllChildrenWithCleanup:YES];
    [self removeFromParentAndCleanup:YES];
}

- (void) damageToPlayer:(Player*)player
{
    player.health = player.health - self.damage;
}
 
- (void) damageFromPlayer:(Player*)player
{
    self.health = self.health - player.damage;
}

- (BOOL) isAlive 
{
    return ( self.health > 0.0 ? TRUE : FALSE );
}

- (BOOL) radiusCheck:(CGPoint) circlePoint withRadius:(float) radius collisionWithCircle:(CGPoint) circlePointTwo collisionCircleRadius:(float) radiusTwo 
{
    float xdif = circlePoint.x - circlePointTwo.x;
    float ydif = circlePoint.y - circlePointTwo.y;
    
    float distance = sqrt(xdif*xdif+ydif*ydif);
    
    if(distance <= radius+radiusTwo) 
        return YES;
    
    return NO;
}

@end
