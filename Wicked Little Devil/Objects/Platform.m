//
//  Platform.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//
//  Platform types
//  -1, 0 = normal
//  1     = double jump
//  2     = horizontal movement
//  3     = vertical movement
//  4     = bat/waving movement
//  5     = toggle button
//  51    = toggle option 1
//  52    = toggle option 2
//  6     = breakable
//  7     = timed - 5 seconds
//  71    = timed - 10 seconds
//  72    = timed - 15 seconds
//  73    = timed - 30 seconds

#import "Platform.h"

@implementation Platform
@synthesize health, type, animating,original_position,active, flipped;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        self.health = 2.0;
        self.animating = FALSE;
        self.active = TRUE;
        self.original_position = ccp(self.position.x, self.position.y);
        self.flipped = FALSE;
    }
    return self;
}

- (void) intersectionCheck:(Player*)player
{

    if ( player.velocity.y < 0  && self.visible && self.health > 0)
    {
        CGSize platform_size = self.contentSize;
        CGPoint platform_pos = self.position;
        CGSize player_size     = player.contentSize; 
        CGPoint player_pos     = player.position;
        
        float max_x = platform_pos.x - platform_size.width/2 - 10;
        float min_x = platform_pos.x + platform_size.width/2 + 10;
        float min_y = platform_pos.y + (platform_size.height+player_size.height)/2 - 1;

        if(player_pos.x > max_x &&
           player_pos.x < min_x &&
           player_pos.y > platform_pos.y &&
           player_pos.y < min_y)
        {
            [self doAction:self.tag player:player];
            
        }
    }

}

- (void) doAction:(int)tag player:(Player*)player
{
    switch (self.tag)
    {
        case 0:
            [player jump:player.jumpspeed];
            break;
        case 1: 
            [player jump:player.jumpspeed*1.75];
            break;
        case 6: 
            self.health--;
            if ( self.health != 0 )
            {
                [player jump:player.jumpspeed*1.75];
            }
            else 
            {
                [self fall];
            }
        default:
            [player jump:player.jumpspeed];
            break;
    }
}

- (void) showDamage
{
    // swap the image
}

- (void) fall
{
    if ( self.animating == FALSE )
    {
        id fallmove = [CCMoveBy actionWithDuration:0.5 position:ccp(0,-400)];
        id falldie  = [CCCallFunc actionWithTarget:self selector:@selector(die)];
        [self runAction:[CCSequence actions:fallmove,falldie,nil]];
        self.animating = TRUE;
    }
}

- (void) die
{
    self.visible = FALSE;
    [self removeFromParentAndCleanup:YES];
}

- (void) setupHVMovement
{
    if (self.tag == 2)
    {
        if ( self.animating == FALSE )
        {
            id verticalmove = [CCMoveBy actionWithDuration:2 position:ccp(0,-100)];
            id verticalmove_opposite = [CCMoveBy actionWithDuration:2 position:ccp(0,100)];
            
            CCAction *repeater = [CCRepeatForever actionWithAction:[CCSequence actions:verticalmove,verticalmove_opposite,nil]];
            [self runAction:repeater];
            
            self.animating = TRUE;
        }
    }
    if (self.tag == 3)
    {
        if ( self.animating == FALSE )
        {
            id horizontalmove = [CCMoveBy actionWithDuration:2 position:ccp(-100,0)];
            id horizontalmove_opposite = [CCMoveBy actionWithDuration:2 position:ccp(100,0)];
            
            CCAction *repeater = [CCRepeatForever actionWithAction:[CCSequence actions:horizontalmove,horizontalmove_opposite,nil]];
            [self runAction:repeater];
            
            self.animating = TRUE;
        }
    }
    if ( self.tag == 4 )
    {
        self.position = ccp(self.position.x + 0.5, self.position.y + sin((self.position.x+2)/10) * 2); 
        if (self.position.x > [[CCDirector sharedDirector] winSize].width+70) self.position = ccp(-70, self.position.y);
    }
}

@end