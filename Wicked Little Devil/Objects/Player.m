//
//  Player.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Player.h"

@implementation Player

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
            self.jumpspeed = 6;
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
        self.halocollected = 0;
        self.last_platform_touched = NULL;
        
        // redo
        self.controllable = NO;
        self.toggled_platform = NO;
        self.animating = NO;
        self.falling = NO;
    }
    return self;
}

- (void) move
{
    self.velocity = ccp( self.velocity.x, self.velocity.y - (self.gravity + self.modifier_gravity) );
    self.position = ccp((self.position.x), (self.position.y + self.velocity.y));
    
    if ( self.velocity.y < 0 && self.velocity.y > -5)
    {
        self.falling = NO;
        [self animate:2];
    }

    if ( self.velocity.y < -8.5  && !self.falling )
    {
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

- (void) setupAnimationsDetective
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"AnimDetectiveDevil.plist"];
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"AnimDetectiveDevil.png"];
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

- (void) setupCharacter:(int)character
{
    switch(character)
    {
        case 0: //detective
            [self setupAnimationsDetective];
        break;
//            
//        case 1: // wicked little
//        {
//            [self setupAnimationsDetective];
//        }
//        break;
//            
//        case 2: // super devil
//        {
//            [self setupAnimationsDetective];
//        }
//        break;
//            
//        case 3: // zombie
//        {
//            [self setupAnimationsDetective];
//        }
//        break;
//            
//        case 4: // ninja
//        {
//            [self setupAnimationsDetective];
//        }
//        break;
//            
//        case 5: // pirate
//        {
//            [self setupAnimationsDetective];
//        }
//        break;
    }
}


- (void) setupPowerup:(int)powerup
{
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
        case 100: // boundplatform 
            break;
        case 101: // bubble pop
            break;
        case 102: // magenet soul
            break;
        case 103: // magenet soul
            break;
        case 104: // it's a dud!
            break;
        case 105: // detective outfit
            [self setupAnimationsDetective];
            break;
    }
}

@end