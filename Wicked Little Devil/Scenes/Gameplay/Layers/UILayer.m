//
//  UILayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "UILayer.h"
#import "GameScene.h"

@implementation UILayer
@synthesize world, level, lbl_bigcollected;

- (id) init
{
	if( (self=[super init]) ) 
    {

    }
	return self;
}

- (void) setupItemsforGame:(Game*)game
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    self.world = game.world;
    self.level = game.level;
    
    lbl_bigcollected = [CCLabelTTF labelWithString:@"0/3" dimensions:CGSizeMake(screenSize.width, 30) hAlignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:22];
    lbl_bigcollected.position = ccp (screenSize.width/2, screenSize.height - 30);
    [self addChild:lbl_bigcollected];
    
    CCMenuItem *button_restart = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"RESTART" fontName:@"CrashLanding BB" fontSize:14] target:self selector:@selector(tap_restart)];
    CCMenu *menu_restart = [CCMenu menuWithItems:button_restart, nil];
    [menu_restart  setPosition:ccp(screenSize.width - 50, screenSize.height - 25 )];
    
    CCMenuItem *button_menu = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"MENU" fontName:@"CrashLanding BB" fontSize:14] target:self selector:@selector(tap_pause)];
    CCMenu *menu_menu = [CCMenu menuWithItems:button_menu, nil];
    [menu_menu  setPosition:ccp(screenSize.width - 120, screenSize.height - 25 )];    
    
    CCMenuItem *button_unpause = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"BACK TO GAME" fontName:@"CrashLanding BB" fontSize:20] target:self selector:@selector(tap_unpause)];
    CCMenuItem *button_mainmenu = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"MAIN MENU" fontName:@"CrashLanding BB" fontSize:20] target:self selector:@selector(tap_mainmenu)];
    pause_screen = [CCMenu menuWithItems:button_unpause, button_mainmenu, nil];
    [pause_screen setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    [pause_screen alignItemsVerticallyWithPadding:10];
    [self addChild:pause_screen];
    pause_screen.visible = FALSE;
    
    [self addChild:menu_restart z:100];
    [self addChild:menu_menu z:100];
}

- (void) tap_restart
{
    [[CCDirector sharedDirector] replaceScene:[GameScene sceneWithWorld:self.world andLevel:self.level isRestart:TRUE]];
}

- (void) tap_pause
{
    [[CCDirector sharedDirector] pause];
    pause_screen.visible = TRUE;
}

- (void) tap_unpause
{
    [[CCDirector sharedDirector] resume];
    pause_screen.visible = FALSE;    
}

- (void) tap_mainmenu
{
    [[CCDirector sharedDirector] resume];
    if ( ![SimpleAudioEngine sharedEngine].mute )
    {
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bg-main.wav" loop:YES];
    }
    [[CCDirector sharedDirector] replaceScene:[LevelSelectScene sceneWithWorld:world]];
}

- (void) update:(Game*)game
{
    [lbl_bigcollected setString:[NSString stringWithFormat:@"%i/3",game.player.bigcollected]];
}

@end
