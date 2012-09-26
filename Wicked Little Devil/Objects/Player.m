//
//  Player.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Player.h"

@implementation Player
@synthesize health, damage, velocity, collected, bigcollected, jumpspeed, gravity, drag, modifier_gravity, score;
@synthesize last_platform_touched, controllable, toggled_platform, animating, falling;
@synthesize anim_jump, anim_fall, anim_fallfar;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        self.velocity = ccp ( 0 , 0 );
        self.drag = ccp ( 0, 0 );
        self.jumpspeed = 7.0;
        self.gravity = 0.18;
        self.modifier_gravity = 0;
        self.health = 1.0;
        self.damage = 1.0;
        self.collected = 0;
        self.bigcollected = 0;
        self.score = 0;
        self.last_platform_touched = NULL;
        
        // redo
        self.controllable = NO;
        self.toggled_platform = NO;
        self.animating = NO;
        self.falling = NO;
        
        //[self setupAnimations];
    }
    return self;
}

- (void) move
{
    self.velocity = ccp( self.velocity.x, self.velocity.y - (self.gravity + self.modifier_gravity) );
    self.position = ccp((self.position.x) + self.drag.x, (self.position.y + self.velocity.y) + self.drag.y);
    
    if ( self.velocity.y < 0 && self.velocity.y > -5)
    {
        [self animate:2];
    }

    if ( self.velocity.y < -8.5  && !self.falling )
    {
        self.animating = NO;
        self.falling = YES;
        [self animate:3];
    }
}

- (void) jump:(float)speed
{
    self.animating = NO;
    [self animate:1];
    
    self.velocity = ccp (self.velocity.x, speed);
}

- (void) animate:(int)animation_id
{
//    if ( !self.animating )
//    {
//        self.animating = YES;
//        
//        CCCallFunc *stopAnimation = [CCCallFunc actionWithTarget:self selector:@selector(end_animate)];
//        switch (animation_id)
//        {
//            case 1: // jump
//                [self runAction:[CCSequence actions:[CCAnimate actionWithAnimation:self.anim_jump], stopAnimation, nil]];
//                break;
//            case 2:
//                [self runAction:[CCSequence actions:[CCAnimate actionWithAnimation:self.anim_fall], nil]];
//                break;
//            case 3:
//                [self runAction:[CCSequence actions:[CCAnimate actionWithAnimation:self.anim_fallfar], nil]];
//                break;
//            case 4:
//                [self runAction:[CCFadeOut actionWithDuration:1.0f]];
//                break;
//        }
//    }
}

- (void) end_animate
{
    self.animating = NO;
    [self stopAllActions];
}

- (bool) isAlive
{
    return ( self.health > 0.0 );
}

- (bool) isControllable
{
    return self.controllable;
}

- (void) setupAnimations
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"DevilAnim.plist"];
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"DevilAnim.png"];
    [self addChild:spriteSheet];
    
    NSMutableArray *arr_anim_jump = [NSMutableArray array];
    for(int i = 1; i <= 6; ++i) {
        [arr_anim_jump addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"jump%i.png", i]]];
    }
    
    NSMutableArray *arr_fall = [NSMutableArray array];
    for(int i = 1; i <= 6; ++i) {
        [arr_fall addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"fall%i.png", i]]];
    }
    
    NSMutableArray *arr_fall_far = [NSMutableArray array];
    for(int i = 1; i <= 6; ++i) {
        [arr_fall_far addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"fall_far%i.png", i]]];
    }
    
    self.anim_jump      = [CCAnimation animationWithSpriteFrames:arr_anim_jump  delay:0.05f];
    self.anim_fall      = [CCAnimation animationWithSpriteFrames:arr_fall       delay:0.05f];
    self.anim_fallfar   = [CCAnimation animationWithSpriteFrames:arr_fall_far   delay:0.05f];
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