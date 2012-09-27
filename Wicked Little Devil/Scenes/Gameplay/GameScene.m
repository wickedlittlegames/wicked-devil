//
//  GameScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//
#import "GameScene.h"
#import "GameOverScene.h"
#import "CCBReader.h"

#import "BGLayer.h"
#import "PlayerLayer.h"
#import "UILayer.h"
#import "GameLayer.h"

#import "Game.h"

@implementation GameScene
@synthesize threshold; // floats

#pragma mark === Init ===

+(CCScene *) sceneWithWorld:(int)w andLevel:(int)l isRestart:(BOOL)restart
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    GameScene *layer = [[GameScene alloc] initWithWorld:w andLevel:l withRestart:restart];
    [scene addChild:layer];

    // Show the scene
	return scene;
}

- (id) initWithWorld:(int)w andLevel:(int)l withRestart:(BOOL)restart
{
	if( (self=[super init]) ) 
    {
        screenSize = [CCDirector sharedDirector].winSize;
        
        if ( restart )
        {
            CCLayerColor *whiteflash = [CCLayerColor layerWithColor:ccc4(225, 225, 225, 225)];
            [self addChild:whiteflash z:1000];
            
            [whiteflash runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.4f], nil]];
        }
        
        User *user = [[User alloc] init];
        game = [[Game alloc] init];

        if ( ![SimpleAudioEngine sharedEngine].mute )
        {
            [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bg-loop1.wav" loop:YES];
        }
        
        self.isTouchEnabled = YES;
        
        CCLOG(@"INIT: W: %i, L: %i", w, l);
//        NSString *file_level = [NSString stringWithFormat:@"world-%i-level-%i.ccbi",w,l];        
        NSString *file_level = [NSString stringWithFormat:@"world-%i-level-2.ccbi",w];
        
        CCMenuItem *launchButton = [CCMenuItemImage itemWithNormalImage:@"Begin-Button.png" selectedImage:@"Begin-Button.png" target:self selector:@selector(tap_launch:)];
        menu = [CCMenu menuWithItems:launchButton, nil];
        menu.position = ccp ( 320/2, 30 );
        menu.opacity = 0.0f;
        [self addChild:menu z:10];

        layer_bg        = [BGLayer node];
        layer_fx        = [FXLayer node];
        layer_game      = (GameLayer*)[CCBReader nodeGraphFromFile:file_level  owner:self];
        layer_player    = [PlayerLayer node];
        layer_ui        = [UILayer node];

        [layer_bg createWorldSpecificBackgrounds:w]; 
        [layer_game createWorldWithObjects:[layer_game children]];
        
        collab = [CCLayer node];
        [self addChild:layer_bg];        
        [self addChild:collab];
        [collab addChild:layer_game];
        [collab addChild:layer_fx];        
        [collab addChild:layer_player];
        [self addChild:layer_ui];
        
        game.player = layer_player.player;
        game.user = user;
        game.world = w;
        game.level = l;
        game.fx = layer_fx;
        [game.player setupPowerup:user.powerup];
        [layer_ui setupItemsforGame:game];   
        layer_game.world = w;
        layer_game.level = l;
        
        Trigger *trigger_top = [layer_game.triggers objectAtIndex:0];
        float top = trigger_top.position.y;
        
        [layer_game runAction:[CCFollow actionWithTarget:(game.player) worldBoundary:CGRectMake(0,0,320,top)]];
        [layer_player runAction:[CCFollow actionWithTarget:(game.player) worldBoundary:CGRectMake(0,0,320,top)]];
        
        // INTRO
        if ( !game.isIntro && !restart)
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
                // Player Layer Interactions
                if ( game.player.controllable ) [game.player move];
                
                // UI Layer Interactions
                [layer_ui update:game];
                
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
        float diff = game.touch.x - game.player.position.x;
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
            game.touch = location;
        }
    }
}

- (void)tap_launch:(id)sender
{ 
    game.isStarted = YES;
    game.isGameover = NO;
    game.player.controllable = YES;
    game.isIntro = NO;
    game.touch = game.player.position;
    menu.visible = NO;
    
    [game.player jump:game.player.jumpspeed];
}

@end
