//
//  UILayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "UILayer.h"
#import "GameScene.h"
#import "LevelSelectScene.h"

#import "Game.h"

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
    
    CCSprite *uibg = [CCSprite spriteWithFile:@"bg-topbar.png"];
    [uibg setPosition:ccp(screenSize.width/2, screenSize.height - 15)];
    [self addChild:uibg];

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
    gameplay_menu.position = ccp(screenSize.width - 45, screenSize.height - 16);
    [self addChild:gameplay_menu];
    
    int x_one = 15;
    int x_two = 45;
    int x_three = 75;
    int x = 0;
    
    for (int i = 1; i <= 3; i++)
    {
        switch (i)
        {
            case 1: x = x_one; break;
            case 2: x = x_two; break;
            case 3: x = x_three; break;
        }
        bigcollect_empty = [CCSprite spriteWithFile:@"icon-bigcollectable-empty.png"];
        bigcollect_empty.position = ccp ( x, screenSize.height - 16 );
        bigcollect_empty.tag = i;
        [self addChild:bigcollect_empty];
        
        bigcollect = [CCSprite spriteWithFile:@"icon-bigcollectable.png"];
        bigcollect.position = ccp ( x, screenSize.height - 16 );
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
        id scaleXAction = [CCScaleTo   actionWithDuration:.25f scaleX:self.scaleX scaleY:self.scaleY];
        id skewAction   = [CCSkewBy    actionWithDuration:.25f skewX:0.0f skewY:self.scaleY];

        CCSprite *tmp_sprite = (CCSprite*)[self getChildByTag:10];
        tmp_sprite.scaleX = 0.0f;
        tmp_sprite.skewX = 0.0f;
        tmp_sprite.visible = TRUE;
        [tmp_sprite runAction:[CCSpawn actions:scaleXAction, skewAction, nil]];
    }
    if ( game.player.bigcollected == 2 && ![self getChildByTag:20].visible )
    {
        id scaleXAction = [CCScaleTo   actionWithDuration:.25f scaleX:self.scaleX scaleY:self.scaleY];
        id skewAction   = [CCSkewBy    actionWithDuration:.25f skewX:0.0f skewY:self.scaleY];
        
        CCSprite *tmp_sprite = (CCSprite*)[self getChildByTag:20];
        tmp_sprite.scaleX = 0.0f;
        tmp_sprite.skewX = 0.0f;
        tmp_sprite.visible = TRUE;
        [tmp_sprite runAction:[CCSpawn actions:scaleXAction, skewAction, nil]];
    }
    if ( game.player.bigcollected == 3 && ![self getChildByTag:30].visible )
    {
        id scaleXAction = [CCScaleTo   actionWithDuration:.25f scaleX:self.scaleX scaleY:self.scaleY];
        id skewAction   = [CCSkewBy    actionWithDuration:.25f skewX:0.0f skewY:self.scaleY];
        
        CCSprite *tmp_sprite = (CCSprite*)[self getChildByTag:30];
        tmp_sprite.scaleX = 0.0f;
        tmp_sprite.skewX = 0.0f;
        tmp_sprite.visible = TRUE;
        [tmp_sprite runAction:[CCSpawn actions:scaleXAction, skewAction, nil]];
    }
}

@end
