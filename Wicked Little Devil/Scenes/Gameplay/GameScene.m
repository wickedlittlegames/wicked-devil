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
#import "DetectivePlayerLayer.h"
#import "UILayer.h"
#import "GameLayer.h"

#import "Game.h"

@interface GameScene ()
- (id) initWithWorld:(int)w andLevel:(int)l withRestart:(BOOL)restart restartMusic:(BOOL)restartMusic;
@end

@implementation GameScene

#pragma mark === Init ===

+(CCScene *) sceneWithWorld:(int)w andLevel:(int)l isRestart:(BOOL)restart restartMusic:(BOOL)restartMusic
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    GameScene *layer = [[GameScene alloc] initWithWorld:w andLevel:l withRestart:restart restartMusic:restartMusic];
    [scene addChild:layer];

    // Show the scene
	return scene;
}

- (id) initWithWorld:(int)w andLevel:(int)l withRestart:(BOOL)restart restartMusic:(BOOL)restartMusic
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
        
        if ( !(w == 20) )
        {
            if ( ![SimpleAudioEngine sharedEngine].mute )
            {
                if ( restartMusic )
                {
                    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
                    if ( w == 11 )
                    {
                        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
                        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bg-main.aifc" loop:YES];
                    }
                    else
                    {
                        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:[NSString stringWithFormat:@"bg-loop%i.aifc",w] loop:YES];
                    }
                }
            }
        }
        
        self.isTouchEnabled = YES;
        
        NSString *file_level = [NSString stringWithFormat:@"world-%i-level-%i.ccbi",w,l];        
        
        CCMenuItem *launchButton = [CCMenuItemImage itemWithNormalImage:@"Begin-Button.png" selectedImage:@"Begin-Button.png" target:self selector:@selector(tap_launch)];
        menu = [CCMenu menuWithItems:launchButton, nil];
        menu.position = ccp ( 320/2, 30 );
        menu.opacity = 0.0f;
        [self addChild:menu z:10];
        
        game.isRestart = restart;
        
        layer_bg        = [BGLayer node];
        layer_fx        = [FXLayer node];
        layer_game      = (GameLayer*)[CCBReader nodeGraphFromFile:file_level  owner:self];

        if ( w == 20 || user.powerup == 105 )
        {
            layer_player    = [DetectivePlayerLayer node];
            [layer_player.player setupAnimationsDetective];
        }
        else
        {
            layer_player    = [PlayerLayer node];
            [layer_player.player setupAnimations];
        }
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
        game.pastScore = [user getHighscoreforWorld:w level:l];
        [game.player setupPowerup:user.powerup];
        [layer_ui setupItemsforGame:game];
        layer_game.world = w;
        layer_game.level = l;

        Trigger *trigger_top = [layer_game.triggers objectAtIndex:0];
        float top = trigger_top.position.y;
        
        game.timelimit = 30;
        if ( top > 2500 ) game.timelimit = 60;
        if ( top > 5000 ) game.timelimit = 90;
        
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
            [collab runAction: [CCSequence actions:ease, [CCCallBlock actionWithBlock:^(void) {game.isIntro = NO;}], nil]];
        }
        
        streak = [CCMotionStreak streakWithFade:0.5 minSeg:10 width:3 color:ccWHITE textureFilename:@"streak3.png"];
        [self addChild:streak];
        
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
                [self unschedule:@selector(countdown:)];
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
        if (diff > game.player.drag)  diff = game.player.drag;
        if (diff < -game.player.drag) diff = -game.player.drag;
        CGPoint new_player_location = CGPointMake(game.player.position.x + diff, game.player.position.y);
        game.player.position = new_player_location;
    }
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for( UITouch *touch in touches )
    {
        if (game.isIntro)
        {
            [collab stopAllActions];
            [collab setPosition:ccp(0,0)];
            game.isIntro = NO;
        }
        
        if ( game.player.floating && !game.player.controllable && game.user.powerup == 101 )
        {
            CGPoint location = [touch locationInView: [touch view]];
            game.touch = location;
            location = [[CCDirector sharedDirector] convertToGL:location];
            [streak setPosition:location];
            firstTouch = location;
        }
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for( UITouch *touch in touches ) 
    {
        if ( game.player.controllable )
        {
            CGPoint location = [touch locationInView: [touch view]];
            game.touch = location;
            location = [[CCDirector sharedDirector] convertToGL:location];
            [streak setPosition:location];
            
            lastTouch = location;
            float swipeLength = ccpDistance(firstTouch, lastTouch);
            if (firstTouch.y > lastTouch.y && swipeLength > 60 && !game.isStarted) {
                [self tap_launch];
            }
        }
    }
}

- (void)tap_launch
{
    if ( !game.isIntro )
    {
        game.isStarted = YES;
        game.isGameover = NO;
        game.player.controllable = YES;
        game.isIntro = NO;
        game.touch = game.player.position;
        menu.visible = NO;

        [game.player jump:game.player.jumpspeed];
        [self schedule:@selector(countdown:) interval:1.0f];
    }
}

- (void)countdown:(ccTime)dt
{
    game.player.time++;
}


@end
