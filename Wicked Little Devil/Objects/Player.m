//
//  Player.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Player.h"

@implementation Player
@synthesize health, damage, velocity, stats, collected, bigcollected, jumpspeed, modifier_gravity, score, last_platform_touched, controllable, toggled_platform, jumpAction, animating, fallAction, fallFarAction, explodeAction, falling;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        self.velocity = ccp ( 0 , 0 );
        self.jumpspeed = 7;        
        self.health = 1.0;
        self.damage = 1.0;
        self.scale = 1.5;
        self.collected = 0;
        self.bigcollected = 0;
        self.modifier_gravity = 0;
        self.score = 0;
        self.last_platform_touched = NULL;
        self.controllable = NO;
        self.toggled_platform = NO;
        self.animating = NO;
        self.falling = NO;
        
        [self setupAnimations];
    }
    return self;
}

- (void) movementwithGravity:(float)gravity
{
    self.velocity = ccp( self.velocity.x, self.velocity.y - (gravity + modifier_gravity) );
    self.position = ccp(self.position.x, self.position.y + self.velocity.y);
    
    if ( self.velocity.y < 0 && self.velocity.y > -5) 
    {
        [self animationRunner:2]; 
    }
    
    if ( self.velocity.y < -8.5  && !self.falling ) 
    {
        self.animating = NO;
        self.falling = YES;
        CCLOG(@"VELOCITY: %f", self.velocity.y); 
        [self animationRunner:3];
    }
}

- (BOOL) isAlive
{
    return ( self.health > 0.0 );
}

- (void) jump:(float)speed
{
    self.animating = NO;
    self.falling = NO;
    [self animationRunner:1];
    
    self.velocity = ccp (self.velocity.x, speed);
}

- (void) animationRunner:(int)which
{
    if ( !self.animating )
    {
        self.animating = YES;
        
        CCCallFunc *stopAnimation = [CCCallFunc actionWithTarget:self selector:@selector(killAnimation)];
        switch (which)
        {
            case 1: // jump
                [self runAction:[CCSequence actions:[CCAnimate actionWithAnimation:self.jumpAction], stopAnimation, nil]];
                break;
            case 2:
                [self runAction:[CCSequence actions:[CCAnimate actionWithAnimation:self.fallAction], nil]];
                break;
            case 3:
                [self runAction:[CCSequence actions:[CCAnimate actionWithAnimation:self.fallFarAction], nil]];
                break;
        }
    }
}

- (void) killAnimation
{
    self.animating = NO;
}



- (void) setupAnimations
{
    // JUMP
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"DevilAnim.plist"];
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"DevilAnim.png"];
    [self addChild:spriteSheet];
    
    NSMutableArray *jumpAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 6; ++i) {
        [jumpAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"jump%i.png", i]]];
    }

    NSMutableArray *fallFarAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 6; ++i) {
        [fallFarAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"fallingforever%i.png", i]]];
    }
    
    // JUMP
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"AnimDevilFall.plist"];
    CCSpriteBatchNode *spriteSheet2 = [CCSpriteBatchNode batchNodeWithFile:@"AnimDevilFall.png"];
    [self addChild:spriteSheet2];
    
    NSMutableArray *fallAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 4; ++i) {
        [fallAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"demon_Falling_%i.png", i]]];
    }
    
    self.jumpAction = [CCAnimation animationWithSpriteFrames:jumpAnimFrames delay:0.05f];
    self.fallAction = [CCAnimation animationWithSpriteFrames:fallAnimFrames delay:0.05f];    
    self.fallFarAction = [CCAnimation animationWithSpriteFrames:fallFarAnimFrames delay:0.05f];
}

- (void) setupPowerup:(int)powerup
{
    switch (powerup)
    {
        case 0:
            // nothing
            break;
        case 1:
            // double health
            self.health = self.health * 2;
            break;
        case 2:
            // light feet / less damage to platforms
            self.damage = self.damage / 4;
            break;
        case 3: 
            // invulnerability
            self.health = self.health * 100000;
        case 4:
            // bigger bounce
            self.jumpspeed = self.jumpspeed + 2;
            break;
        case 5:
            // little devil
            self.scale = self.scale/2;
            break;
        case 6:
            // low gravity
            self.modifier_gravity = 0.1;
            break;
        default:
            // nothing
            break;
            
        // OTHERS:
            // Bounce on the floor, never die from falling if self.position < 0, player jump make sound
            // Hit enemies from below - 
            // quicker reactions (modifier for move diff) - 
            // collectables are worth twice as much! - self.collectable += 2;
            // moneybags - normal platforms give 100 points per bounce but are destroyer
            // tiny enemies - enemies.scale = 0.5;
            // fun card - change devil to different colour - self.colour = ccc3(255,123,122);
            // fun card - comedy "boing" sound when jumping - 
            // fun card - dubstep noises when jumping on platforms
            
    }
}

@end