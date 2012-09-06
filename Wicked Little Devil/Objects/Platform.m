//
//  Platform.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//
//  Platform types
//  -1, 0 = normal
//  1     = double jump (green)
//  2     = horizontal movement (pink)
//  3     = vertical movement (pink dark)
//  4     = bat/waving movement (blue)
//  5     = toggle button 
//  51    = toggle option 1
//  52    = toggle option 2
//  6     = breakable (yellow)
//  7     = timed - 5 seconds
//  71    = timed - 10 seconds
//  72    = timed - 15 seconds
//  73    = timed - 30 seconds

#import "Platform.h"

@implementation Platform
@synthesize health, type, animating, toggled;
@synthesize action_vertical_repeat, action_horizontal_repeat, action_fall;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        self.health = 2.0;
        self.animating = FALSE;
    
        [self setupActions];
        [self setupMovement];
    }
    return self;
}

- (void) intersectionCheck:(Player*)player platforms:(CCArray*)platforms
{
    if ( player.velocity.y < 0  && [self isActive])
    {
        float max_x = self.position.x - self.contentSize.width/2 - 10;
        float min_x = self.position.x + self.contentSize.width/2 + 10;
        float min_y = self.position.y + (self.contentSize.height+player.contentSize.height)/2 - 1;

        if(player.position.x > max_x &&
           player.position.x < min_x &&
           player.position.y > self.position.y &&
           player.position.y < min_y)
        {
            player.last_platform_touched = self;
            
            switch (self.tag)
            {
                case 1: // bigger jump
                    [player jump:player.jumpspeed*1.75];
                    break;
                case 5: // toggle
                    [player jump:player.jumpspeed];
                    for (Platform *tmpPlatform in platforms)
                    {
                        switch (tmpPlatform.tag)
                        {
                            case 51:
                                tmpPlatform.visible = player.toggled_platform;
                                break;
                            case 52:
                                tmpPlatform.visible = !player.toggled_platform; 
                                break;
                            default:
                                break;
                        }
                    }
                    player.toggled_platform = !player.toggled_platform;
                    break;
                case 6: 
                    [player jump:player.jumpspeed];
                    [self fall];
                    break;
                default:
                    [player jump:player.jumpspeed];
                    break;
            }
        }
    }
}

- (void) fall
{
    if ( !self.animating )
    {
        [self runAction:self.action_fall];
        self.animating = TRUE;
    }
}

- (void) die
{
    self.visible = FALSE;
    [self removeFromParentAndCleanup:YES];
}

- (BOOL) isActive
{
    return YES;
}

- (void) setupActions 
{
    id verticalmove = [CCMoveBy actionWithDuration:2 position:ccp(0,-100)];
    id verticalmove_opposite = [CCMoveBy actionWithDuration:2 position:ccp(0,100)];
    id horizontalmove = [CCMoveBy actionWithDuration:2 position:ccp(-100,0)];
    id horizontalmove_opposite = [CCMoveBy actionWithDuration:2 position:ccp(100,0)];
    id fallmove = [CCMoveBy actionWithDuration:0.5 position:ccp(0,-400)];
    id falldie  = [CCCallFunc actionWithTarget:self selector:@selector(die)];

    self.action_fall = [CCSequence actions:fallmove,falldie,nil];
    self.action_horizontal_repeat = [CCRepeatForever actionWithAction:[CCSequence actions:horizontalmove,horizontalmove_opposite,nil]];
    self.action_vertical_repeat = [CCRepeatForever actionWithAction:[CCSequence actions:verticalmove,verticalmove_opposite,nil]];
}

- (void) setupMovement
{
    if ( !self.animating ) 
    {       
        switch (self.tag)
        {
            default:
                break;
            case 2:
                [self runAction:self.action_vertical_repeat];
                self.animating = TRUE;
                break;
            case 3:
                [self runAction:self.action_horizontal_repeat];
                self.animating = TRUE;                
                break;
        }
    }
}

@end