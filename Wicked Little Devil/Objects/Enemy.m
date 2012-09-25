//
//  Enemy.m
//  Wicked Little Devil
// 
//  Created by Andrew Girvan on 30/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
// 1  = Bat
// 2  = Mine
// 3  = Bubble
// 4  = Rockets
// 5  = blackholes
// 6  = Angel Laser of Death (from the top and sides and bottom)

#import "Game.h"
#import "FXLayer.h"

@implementation Enemy
@synthesize animating, running;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        //[self setupAnimations];
    }
    return self;
}

- (void) move
{
    switch (self.tag)
    {
        default: break;
        case 1: // BAT: Wave motion up and down
			self.position = ccp(self.position.x + 2, self.position.y + sin((self.position.x+2)/10) * 15);
            if (self.position.x > [[CCDirector sharedDirector] winSize].width+40) self.position = ccp(-50, self.position.y);
            break;
    }
}

- (void) isIntersectingPlayer:(Game*)game
{
    if ( self.visible && !self.running )
    {
        switch (self.tag)
        {
            default: // simple interaction, kill player
                if ( [self intersectCheck:game] )   [self action:self.tag game:game];
                break;
            case 4:  // rocket blast
                if ( [self radiusCheck:game] )      [self action:self.tag game:game];
                break;
        }
    }
}

- (void) action:(int)action_id game:(Game*)game
{
    switch(action_id)
    {
        case 1: // BAT: Jump ontop, or die below
            if ( game.player.velocity.y > 0 ) game.player.health--;
            else [game.player jump:game.player.jumpspeed];
            self.visible = NO;
            break;
        case 2: // MINE: Any time touched, blows up
            [game.fx start:0 position:[self worldBoundingBox].origin];
            game.player.health--;
            self.visible = NO;
            break;
        case 3: // !!TODO!! BUBBLE: Floats the player up
            self.running = YES;
            break;
        case 4: // !!TODO!! ROCKET: Shoots rocket at target player area
            self.running = YES;
            break;
        case 5: // !!TODO!! PLANET: TBA
            break;
        case 6: // !!TODO!! ANGEL: TBA
            break;
        default: break;
    }
}

- (bool) intersectCheck:(Game*)game
{
    CGSize enemy_size       = self.contentSize;
    CGPoint enemy_pos       = self.position;
    CGSize player_size      = game.player.contentSize;
    CGPoint player_pos      = game.player.position;
    
    float max_x = enemy_pos.x - enemy_size.width/2 - 10;
    float min_x = enemy_pos.x + enemy_size.width/2 + 10;
    float min_y = enemy_pos.y + (enemy_size.height+player_size.height)/2 - 1;
    
    if(player_pos.x > max_x &&
       player_pos.x < min_x &&
       player_pos.y > enemy_pos.y &&
       player_pos.y < min_y)
        return YES;

    return NO;
}

- (bool) radiusCheck:(Game*)game
{
    float xdif = self.position.x - game.player.position.x;
    float ydif = self.position.y - game.player.position.y;
    float radius = 70;
    float radiusTwo = 1;
    
    float distance = sqrt(xdif*xdif+ydif*ydif);
    
    if(distance <= radius+radiusTwo)
        return YES;
    
    return NO;
}

- (void) setupAnimations
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"BatAnim.plist"];
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"BatAnim.png"];
    [self addChild:spriteSheet];
    
    NSMutableArray *arr_anim_flap = [NSMutableArray array];
    for(int i = 1; i <= 7; ++i) {
        [arr_anim_flap addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"bat_flap%i.png", i]]];
    }
    
    self.anim_flap = [CCAnimation animationWithSpriteFrames:arr_anim_flap  delay:0.05f];
    CCAction *repeater = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:[CCAnimate actionWithAnimation:self.anim_flap]]];
    
    if ( self.tag == 1 && self.animating )
    {
        [self runAction:repeater];
    }
}

@end
