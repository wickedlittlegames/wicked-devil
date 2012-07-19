//
//  Platform.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Platform.h"

@implementation Platform
@synthesize health, type, animating,original_position,active, flipped;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        self.health = 1.0;
        self.animating = FALSE;
        self.active = TRUE;
        self.original_position = ccp(self.position.x, self.position.y);
        self.flipped = FALSE;
    }
    return self;
}

- (void) intersectionCheck:(Player*)player
{

    if ( player.velocity.y < 0  && self.visible)
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
        default:
            [player jump:player.jumpspeed];
            break;
    }
}





- (void) setupHVMovement
{
    if (self.tag == 0)
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
//    if (self.tag == 1)
//    {
//        if ( self.animating == FALSE )
//        {
//            id horizontalmove = [CCMoveBy actionWithDuration:2 position:ccp(-100,0)];
//            id horizontalmove_opposite = [CCMoveBy actionWithDuration:2 position:ccp(100,0)];
//            
//            CCAction *repeater = [CCRepeatForever actionWithAction:[CCSequence actions:horizontalmove,horizontalmove_opposite,nil]];
//            [self runAction:repeater];
//            
//            self.animating = TRUE;
//        }
//    }
    if (self.tag == 10)
    {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        int direction = (self.flipped ? -1 : 1);  
        self.position = ccp (self.position.x + direction, self.position.y);

        if ( self.position.x >= (screenSize.width - self.contentSize.width/2) && self.flipped == FALSE )
        {
            self.flipped = TRUE;
        }
        if ( self.position.x <= 0 + (self.contentSize.width/2) )
        {
            self.flipped = FALSE;
        }
    }
}

@end