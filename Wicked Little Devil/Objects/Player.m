//
//  Player.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Player.h"

@implementation Player
@synthesize health, damage, velocity, collected, bigcollected, jumpspeed, gravity, drag, modifier_gravity, score, time, jumps, deaths;
@synthesize last_platform_touched, controllable, toggled_platform, animating, falling, floating;
@synthesize anim_jump, anim_fall, anim_fallfar, anim_die;
@synthesize per_collectable, collectable_multiplier;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        self.velocity = ccp ( 0 , 0 );
        self.drag = 4;
        self.per_collectable = 10;
        self.collectable_multiplier = 1;
        self.scale = 1.25;
        self.jumpspeed = 5.5;
        if ([[UIScreen mainScreen] bounds].size.height == 568)
        {
            self.jumpspeed = 6.5;
        }
        self.gravity = 0.18;
        self.modifier_gravity = 0;
        self.health = 1.0;
        self.damage = 1.0;
        self.collected = 0;
        self.bigcollected = 0;
        self.score = 0;
        self.time = 0;
        self.jumps = 0;
        self.deaths = 0;
        self.last_platform_touched = NULL;
        
        // redo
        self.controllable = NO;
        self.toggled_platform = NO;
        self.animating = NO;
        self.falling = NO;
        
        [self setupAnimations];
        
    }
    return self;
}

- (void) move
{
    self.velocity = ccp( self.velocity.x, self.velocity.y - (self.gravity + self.modifier_gravity) );
    self.position = ccp((self.position.x), (self.position.y + self.velocity.y));
    
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
    if ( !self.animating )
    {
        self.animating = YES;
        
        CCCallFunc *stopAnimation = [CCCallFunc actionWithTarget:self selector:@selector(end_animate)];
        switch (animation_id)
        {
            case 1: // jump
                [self runAction:[CCSequence actions:[CCAnimate actionWithAnimation:self.anim_jump], stopAnimation, nil]];
                break;
            case 2:
                [self runAction:[CCSequence actions:[CCAnimate actionWithAnimation:self.anim_fall], nil]];
                break;
            case 3:
                [self runAction:[CCSequence actions:[CCAnimate actionWithAnimation:self.anim_fallfar], nil]];
                break;
            case 4:
               [self runAction:[CCSpawn actions:[CCAnimate actionWithAnimation:self.anim_die], [CCFadeOut actionWithDuration:0.5f], nil]];
                break;
        }
    }
}

- (void) end_animate
{
    self.animating = NO;
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
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"AnimDevil.plist"];
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"AnimDevil.png"];
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
    
    NSMutableArray *arr_die = [NSMutableArray array];
    for(int i = 1; i <= 6; ++i) {
        [arr_die addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"die%i.png", i]]];
    }
    
    self.anim_jump      = [CCAnimation animationWithSpriteFrames:arr_anim_jump  delay:0.05f];
    self.anim_fall      = [CCAnimation animationWithSpriteFrames:arr_fall       delay:0.05f];
    self.anim_fallfar   = [CCAnimation animationWithSpriteFrames:arr_fall_far   delay:0.05f];
    self.anim_die       = [CCAnimation animationWithSpriteFrames:arr_die        delay:0.01f];
}

- (void) setupPowerup:(int)powerup
{
    //  Lucky Devil I - 0
    //	Lucky Devil II - 1
    //	Lucky Devil III - 2
    //	Lucky Devil IV - 3
    //	Bouncy Devil I - 4
    //	Bouncy Devil II - 5
    //	Bouncy Devil III - 6
    //	Feather Devil I - 7
    //	Feather Devil II - 8
    //	Feather Devil III - 9
    //	Quick Devil I - 10
    //	Quick Devil II - 11
    //	Quick Devil III - 12
    //	Tough Devil I - 13
    //	Tough Devi II - 14
    //	Tough Devil III - 15
    //	Tough Devil IV - 16
    //	Winning Devil I - 17
    //	Winning Devil I - 18
    //	Winning Devil I - 19
    //	Rich Devil I - 20
    //	Rich Devil II - 21
    //	Rich Devil I3 - 22
    switch (powerup)
    {
        default: break;
        case 4: //	Bouncy Devil I
            self.jumpspeed += 0.5;
            break;
        case 5: //	Bouncy Devil II
            self.jumpspeed += 1.0;
            break;
        case 6: // Bouncy devil III
            self.jumpspeed += 1.5;
            break;
        case 7: // Feather Devil I
            self.damage = self.damage/2;
            break;
        case 8: // Feather Devil II
            self.damage = self.damage/3;
            break;
        case 9: // Feather Devil III
            self.damage = self.damage/4;
            break;
        case 10: // Quick Devil I
            self.drag = 4.5;
            break;
        case 11: // Quick Devil II
            self.drag = 4.75;
            break;
        case 12: // Quick Devil III
            self.drag = 5.5;
            break;
        case 13: // Tough Devil I
            self.health += 1;
            break;
        case 14: // Tough Devil II
            self.health += 2;
            break;
        case 15: // Tough Devil III
            self.health += 3;
            break;
        case 16: // Tough Devil IV
            self.health += 1000;
            break;
        case 17: // Winning Devil I
            self.per_collectable = 15;
            break;
        case 18: // Winning Devil II
            self.per_collectable = 20;
            break;
        case 19: // Winning Devil III
            self.per_collectable = 30;
            break;
        case 20: // Rich Devil I
            self.collectable_multiplier = 2;
            break;
        case 21: // Rich Devil II
            self.collectable_multiplier = 3;
            break;
        case 22: // Rich Devil III
            self.collectable_multiplier = 5;
            break;
        case 100: // dubstep devil
            break;
        case 101: // bubble pop
            break;
        case 102: // magenet soul
            break;
    }
}

@end