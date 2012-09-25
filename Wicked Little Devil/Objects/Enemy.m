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

#import "Platform.h"
#import "Game.h"
#import "Enemy.h"
#import "FXLayer.h"

@implementation Enemy
@synthesize type, active, speed_x, speed_y, health, damage, attacking, base_y, animating, batFlap;

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
        self.animating = NO;
        CCLOG(@"ENEMY");
        
        // update bat anim files
        [self setupAnimations];
    }
    return self;
}

- (void) doMovement
{
    switch (self.tag)
    {
        default: // just move down the screen
            break;
        case 1: // bat wobble
            if ( self.base_y == 0 ) { self.base_y = self.position.y; }
            self.position = ccp(self.position.x + 0.5, self.position.y + sin((self.position.x+1)/10) * 10);
            if (self.position.x > [[CCDirector sharedDirector] winSize].width+40) 
            {
                self.position = ccp(-70, self.base_y);
            }
            break;
    }
}

- (void) isIntersectingPlayer:(Game*)game
{
    switch (self.tag)
    {
        default: // all normal hit then die enemies
            if ( self.visible && self.health > 0)
            {
                CGSize enemy_size = self.contentSize;
                CGPoint enemy_pos = self.position;
                CGSize player_size     = game.player.contentSize; 
                CGPoint player_pos     = game.player.position;
                
                float max_x = enemy_pos.x - enemy_size.width/2 - 10;
                float min_x = enemy_pos.x + enemy_size.width/2 + 10;
                float min_y = enemy_pos.y + (enemy_size.height+player_size.height)/2 - 1;
                
                if(player_pos.x > max_x &&
                   player_pos.x < min_x &&
                   player_pos.y > enemy_pos.y &&
                   player_pos.y < min_y)
                {
                    [self doAction:self.tag player:game];
                }
            }
            break;
        case 4:
            if ( [self radiusCheck:self.position withRadius:70 collisionWithCircle:game.player.position collisionCircleRadius:1] && !self.attacking )
            {
                [self doAction:4 player:game];
            }
            break;
    }
}

- (void) doAction:(int)tag player:(Game*)game
{   
    switch (tag)
    {
        default:
            if ( game.player.velocity.y > 0 )
            {
                [self damageToPlayer:game.player];
            }
            else
            {
                [game.player jump:game.player.jumpspeed];
            }
            self.active = NO;
            self.visible = NO;
            break;
        case 2: // mine
            self.active = NO;
            self.visible = NO;
            [game.fx start:0 position:[self worldBoundingBox].origin];
            [self damageToPlayer:game.player];
            break;
        case 3: // water
            if ( !self.attacking ) [self floatPlayer:game.player];
            break;
        case 4: // generate rocket somewhere
            [self shootRocket:game];
            break;
    }
}

- (void) shootRocket:(Game*)game
{
    Enemy *rocket = [CCSprite spriteWithFile:@"enemy-rocket.png"];
    rocket.position = ccp (self.position.x, 500);
    [self addChild:rocket];
    
    [rocket runAction:[CCMoveTo actionWithDuration:2.0f position:ccp([game.player worldBoundingBox].origin.x, [game.player worldBoundingBox].origin.y - 300)]];
}

- (void) floatPlayer:(Player*)player
{
    self.attacking = TRUE;
    
    self.position = ccp(player.position.x, player.position.y);
    [self setZOrder:4];
        
    id movedownwobble = [CCMoveBy actionWithDuration:0.1 position:ccp(0,-10)];
    id moveupby = [CCMoveBy actionWithDuration:5 position:ccp(0,400)];
    id killfloat = [CCCallFuncND actionWithTarget:self selector:@selector(killFloat:data:) data:(void*)player];
    
    player.controllable = FALSE;
    player.velocity = ccp(0,0);
    [player runAction:[CCSequence actions:movedownwobble, moveupby, killfloat, nil]];
}

- (void) killFloat:(id)sender data:(id)data
{
    Player *player = data;
    player.controllable = TRUE;
    self.visible = FALSE;
    self.active = FALSE;
    [self removeFromParentAndCleanup:YES];
}

- (void) damageToPlayer:(Player*)player
{
    player.health = player.health - self.damage;
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

- (void) setupAnimations
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"BatAnim.plist"];
    //CCSpriteBatchNode *spriteSheet3 = [CCSpriteBatchNode batchNodeWithFile:@"BatAnim.png"];
//    [self addChild:spritesheet3];
    
    NSMutableArray *flapAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 7; ++i) {
        [flapAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"bat-flap%i.png", i]]];
        CCLOG(@"bat-flap%i.png", i);
    }
    
    self.batFlap = [CCAnimation animationWithSpriteFrames:flapAnimFrames delay:0.05f];
    
    if ( self.tag == 1 && !self.animating )
    {
        [self runAction:[CCSequence actions:[CCAnimate actionWithAnimation:self.batFlap], nil]];
        self.animating = YES;
    }
}

@end
