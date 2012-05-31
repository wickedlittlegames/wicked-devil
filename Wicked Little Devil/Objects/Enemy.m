//
//  Enemy.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 30/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Enemy.h"


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
    }
    return self;
}

- (void) movementWithThreshold:(float)levelThreshold
{
    if ( self.active )
    {
        switch (self.tag)
        {
            // Horizontal Movement (right to left)
            case 0:
                self.position = ccp ( self.position.x + self.speed_x, self.position.y );
                break;
                
            // Horizontal with wiggle (Bat style)
            case 1:
                self.position = ccp(self.position.x + self.speed_x, self.position.y + sin((self.position.x+2)/10) * 15); 
                if (self.position.x > 480+70) self.position = ccp(-30, self.position.y);
                break;
                
            // Vertical (down from up)
            case 2:
                self.position = ccp (self.position.x, self.position.y + self.speed_y);
                break;
            
            // Fallback (as in, default).
            default:
                // don't move anywhere
                break;
        }
        if ( levelThreshold < 0 && !(self.tag == 2) )
        {
            self.position = ccp(self.position.x, self.position.y + levelThreshold);
        }
    }
}

- (void) activateNearPlayerPoint:(Player*)player
{
    // TODO: Needs work
}

- (BOOL) isIntersectingPlayer:(Player*)player
{
    if (player.velocity.y > 0)
    {
        [self damageFromPlayer:player];
        if ( self.health <= 0 )
        {
            self.active = FALSE;
            self.visible = FALSE;
        }
        return TRUE;
    }
    else if (player.velocity.y < 0)
    {
        [self damageToPlayer:player];
        return TRUE;
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

@end
