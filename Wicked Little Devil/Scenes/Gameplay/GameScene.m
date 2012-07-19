//
//  GameScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//
#import "GameScene.h"

@implementation GameScene
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
        screenSize = [CCDirector sharedDirector].winSize;
        
        User *user = [[User alloc] init];
        game = [[Game alloc] init];        
        self.isTouchEnabled = YES;
        
        CCLOG(@"INIT: W: %i, L: %i", w, l);
        NSString *file_level = [NSString stringWithFormat:@"world-%i-level-%i.ccbi",w,l];
        
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
        
        game.player = layer_player.player;
        game.threshold = 0;
        game.user = user;
        game.world = w;
        game.level = l;
        [game.player setupPowerup:user.powerup];
        location_touch = game.player.position;
        
        [layer_game runAction:[CCFollow actionWithTarget:(game.player) worldBoundary:CGRectMake(0,0,320,1350)]];
        [layer_player runAction:[CCFollow actionWithTarget:(game.player) worldBoundary:CGRectMake(0,0,320,1350)]];        
        
        // INTRO
        //        id move = [CCMoveTo actionWithDuration:1.0 position:ccp(0,0)];
        //        id ease = [CCEaseSineOut actionWithAction:move];
        //        
        //        [self setPosition:ccp(0,(-self.contentSize.height - 200))];
        //        [self runAction: ease];
    }
	return self;
}

#pragma mark === Game Loop ===

- (void)update:(ccTime)dt 
{
    if ( ![[CCDirector sharedDirector] isPaused])
    {
        if ( game.isStarted )
        {
            [layer_game gameoverCheck:game];
            if ( !game.isGameover )
            {
                game.threshold = 340 - game.player.position.y;
                
                // Background Layer Interactions
                [layer_bg update:game.threshold];
                
                // Game Layer Interactions
                [layer_game update:game];
                
                // Player Layer Interactions
                [game.player movementwithGravity:0.18];
                
                // UI Layer Interactions
                [layer_ui update:game.player];
                
                // Control Interactions
                [self control_player];
            }
            else 
            {
                [self unschedule:@selector(update:)];
            }
        }
    }
}

#pragma mark === Controls and Taps ===

- (void) control_player
{
    float diff = location_touch.x - game.player.position.x;
    if (diff > 4)  diff = 4;
    if (diff < -4) diff = -4;
    CGPoint new_player_location = CGPointMake(game.player.position.x + diff, game.player.position.y);
    game.player.position = new_player_location;
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
    game.isStarted = YES;
    game.isGameover = NO;
    [self schedule:@selector(update:)];
    
    layer_player.player.velocity = ccp ( layer_player.player.velocity.x, layer_player.player.jumpspeed );
    menu.visible = NO;
}

@end
