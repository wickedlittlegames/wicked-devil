//
//  Player.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Player.h"

@implementation Player
@synthesize health, damage, velocity, stats, collected, jumpspeed;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        self.velocity = ccp ( 0 , 0 );
        self.position = ccp( 320/2 , 480/2 );
        
        self.stats = [NSUserDefaults standardUserDefaults];
        
        self.health = 100.0;
        self.damage = 1.0; 
        self.collected = 0;
        self.jumpspeed = 8.5;
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

- (void) jump
{
    self.velocity = ccp (self.velocity.x, self.jumpspeed);
}

@end