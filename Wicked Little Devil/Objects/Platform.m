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
#import "Game.h"

@implementation Platform
@synthesize health, animating, toggled, end_fx_added;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        self.health = 1.0;
    }
    return self;
}


- (void) move
{
    if ( !self.animating )
    {
        if (self.tag == 2)
        {
            id verticalmove = [CCMoveBy actionWithDuration:2 position:ccp(0,-100)];
            id verticalmove_opposite = [CCMoveBy actionWithDuration:2 position:ccp(0,100)];
            
            CCAction *repeater = [CCRepeatForever actionWithAction:[CCSequence actions:verticalmove,verticalmove_opposite,nil]];
            [self runAction:repeater];
            
            self.animating = TRUE;
        }
        if (self.tag == 3)
        {
            id horizontalmove = [CCMoveBy actionWithDuration:2 position:ccp(-100,0)];
            id horizontalmove_opposite = [CCMoveBy actionWithDuration:2 position:ccp(100,0)];
            
            CCAction *repeater = [CCRepeatForever actionWithAction:[CCSequence actions:horizontalmove,horizontalmove_opposite,nil]];
            [self runAction:repeater];
            
            self.animating = TRUE;
        }
    }
}

- (void) isIntersectingPlayer:(Game*)game platforms:(CCArray*)platforms
{
    if ( self.visible && game.player.velocity.y < 0 )
    {
        if ( [self intersectCheck:game] )
        {
            switch (self.tag)
            {
                default: // NORMAL & MOVING PLATFORMS
                    [game.player jump:game.player.jumpspeed];
                    break;
                case 1: // DOUBLE JUMP: Causes player to jump 1.75* higher
                    [game.player jump:game.player.jumpspeed*1.75];
                    break;
                case 5: // TOGGLE SWITCH: Turns off and on platforms 51 & 52
                    [game.player jump:game.player.jumpspeed];
                    [self action:self.tag game:game platforms:platforms];
                    break;
                case 6: // BREAKABLE: Falls when the player jumps on it and has =||less than 0 damage
                    [game.player jump:game.player.jumpspeed];
                    self.health = self.health - game.player.damage;
                    if ( self.health <= 0 )
                    {
                        [self action:self.tag game:game platforms:platforms];
                    }
                    break;
                case 100: // End of level platform
                    [game.player jump:game.player.jumpspeed*1.5];
                    [self action:100 game:game platforms:platforms];
                    break;
            }
        }
    }
}

- (void) action:(int)action_id game:(Game*)game platforms:(CCArray*)platforms
{
    if (action_id == 5) // TOGGLEABLE 
    {
        for (Platform *tmpPlatform in platforms)
        {
            switch (tmpPlatform.tag)
            {
                case 51:
                    tmpPlatform.visible = game.player.toggled_platform;
                    break;
                case 52:
                    tmpPlatform.visible = !game.player.toggled_platform;
                    break;
                default:
                    break;
            }
        }
        game.player.toggled_platform = !game.player.toggled_platform;
    }
    
    if (action_id == 6 && !self.animating ) // BREAKABLE
    {
        self.animating = TRUE;
        
        id move = [CCMoveBy actionWithDuration:0.5 position:ccp(0,-600)];
        id ease = [CCEaseSineIn actionWithAction:move];
        id end  = [CCCallFunc actionWithTarget:self selector:@selector(end_action)];
        
        [self runAction:[CCSequence actions:ease, end, nil]];
    }
    
    if ( action_id == 100 && !self.animating )
    {
        self.animating = TRUE;
        
        id delay    = [CCDelayTime actionWithDuration:1.0];
        id endgame  = [CCCallBlock actionWithBlock:^(void)
                    {
                          game.isGameover = YES;
                          game.didWin = ( game.player.bigcollected >= 1 ? TRUE : FALSE );
                    }];
        
        [self runAction:[CCSequence actions:delay, endgame, nil]];
    }
}

- (void) end_action
{
    self.visible = FALSE;
    [self stopAllActions];
    [self removeAllChildrenWithCleanup:YES];
}

- (bool) intersectCheck:(Game*)game
{
    float max_x = self.position.x - self.contentSize.width/2 - 10;
    float min_x = self.position.x + self.contentSize.width/2 + 10;
    float min_y = self.position.y + (self.contentSize.height+game.player.contentSize.height)/2 - 4; // was /2 - 1;
    
    if(game.player.position.x > max_x &&
       game.player.position.x < min_x &&
       game.player.position.y > self.position.y &&
       game.player.position.y < min_y)
        return YES;
    
    return NO;
}

@end