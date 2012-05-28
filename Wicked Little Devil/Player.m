//
//  Player.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Player.h"

@implementation Player
@synthesize health, damage, velocity, stats;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        self.stats = [NSUserDefaults standardUserDefaults];
        //self.health = [self.stats floatForKey:@"health"];
        
        self.health = 100.0;
        self.damage = 1.0; 
        self.velocity = ccp ( 0 , 0 );
    }
    return self;
}

- (BOOL) isAlive 
{
    return ( self.health > 0.0 ? TRUE : FALSE );
}

@end