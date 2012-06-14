//
//  Enemy.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 30/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Enemy.h"
#import "CCNode+CoordHelpers.h"

@implementation Enemy
@synthesize type, active, speed_x, speed_y, health, damage;

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
        
        NSLog(@"Theres an enemy!");
    }
    return self;
}

- (BOOL) isIntersectingPlayer:(Player*)player
{
    switch (self.tag)
    {
        case 0:
            break;
        default:
            if (player.velocity.y < 0 && CGRectIntersectsRect([player worldBoundingBox], [self worldBoundingBox]) && self.visible == TRUE)
            {
                [self damageFromPlayer:player];
                if ( self.health <= 0 )
                {
                    self.active = FALSE;
                    self.visible = FALSE;
                }
                [player jump:player.jumpspeed];
                return TRUE;
            }
            else if (player.velocity.y > 0 && CGRectIntersectsRect([player worldBoundingBox], [self worldBoundingBox]) && self.visible == TRUE)
            {
                [self damageToPlayer:player];
                return TRUE;
            }
            break;
    }
    return FALSE;
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


@end
