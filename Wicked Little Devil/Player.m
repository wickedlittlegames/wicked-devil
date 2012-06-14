//
//  Player.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Player.h"

@implementation Player
@synthesize health, damage, velocity, stats, collected, bigcollected, jumpspeed;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        self.velocity = ccp ( 0 , 0 );
        self.jumpspeed = 5.5;
        
        self.stats = [NSUserDefaults standardUserDefaults];
        
        self.health = 100.0;
        self.damage = 0.5; 
        self.collected = 0;
        self.bigcollected = 0;
    }
    return self;
}

- (void) movement:(float)levelThreshold withGravity:(float)gravity
{
    self.velocity = ccp( self.velocity.x, self.velocity.y - gravity );
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

@end