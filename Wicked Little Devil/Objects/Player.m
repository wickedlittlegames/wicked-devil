//
//  Player.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Player.h"

@implementation Player
@synthesize health, damage, velocity, stats, collected, bigcollected, jumpspeed, modifier_gravity, score;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        self.velocity = ccp ( 0 , 0 );
        self.jumpspeed = 7.5;
        self.scaleY = 0.5;
        self.scaleX = 0.8;
        
        
        self.stats = [NSUserDefaults standardUserDefaults];
        
        self.health = 10.0;
        self.damage = 1.0;
        self.collected = 0;
        self.bigcollected = 0;
        self.modifier_gravity = 0;
        self.score = 0;
    }
    return self;
}

- (void) movement:(float)levelThreshold withGravity:(float)gravity
{
    self.velocity = ccp( self.velocity.x, self.velocity.y - (gravity + modifier_gravity) );
    if (levelThreshold < 0)
    {
        self.position = ccp(self.position.x + self.velocity.x, self.position.y + (self.velocity.y + levelThreshold));
    }
    else 
    {
        self.position = ccp(self.position.x, self.position.y + self.velocity.y);
    }
}

- (BOOL) isAlive 
{
    return ( self.health > 0.0 ? TRUE : FALSE );
}

- (void) jump:(float)speed
{
    self.velocity = ccp (self.velocity.x, speed);
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
            // Bounce on the floor, never die from falling
            // Hit enemies from below
            // quicker reactions (modifier for move diff)
            // collectables are worth twice as much!
            // moneybags - normal platforms give 100 points per bounce but are destroyed
            // slow motion - slow down the timer
            // tiny enemies
            // fun card - change devil to different colour
            // fun card - comedy "boing" sound when jumping
            // fun card - 
    }
}

- (void) killObject:(id)sender
{
    
}

@end