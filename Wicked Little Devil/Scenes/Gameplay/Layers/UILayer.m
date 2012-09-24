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
@synthesize world, level;

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
    
    pause_bg = [CCSprite spriteWithFile:@"bg-pauseoverlay.png"];
    pause_bg.position = ccp ( screenSize.width/2, screenSize.height/2 );
    [self addChild:pause_bg];
    pause_bg.visible = FALSE;

    CCMenuItem *button_unpause = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"BACK TO GAME" fontName:@"CrashLanding BB" fontSize:20] target:self selector:@selector(tap_unpause)];
    CCMenuItem *button_mainmenu = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"MAIN MENU" fontName:@"CrashLanding BB" fontSize:20] target:self selector:@selector(tap_mainmenu)];
    pause_screen = [CCMenu menuWithItems:button_unpause, button_mainmenu, nil];
    [pause_screen setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    [pause_screen alignItemsVerticallyWithPadding:10];
    [self addChild:pause_screen];
    pause_screen.visible = FALSE;
    
    CCMenuItemImage *btn_reload = [CCMenuItemImage itemWithNormalImage:@"btn-pause.png" selectedImage:@"btn-pause.png" disabledImage:@"btn-pause.png" target:self selector:@selector(tap_reload)];
    CCMenuItemImage *btn_menu   = [CCMenuItemImage itemWithNormalImage:@"btn-gameplay-menu.png" selectedImage:@"btn-gameplay-menu.png" disabledImage:@"btn-gameplay-menu.png" target:self selector:@selector(tap_pause)];
    CCMenu *gameplay_menu = [CCMenu menuWithItems:btn_reload,btn_menu, nil];
    [gameplay_menu alignItemsHorizontallyWithPadding:10];
    gameplay_menu.position = ccp(screenSize.width - 40, screenSize.height - 25);
    [self addChild:gameplay_menu];
    
    int x_mod = 25;
    for (int i = 1; i <= 3; i++)
    {
        bigcollect_empty = [CCSprite spriteWithFile:@"icon-bigcollectable-empty.png"];
        bigcollect_empty.position = ccp ( x_mod * i, screenSize.height - 25 );
        bigcollect_empty.tag = i;
        [self addChild:bigcollect_empty];
        
        bigcollect = [CCSprite spriteWithFile:@"icon-bigcollectable.png"];
        bigcollect.position = ccp ( x_mod * i, screenSize.height - 25 );
        bigcollect.visible = FALSE;
        bigcollect.tag = i*10;
        [self addChild:bigcollect];
    }
}

- (void) tap_reload
{
    [[CCDirector sharedDirector] replaceScene:[GameScene sceneWithWorld:self.world andLevel:self.level isRestart:TRUE]];
}

- (void) tap_pause
{
    [[CCDirector sharedDirector] pause];
    pause_screen.visible = TRUE;
    pause_bg.visible = TRUE;
}

- (void) tap_unpause
{
    [[CCDirector sharedDirector] resume];
    pause_screen.visible = FALSE;
    pause_bg.visible = FALSE;
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
    if ( game.player.bigcollected == 1 && ![self getChildByTag:10].visible )
    {
        [self getChildByTag:10].visible = TRUE;
    }
    if ( game.player.bigcollected == 2 && ![self getChildByTag:20].visible )
    {
        [self getChildByTag:20].visible = TRUE;
    }
    if ( game.player.bigcollected == 3 && ![self getChildByTag:30].visible )
    {
        [self getChildByTag:30].visible = TRUE;
    }
}

@end
