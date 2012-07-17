//
//  GameScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//
#import "GameScene.h"

@implementation GameScene
@synthesize world, level; // ints
@synthesize started, won; // bools
@synthesize threshold; // floats

#pragma mark === Init ===

+(CCScene *) sceneWithWorld:(int)w andLevel:(int)l
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    GameScene *layer = [[GameScene alloc] initWithWorld:w andLevel:l];
    [scene addChild:layer];

    // Show the scene
	return scene;
}

- (id) initWithWorld:(int)w andLevel:(int)l
{
	if( (self=[super init]) ) 
    {
        user = [[User alloc] init];
        world = w;
        level = l;
        
        self.isTouchEnabled = YES;
        
        CCLOG(@"INIT: W: %i, L: %i", world, level);
        NSString *file_level = [NSString stringWithFormat:@"world-%i-level-%i.ccbi",world,level];
        
        CCMenuItem *launchButton = [CCMenuItemImage itemWithNormalImage:@"Start-button.png" selectedImage:@"Start-button.png" target:self selector:@selector(tap_launch:)];
        menu = [CCMenu menuWithItems:launchButton, nil];
        menu.position = ccp ( 320/2, 30 );
        [self addChild:menu];

        layer_bg        = [BGLayer node];
        layer_fx        = [FXLayer node];
        layer_game      = (GameLayer*)[CCBReader nodeGraphFromFile:file_level  owner:self];
        layer_player    = [PlayerLayer node];
        layer_ui        = [UILayer node];

        [layer_game createWorldWithObjects:[layer_game children]];
        
        [self addChild:layer_bg];
        [self addChild:layer_fx];
        [self addChild:layer_game];
        [self addChild:layer_player];
        [self addChild:layer_ui];
        
        player = layer_player.player;
        [player setupPowerup:user.powerup];
        
        location_touch = player.position;
        
        self.started = NO;
        [self schedule:@selector(update:)];
    }
	return self;
}

#pragma mark === Game Loop ===

- (void)update:(ccTime)dt 
{
    if ( ![[CCDirector sharedDirector] isPaused] && self.started )
    {
        if (player.isAlive && player.position.y > -20)
        {
            threshold = 340 - player.position.y;
            
            // Background Layer Interactions
            [layer_bg update:threshold];
            
            // Game Layer Interactions
            [layer_game update:player threshold:threshold];
            
            // Player Layer Interactions        
            [player movement:threshold withGravity:0.25];
            
            // UI Layer Interactions
            [layer_ui update:player];
            
            // Control Interactions
            [self control_player];
        }
        else 
        {
            CCLOG(@"GAMEOVER");
            player.health = 0;
            [self end];
        }
    }
}

- (void) end
{
    CCLOG(@"ENDED");
    self.started = FALSE;
    [self unschedule:@selector(update:)];
    
    if (player.isAlive && player.bigcollected > 0 && self.won) // Won the game
    {
        user.collected += player.collected;
        int score = player.score * player.bigcollected;
        int souls = player.bigcollected;
        
        [user setHighscore:score world:world level:level];
        [user setSouls:souls world:world level:level];
        
        if (level == user.levelprogress)
        {
            user.levelprogress = user.levelprogress + 1;
            if (user.levelprogress > LEVELS_PER_WORLD)
            {
                user.worldprogress = user.worldprogress + 1;
                user.levelprogress = 1;
            }
        }
        
        [user sync];
        
        [[CCDirector sharedDirector] replaceScene:[GameOverScene 
                                                   sceneWithScore:player.score 
                                                   timebonus:100 
                                                   bigs:player.bigcollected 
                                                   forWorld:world 
                                                   andLevel:level]];
    }
    else 
    {
        [[CCDirector sharedDirector] replaceScene:[GameOverScene 
                                                   sceneWithScore:player.score 
                                                   timebonus:100 
                                                   bigs:player.bigcollected 
                                                   forWorld:world 
                                                   andLevel:level]];
    }
}

#pragma mark === Controls and Taps ===

- (void) control_player
{
    float diff = location_touch.x - player.position.x;
    if (diff > 4)  diff = 4;
    if (diff < -4) diff = -4;
    CGPoint new_player_location = CGPointMake(player.position.x + diff, player.position.y);
    player.position = new_player_location;
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for( UITouch *touch in touches ) 
    {
        CGPoint location = [touch locationInView: [touch view]];
        location_touch = location;
    }
}

- (void)tap_launch:(id)sender
{
    layer_player.player.velocity = ccp ( layer_player.player.velocity.x, layer_player.player.jumpspeed );
    self.started = YES;
    menu.visible = NO;
}

@end
