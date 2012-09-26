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
@synthesize animating, running, projectiles, fx;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        self.projectiles    = [CCArray arrayWithCapacity:100];
        self.fx             = [CCArray arrayWithCapacity:100];
    }
    return self;
}

- (void) move
{
    switch (self.tag)
    {
        default: break;
        case 1: // BAT: Wave motion up and down
			self.position = ccp(self.position.x + 0.5, self.position.y + sin((self.position.x+2)/10) * 0.5);
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
            case 5: // black hole, add drag to the controls
                if ( [self intersectCheck:game]) [self action:self.tag*2 game:game];
                //if ( [self radiusCheck:game] )      { [self action:self.tag game:game]; } else { game.player.drag = ccp(0,0); }
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
        case 3: // BUBBLE: Floats the player up
            self.running = YES;
            [self action_bubble_float:game];
            break;
        case 4: // ROCKET: Shoots rocket at target player area
            [self action_shoot_rocket:game];
            break;
        case 5: // !!TODO!! SPACE: Blackhole draws player in and transports player to a new location
            [self action_drag_player:game];
            break;
        case 10: // SPACE part 2: Transports player to a new location
            [self action_teleport_player:game];
            break;
        default: break;
    }
}

- (void) action_teleport_player:(Game*)game
{
    game.player.drag = ccp ( 0, 0 );
    game.player.velocity = ccp ( 0, 0 );
    [game.player setPosition:ccp(game.player.position.x + 150, game.player.position.y + 150)];
    // TODO: SEND ANIMATION OF PORTAL ENTRY [game.player animate:4];
    self.running = YES;
}

- (void) action_drag_player:(Game*)game
{
    float diff_x = game.player.position.x - [self worldBoundingBox].origin.x; // -100
    float diff_y = game.player.position.y - [self worldBoundingBox].origin.y; // 200
    float drag_factor = 50;
    
    CGPoint _drag = CGPointMake( diff_x/drag_factor, diff_y/drag_factor );
    game.player.drag = _drag;
}

- (void) action_bubble_float:(Game*)game
{
    self.running = YES;
    self.position = game.player.position;
    game.player.controllable = NO;
    game.player.velocity = ccp ( 0, 0 );
    

    // MOVE THE BUBBLE
    id floatup_player           = [CCMoveBy actionWithDuration:3 position:ccp(0,300)];
    id floatup_bubble           = [CCMoveBy actionWithDuration:3 position:ccp(0,300)];
    id end_action_bubble        = [CCCallFunc actionWithTarget:self selector:@selector(action_end_item)];
    id end_action_player        = [CCCallBlock actionWithBlock:^(void) { game.player.controllable = YES; }];
    
    [self runAction:[CCSequence actions:floatup_bubble, end_action_bubble, nil]];
    [game.player runAction:[CCSequence actions:floatup_player, end_action_player, nil]];
}


