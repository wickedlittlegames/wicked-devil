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
@synthesize health, animating, toggled, end_fx_added, dead;

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
    if (self.tag == 2 || self.tag == 67)
    {
        id verticalmove = [CCMoveBy actionWithDuration:2 position:ccp(0,100)];
        id verticalmove_opposite = [CCMoveBy actionWithDuration:2 position:ccp(0,-100)];
        
        CCAction *repeater = [CCRepeatForever actionWithAction:[CCSequence actions:verticalmove,verticalmove_opposite,nil]];
        [self runAction:repeater];
        
        self.animating = TRUE;
    }
    if (self.tag == 3 || self.tag == 66)
    {
        id horizontalmove = [CCMoveBy actionWithDuration:2 position:ccp(-100,0)];
        id horizontalmove_opposite = [CCMoveBy actionWithDuration:2 position:ccp(100,0)];
        
        CCAction *repeater = [CCRepeatForever actionWithAction:[CCSequence actions:horizontalmove,horizontalmove_opposite,nil]];
        [self runAction:repeater];
        
        self.animating = TRUE;
    }
    if (self.tag == 33 || self.tag == 663)
    {
        id horizontalmove = [CCMoveBy actionWithDuration:2 position:ccp(100,0)];
        id horizontalmove_opposite = [CCMoveBy actionWithDuration:2 position:ccp(-100,0)];
        
        CCAction *repeater = [CCRepeatForever actionWithAction:[CCSequence actions:horizontalmove,horizontalmove_opposite,nil]];
        [self runAction:repeater];
        
        self.animating = TRUE;
    }
}

- (void) playAudio:(int)platform_id game:(Game*)game
{
    if ( ![SimpleAudioEngine sharedEngine].mute )
    {
        if ( game.user.powerup == 100 )
        {
            // 1, 2, 3, 4 ,5
            int r = arc4random_uniform(5) + 1;
            
            [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"dubstep_%i",r] pitch:1 pan:1 gain:0.5];
        }
        else
        {
            switch (platform_id)
            {
                default:
                    [[SimpleAudioEngine sharedEngine] playEffect:@"jump1.caf" pitch:1 pan:1 gain:0.5];
                    break;
                case 1:
                    [[SimpleAudioEngine sharedEngine] playEffect:@"jump4.caf" pitch:1 pan:1 gain:0.5];
                    break;
                case 66:
                    [[SimpleAudioEngine sharedEngine] playEffect:@"jump2.caf" pitch:1 pan:1 gain:0.5];
                    break;
                case 663:
                    [[SimpleAudioEngine sharedEngine] playEffect:@"jump2.caf" pitch:1 pan:1 gain:0.5];
                    break;
            }
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
                default: // NORMAL & MOVING PLATFORMS]
                    [self playAudio:self.tag game:game];
                    
                    game.player.jumps++;
                    
                    [game.player jump:game.player.jumpspeed];
                    break;
                case 1: // DOUBLE JUMP: Causes player to jump 1.75* higher
                    [self playAudio:self.tag game:game];
                    game.player.jumps++;
                    
                    [game.player jump:game.player.jumpspeed*1.95];
                    break;
                case 5: // TOGGLE SWITCH: Turns off and on platforms 51 & 52
                    [self playAudio:self.tag game:game];
                    game.player.jumps++;
                                        
                    [game.player jump:game.player.jumpspeed];
                    [self action:self.tag game:game platforms:platforms];
                    break;
                case 6: // BREAKABLE: Falls when the player jumps on it and has =||less than 0 damage
                    [self playAudio:self.tag game:game];
                    game.player.jumps++;
                                        
                    [game.player jump:game.player.jumpspeed];
                    self.health = self.health - game.player.damage;
                    if ( self.health <= 0 )
                    {
                        [self action:self.tag game:game platforms:platforms];
                    }
                    break;
                case 66: // BREAKABLE: Falls when the player jumps on it and has =||less than 0 damage
                    [self playAudio:self.tag game:game];
                    game.player.jumps++;
                                        
                    self.animating = NO;
                    [game.player jump:game.player.jumpspeed];
                    self.health = self.health - game.player.damage;
                    if ( self.health <= 0 )
                    {
                        [self action:self.tag game:game platforms:platforms];
                    }
                    break;
                case 663: // BREAKABLE: Falls when the player jumps on it and has =||less than 0 damage
                    [self playAudio:self.tag game:game];
                    game.player.jumps++;
                    
                    
                    self.animating = NO;                    
                    [game.player jump:game.player.jumpspeed];
                    self.health = self.health - game.player.damage;
                    if ( self.health <= 0 )
                    {
                        [self action:self.tag game:game platforms:platforms];
                    }
                    break;
                case 100: // End of level platform
                    if ( game.player.bigcollected > 0 )
                    {
                        if ( ![SimpleAudioEngine sharedEngine].mute ) [[SimpleAudioEngine sharedEngine] playEffect:@"complete.caf"];
                    }
                    game.player.jumps++;
                                        
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
        
        id move = [CCMoveBy actionWithDuration:0.5 position:ccp(0,-400)];
        id ease = [CCEaseExponentialIn actionWithAction:move];
        id end  = [CCCallFunc actionWithTarget:self selector:@selector(end_action)];
        
        [self runAction:[CCSequence actions:ease, end, nil]];
    }
    if (action_id == 66 && !self.animating ) // BREAKABLE
    {
        self.animating = TRUE;
        
        id move = [CCMoveBy actionWithDuration:0.5 position:ccp(0,-400)];
        id ease = [CCEaseExponentialIn actionWithAction:move];
        id end  = [CCCallFunc actionWithTarget:self selector:@selector(end_action)];
        
        [self runAction:[CCSequence actions:ease, end, nil]];
    }
    if (action_id == 663 && !self.animating ) // BREAKABLE
    {
        self.animating = TRUE;
        
        id move = [CCMoveBy actionWithDuration:0.5 position:ccp(0,-400)];
        id ease = [CCEaseExponentialIn actionWithAction:move];
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