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
        [self addChild:menu z:10];

        layer_bg        = [BGLayer node];
        layer_fx        = [FXLayer node];
        layer_game      = (GameLayer*)[CCBReader nodeGraphFromFile:file_level  owner:self];
        layer_player    = [PlayerLayer node];
        layer_ui        = [UILayer node];

        [layer_bg createWorldSpecificBackgrounds:w]; 
        [layer_game createWorldWithObjects:[layer_game children]];
        
        collab = [CCLayer node];
        [self addChild:collab];
        
        [collab addChild:layer_bg];
        [collab addChild:layer_fx];
        [collab addChild:layer_game];
        [collab addChild:layer_player];
        [self addChild:layer_ui];
        
        game.player = layer_player.player;
        game.threshold = 0;
        game.user = user;
        game.world = w;
        game.level = l;
        game.fx = layer_fx;
        [game.player setupPowerup:user.powerup];
        
        Trigger *trigger_top = [layer_game.triggers objectAtIndex:0];
        float top = trigger_top.position.y + 100;
        
        [layer_game runAction:[CCFollow actionWithTarget:(game.player) worldBoundary:CGRectMake(0,0,320,top)]];
        [layer_player runAction:[CCFollow actionWithTarget:(game.player) worldBoundary:CGRectMake(0,0,320,top)]];
        
        // INTRO
        if ( !game.isIntro )
        {
            game.isIntro = YES;
            float time_for_anim = top/400;

            id move = [CCMoveTo actionWithDuration:time_for_anim position:ccp(0,0)];
            id ease = [CCEaseSineOut actionWithAction:move];
        
            [collab setPosition:ccp(0,-top)];
            [collab runAction: ease];
        }
        
        [self schedule:@selector(update:)];
    }
	return self;
}

#pragma mark === Game Loop ===

- (void)update:(ccTime)dt 
{
    if ( ![[CCDirector sharedDirector] isPaused])
    {
        // Game Layer Interactions
        [layer_game update:game];

        if ( game.isStarted && !game.isGameover )
        {
            [layer_game gameoverCheck:game];
            if ( !game.isGameover )
            {
                game.threshold = 340 - game.player.position.y;
                
                // FX Layer Interactions
                [layer_fx update:game.threshold];
                
                // Player Layer Interactions
                if ( game.player.controllable ) [game.player movementwithGravity:0.18];
                
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
    if ( game.player.controllable )
    {
        float diff = location_touch.x - game.player.position.x;
        if (diff > 4)  diff = 4;
        if (diff < -4) diff = -4;
        CGPoint new_player_location = CGPointMake(game.player.position.x + diff, game.player.position.y);
        game.player.position = new_player_location;
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for( UITouch *touch in touches ) 
    {
        if (game.isIntro)
        {
            [collab stopAllActions];
            [collab setPosition:ccp(0,0)];
            game.isIntro = NO;
        }
        
        if ( game.player.controllable )
        {
            CGPoint location = [touch locationInView: [touch view]];
            location_touch = location;
        }
    }
}

- (void)tap_launch:(id)sender
{ 
    game.isStarted = YES;
    game.isGameover = NO;
    game.player.controllable = YES;
    game.isIntro = NO;
    location_touch = game.player.position;
    menu.visible = NO;
    
    [game.player jump:game.player.jumpspeed];
}

@end