- (void) action_shoot_rocket:(Game*)game
{
    self.running = YES;
    
    // SHOOT A ROCKET AT THE PLAYER
    Projectile *projectile = [Projectile spriteWithFile:@"ingame-rocket.png"];
    [projectile setPosition:ccp([self worldBoundingBox].origin.x, [self worldBoundingBox].origin.y + 300)];
    
    EnemyFX *rocket_fx = [EnemyFX particleWithFile:@"RocketBlast.plist"];
    [rocket_fx setPosition:ccp([self worldBoundingBox].origin.x, [self worldBoundingBox].origin.y + 315)];
    rocket_fx.tag = 1111;

    [self addChild:rocket_fx];
    [self addChild:projectile];
    [self.projectiles addObject:projectile];
    
    // Determine offset of location to projectile
    int offX = [game.player worldBoundingBox].origin.x - projectile.position.x;
    int offY = [game.player worldBoundingBox].origin.y - projectile.position.y;
    
    // Determine where we wish to shoot the projectile to
    int realX = [[CCDirector sharedDirector] winSize].width + (projectile.contentSize.width/2);
    float ratio = (float) offY / (float) offX;
    int realY = (realX * ratio) + projectile.position.y;
    CGPoint realDest = ccp([self worldBoundingBox].origin.x, realY);
    
    // Determine the length of how far we're shooting
    int offRealX = realX - projectile.position.x;
    int offRealY = realY - projectile.position.y;
    float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
    float velocity = 300/1; // 480pixels/1sec
    float realMoveDuration = length/velocity;

    // Move projectile to actual endpoint
    [projectile runAction:[CCSequence actions:
                           [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
                           [CCCallFuncN actionWithTarget:self selector:@selector(action_end_projectile:)],
                           nil]];
    [rocket_fx runAction:[CCSequence actions:
                           [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
                           [CCCallFuncN actionWithTarget:self selector:@selector(action_end_projectile:)],
                           nil]];
}

- (void) action_angel_blast
{
    CCLOG(@"BLASTING");
    EnemyFX *tmp_fx = [EnemyFX particleWithFile:@"AngelBlast.plist"];
    [tmp_fx setPosition:[self worldBoundingBox].origin];
    [self.fx addObject:tmp_fx];
    
    if ( ![self getChildByTag:1234] )
    {
        CCLOG(@"ADDING ORIGINAL FX");
        [self addChild:tmp_fx z:10 tag:1234];
    }
    else
    {
        CCLOG(@"NOT ADDING - RESETTING");        
        [tmp_fx resetSystem];
    }
}

- (void) action_end_item
{
    self.visible = NO;
    self.running = NO;
}

- (void) action_end_projectile:(id)sender
{
    Projectile *sprite = (Projectile*)sender;
    self.visible = NO;
    [self.projectiles removeAllObjects];
    [sprite removeFromParentAndCleanup:YES];
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
    float radius = 100;
    float radiusTwo = 1;
    
    float distance = sqrt(xdif*xdif+ydif*ydif);
    
    if(distance <= radius+radiusTwo)
        return YES;
    
    return NO;
}

- (void) setupAnimations
{
    if ( self.tag == 1 || self.tag == 6 )
    {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"BatAnim.plist"];
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"BatAnim.png"];
    [self addChild:spriteSheet];
    
    NSMutableArray *arr_anim_flap = [NSMutableArray array];
    for(int i = 1; i <= 7; ++i) {
        [arr_anim_flap addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"bat-flap%i.png", i]]];
    }
    
    self.anim_flap = [CCAnimation animationWithSpriteFrames:arr_anim_flap  delay:0.05f];
    CCAction *repeater = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:self.anim_flap]];
    
    EnemyFX *tmp_fx = [EnemyFX particleWithFile:@"AngelBlast.plist"];
    id anim_angel_blast = [CCCallBlock actionWithBlock:^(void)
                           {
                               [tmp_fx setPosition:self.position];
                               [self.fx addObject:tmp_fx];
                               
                               if ( ![self getChildByTag:1234] )
                               {
                                   CCLOG(@"ADDING ORIGINAL FX");
                                   [self addChild:tmp_fx z:10 tag:1234];
                               }
                               else
                               {
                                   CCLOG(@"NOT ADDING - RESETTING");        
                                   [tmp_fx resetSystem];
                               }

                           }];
    id anim_angel_blast_stop = [CCCallBlock actionWithBlock:^(void)
                           {
                               [tmp_fx stopSystem];
                           }];
    id anim_angel_blast_delay = [CCDelayTime actionWithDuration:4];
    id anim_angel = [CCRepeatForever actionWithAction:[CCSequence actions:anim_angel_blast, anim_angel_blast_delay, anim_angel_blast_stop, anim_angel_blast_delay, nil]];
//    
    if ( self.tag == 1 && !self.animating )
    {
        [self runAction:repeater];
        self.animating = YES;
    }
//
    if ( self.tag == 6 && !self.animating )
    {
        CCLOG(@"RUNNING ANGEL ANIM");
        [self runAction:anim_angel];
        self.animating = YES;
    }
    }
}

@end
