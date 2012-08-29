//
//  Enemy.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 30/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//
//
//   -1 - Rat STATIC
//   0 - Bat
//   1 - Water
//   2 - Preist
//   3 - Meteors (take from little devil)
//   4 - Angels

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
        
        NSLog(@"Theres an enemy!");
    }
    return self;
}

- (BOOL) isIntersectingPlayer:(Player*)player
{
    if ( player.velocity.y < 0  && self.visible && self.health > 0)
    {
        CGSize enemy_size = self.contentSize;
        CGPoint enemy_pos = self.position;
        CGSize player_size     = player.contentSize; 
        CGPoint player_pos     = player.position;
        
        float max_x = enemy_pos.x - enemy_size.width/2 - 10;
        float min_x = enemy_pos.x + enemy_size.width/2 + 10;
        float min_y = enemy_pos.y + (enemy_size.height+player_size.height)/2 - 1;
        
        if(player_pos.x > max_x &&
           player_pos.x < min_x &&
           player_pos.y > enemy_pos.y &&
           player_pos.y < min_y)
        {
            [self doAction:self.tag player:player];
        }
    }
    return FALSE;
}

- (void) doAction:(int)tag player:(Player*)player
{
    switch (tag)
    {
        // rat, bat, meteors
        default:
            [self damageToPlayer:player];
            break;
        // water
        case 1:
            // move player up then pop (animation)
            break;
        // stop intersection of preists
        case 2:
            break;
        // stop intersections of angels
        case 4:
            break;
    }
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
