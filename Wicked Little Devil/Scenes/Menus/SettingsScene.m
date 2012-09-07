//
//  SettingsScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 13/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "SettingsScene.h"


@implementation SettingsScene

+(CCScene *) scene
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    // Grab the layers
	SettingsScene *current = [SettingsScene node];
    
    // Fill the scene
	[scene addChild:current];
    
    // Show the scene
	return scene;
}

-(id) init
{
    if( (self=[super init]) ) {
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        NSString *font = @"Marker Felt";
        int fontsize = 18;
        
        user = [[User alloc] init];
        
        // Normal Menu
        CCMenuItem *btn_music = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"MUTE MUSIC" fontName:font fontSize:fontsize] target:self selector:@selector(tap_mute_music)];
        CCMenuItem *btn_sound = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"MUTE SOUND" fontName:font fontSize:fontsize] target:self selector:@selector(tap_mute_sound)];
        CCMenuItem *btn_fblogout = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"LOGOUT FACEBOOK" fontName:font fontSize:fontsize] target:self selector:@selector(tap_fblogout)];
        CCMenu *menu = [CCMenu menuWithItems:btn_music,btn_sound,btn_fblogout, nil];
        [menu alignItemsVerticallyWithPadding:10];
        menu.position = ccp ( screenSize.width/2, 420 );
        [self addChild:menu z:100];
        
        // Cheat Menu
        CCMenuItem *btn_cheat1 = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"CHEAT: 1 MILLION SOULS" fontName:font fontSize:fontsize] target:self selector:@selector(tap_cheat1)];
        CCMenuItem *btn_cheat2 = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"CHEAT: UNLOCK ALL WORLDS" fontName:font fontSize:fontsize] target:self selector:@selector(tap_cheat2)];
        CCMenuItem *btn_cheat3 = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"CHEAT: UNLOCK ALL POWERUPS" fontName:font fontSize:fontsize] target:self selector:@selector(tap_cheat3)];
        CCMenuItem *btn_reset = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"RESET USER" fontName:font fontSize:fontsize] target:self selector:@selector(tap_reset)];
        CCMenuItem *btn_dummygameover = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"FAKE GAME OVER" fontName:font fontSize:fontsize] target:self selector:@selector(tap_fake_gameover)];
        CCMenuItem *btn_dummylevel = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"DUMMY LEVEL" fontName:font fontSize:fontsize] target:self selector:@selector(tap_dummy_level)];        
        CCMenu *menu_cheat = [CCMenu menuWithItems:btn_cheat1,btn_cheat2,btn_cheat3, btn_reset,btn_dummygameover, btn_dummylevel, nil];
        [menu_cheat alignItemsVerticallyWithPadding:10];
        menu_cheat.position = ccp ( screenSize.width/2, 240 );
        [self addChild:menu_cheat z:100];

        CCMenuItem *back = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"BACK" fontName:font fontSize:fontsize] target:self selector:@selector(tap_back)];
        CCMenu *menu_back = [CCMenu menuWithItems:back, nil];
        menu_back.position = ccp ( screenSize.width - 80, 10 );
        [self addChild:menu_back z:100];

    }
    return self;
}

- (void) tap_back
{
    [[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene]];
}

- (void) tap_mute_music 
{
    CCLOG(@"TODO: MUTE MUSIC SLIDER/TICK");
}

- (void) tap_mute_sound
{
    CCLOG(@"TODO: MUTE SOUND SLIDER/TICK");    
}

- (void) tap_fblogout
{
    [PFUser logOut];
}

- (void) tap_cheat1 
{
    user.collected = 1000000;
    [user sync];
}

- (void) tap_cheat2
{
    user.worldprogress = 6;
    user.levelprogress = 12;
    [user sync];
}

- (void) tap_cheat3
{
    CCLOG(@"UNLOCK ALL POWERUPS");
}

- (void) tap_reset
{
    [user reset];
}

- (void) tap_fake_gameover
{
    CCLOG(@"FAKE A GAMEOVER SCREEN");
    [[CCDirector sharedDirector] replaceScene:[GameOverScene sceneWithScore:1200 timebonus:300 bigs:3 forWorld:1 andLevel:1]];
}

- (void) tap_dummy_level
{
    CCLOG(@"START AN EXTREME LEVEL WITH ALL THE STUFF IN IT BUT ITS NOT POSSIBLE TO DIE");
    [[CCDirector sharedDirector] replaceScene:[GameScene sceneWithWorld:1 andLevel:3 isRestart:FALSE]];
}

@end
