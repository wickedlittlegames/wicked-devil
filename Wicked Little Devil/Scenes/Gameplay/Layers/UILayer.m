//
//  UILayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "UILayer.h"
#import "GameScene.h"
#import "DetectiveLevelSelectScene.h"
#import "LevelSelectScene.h"
#import "StartScene.h"

#import "Game.h"

@implementation UILayer

- (id) init {if( (self=[super init]) ) {} return self;}

- (void) setupItemsforGame:(Game*)game
{
    // Setup screen size, dimensions and game levels
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    self.world = game.world;
    self.level = game.level;
    NSString *txt_powerup       = (game.user.bought_powerups ? [NSString stringWithFormat:@"POWERUP: %@",[game.user getEquippedPowerup]] : @"POWERUP: None Equipped");
    NSString *txt_highscore     = [NSString stringWithFormat:@"BEST: %i",[game.user getHighscoreforWorld:self.world level:self.level]];
    NSString *txt_gamenumber    = [NSString stringWithFormat:@"%i - %i",self.world,self.level];
    
    // background and functionality sprites
    if ( game.world == 20 )
    {
        CCSprite *uibg = [CCSprite spriteWithFile:@"bg-topbar-bw.png"];
        [uibg setPosition:ccp(screenSize.width/2, screenSize.height - 15)];
        [self addChild:uibg];
    }
    else
    {
        CCSprite *uibg = [CCSprite spriteWithFile:@"bg-topbar.png"];
        [uibg setPosition:ccp(screenSize.width/2, screenSize.height - 15)];
        [self addChild:uibg];
    }
    
    // UI game number
    CCLabelTTF *gamenumber = [CCLabelTTF labelWithString:txt_gamenumber fontName:@"CrashLanding BB" fontSize:24];
    [gamenumber setPosition:ccp(screenSize.width/2,screenSize.height - 15)]; gamenumber.color = ccBLACK;
    [self addChild:gamenumber];
    
    
    // Menu selection options - reload and menu
    CCMenu *gameplay_menu = [CCMenu menuWithItems:
                             [CCMenuItemImage itemWithNormalImage:@"btn-pause.png" selectedImage:@"btn-pause.png" disabledImage:@"btn-pause.png" target:self selector:@selector(tap_reload)],
                             [CCMenuItemImage itemWithNormalImage:@"btn-gameplay-menu.png" selectedImage:@"btn-gameplay-menu.png" disabledImage:@"btn-gameplay-menu.png" target:self selector:@selector(tap_pause)],
                             nil];
    gameplay_menu.position = ccp(screenSize.width - 48, screenSize.height - 16);
    [gameplay_menu alignItemsHorizontallyWithPadding:20];
    [self addChild:gameplay_menu];
    
    // Sorting out the big collect icons, for gameplay and collection
    int x = 0;
    for (int i = 1; i <= 3; i++)
    {
        switch (i)
        {
            case 1: x = 15; break;
            case 2: x = 45; break;
            case 3: x = 75; break;
        }
        bigcollect_empty = [CCSprite spriteWithFile:@"icon-bigcollectable-empty.png"];
        bigcollect_empty.position = ccp ( x, screenSize.height - 16 );
        bigcollect_empty.tag = i;
        [self addChild:bigcollect_empty];
        
        if ( game.world == 20 )
        {
            bigcollect = [CCSprite spriteWithFile:@"icon-bigcollectable-bw.png"];
        }
        else
        {
            bigcollect = [CCSprite spriteWithFile:@"icon-bigcollectable.png"];
        }
        bigcollect.position = ccp ( x, screenSize.height - 16 );
        bigcollect.visible = FALSE;
        bigcollect.tag = i*10;
        [self addChild:bigcollect];
    }  
    
    // pause background and functionality sprites
    pause_bg = [CCSprite spriteWithFile:@"bg-pauseoverlay.png"];
    pause_bg.position = ccp ( screenSize.width/2, screenSize.height/2 );
    [self addChild:pause_bg]; pause_bg.visible = FALSE;
    
    CCLabelTTF *label_resume        = [CCLabelTTF labelWithString:@"RESUME GAME" fontName:@"CrashLanding BB" fontSize:36];
    CCLabelTTF *label_levelselect   = [CCLabelTTF labelWithString:@"BACK TO LEVEL SELECT" fontName:@"CrashLanding BB" fontSize:36];
    CCLabelTTF *label_gamenumber    = [CCLabelTTF labelWithString:txt_gamenumber dimensions:CGSizeMake(screenSize.width -5, 30) hAlignment:kCCTextAlignmentLeft fontName:@"CrashLanding BB" fontSize:30.0f];
    CCLabelTTF *label_best          = [CCLabelTTF labelWithString:txt_highscore dimensions:CGSizeMake(screenSize.width - 7, 30) hAlignment:kCCTextAlignmentRight fontName:@"CrashLanding BB" fontSize:30.0f];
    CCLabelTTF *label_powerup       = [CCLabelTTF labelWithString:txt_powerup dimensions:CGSizeMake(screenSize.width -5, 30) hAlignment:kCCTextAlignmentLeft fontName:@"CrashLanding BB" fontSize:30.0f];
    CCMenuItem *button_unpause  = [CCMenuItemFont itemWithLabel:label_resume target:self selector:@selector(tap_unpause)];
    CCMenuItem *button_mainmenu = [CCMenuItemFont itemWithLabel:label_levelselect block:^(id sender) {
        if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
        [[CCDirector sharedDirector] resume];
        if ( !(game.world == 20) )
        {
            if ( ![SimpleAudioEngine sharedEngine].mute )
            {
                [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
                [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bg-main.aifc" loop:YES];
            }
        }
        if ( game.world == 11 && game.level == 1)
        {
            [[CCDirector sharedDirector] replaceScene:[StartScene scene]];
        }
        else
        {
            if ( game.world == 20 )
            {
                [[CCDirector sharedDirector] replaceScene:[DetectiveLevelSelectScene sceneWithWorld:20]];
            }
            else
            {
                [[CCDirector sharedDirector] replaceScene:[LevelSelectScene sceneWithWorld:self.world]];                
            }
        }
    }];
        
    [label_resume       setColor:ccc3(205, 51, 51)];
    [label_levelselect  setColor:ccc3(205, 51, 51)];
    [label_best         setAnchorPoint:ccp(0,0)];
    [label_gamenumber   setAnchorPoint:ccp(0,0)];
    [label_powerup      setAnchorPoint:ccp(0,0)];
    [label_best         setPosition:ccp(5, screenSize.height - 149)];
    [label_gamenumber   setPosition:label_best.position];
    [label_powerup      setPosition:ccp(label_gamenumber.position.x, label_gamenumber.position.y - 30)];
    
    pause_screen = [CCMenu menuWithItems:button_unpause, button_mainmenu, nil];
    [pause_screen setPosition:ccp(screenSize.width/2, screenSize.height/2 - 75)];
    
    [pause_screen alignItemsVerticallyWithPadding:-3];
    [pause_bg addChild:label_best];
    [pause_bg addChild:label_gamenumber];
    [pause_bg addChild:label_powerup];
    [pause_bg addChild:pause_screen];
    
    
    // second chance menu and sprites
    // get the number of saves that the user is allowed, if any...
    self.saves = 0;
    if (game.user.bought_powerups && game.user.powerup == 0) self.saves = 1;
    if (game.user.bought_powerups && game.user.powerup == 1) self.saves = 2;
    if (game.user.bought_powerups && game.user.powerup == 2) self.saves = 3;
    if (game.user.bought_powerups && game.user.powerup == 3) self.saves = 10;
    
    menu_second_chance = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-second-chance.png" selectedImage:@"btn-second-chance.png" block:^(id sender) { [game.player jump:game.player.jumpspeed*2.5]; self.saves--; menu_second_chance.visible = !( self.saves == 0 ); }], nil];
    [menu_second_chance setPosition:ccp(screenSize.width/2,screenSize.height/2 - 200)];
    menu_second_chance.visible = FALSE;
    [self addChild:menu_second_chance];
    
    if ( !game.isRestart )
    {
        if ( self.world == 1 && self.level == 1 )
        {
            CCSprite *tip1 = [CCSprite spriteWithFile:@"tip-world-1-level-1.png"];
            [tip1 setPosition:ccp(screenSize.width/2, screenSize.height/2)];
            [self addChild:tip1];
            
            CCMenu *menu_tip1 = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"tip-ok.png" selectedImage:@"tip-ok.png" block:^(id sender){
                tip1.visible = NO;
            }], nil];
            [menu_tip1 setAnchorPoint:ccp(0,0)];
            [menu_tip1 setPosition:ccp(tip1.contentSize.width/2,27)];
            [tip1 addChild:menu_tip1];
        }
        
        if ( self.world == 1 && self.level == 2 )
        {
            CCSprite *tip1 = [CCSprite spriteWithFile:@"tip-world-1-level-2.png"];
            [tip1 setPosition:ccp(screenSize.width/2, screenSize.height/2)];
            [self addChild:tip1];
            
            CCMenu *menu_tip1 = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"tip-ok.png" selectedImage:@"tip-ok.png" block:^(id sender){
                tip1.visible = NO;
            }], nil];
            [menu_tip1 setAnchorPoint:ccp(0,0)];
            [menu_tip1 setPosition:ccp(tip1.contentSize.width/2,27)];
            [tip1 addChild:menu_tip1];
        }
        
        if ( self.world == 1 && self.level == 3 )
        {
            CCSprite *tip1 = [CCSprite spriteWithFile:@"tip-world-1-level-3.png"];
            [tip1 setPosition:ccp(screenSize.width/2, screenSize.height/2)];
            [self addChild:tip1];
            
            CCMenu *menu_tip1 = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"tip-ok.png" selectedImage:@"tip-ok.png" block:^(id sender){
                tip1.visible = NO;
            }], nil];
            [menu_tip1 setAnchorPoint:ccp(0,0)];
            [menu_tip1 setPosition:ccp(tip1.contentSize.width/2,27)];
            [tip1 addChild:menu_tip1];
        }

        if ( self.world == 1 && self.level == 5 ) // level 1 - 5 - double jump platforms
        {
            CCSprite *tip1 = [CCSprite spriteWithFile:@"tip-world-1-level-5.png"];
            [tip1 setPosition:ccp(screenSize.width/2, screenSize.height/2)];
            [self addChild:tip1];
            
            CCMenu *menu_tip1 = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"tip-ok.png" selectedImage:@"tip-ok.png" block:^(id sender){
                tip1.visible = NO;
            }], nil];
            [menu_tip1 setAnchorPoint:ccp(0,0)];
            [menu_tip1 setPosition:ccp(tip1.contentSize.width/2,27)];
            [tip1 addChild:menu_tip1];
        }

        if ( self.world == 1 && self.level == 17 ) // level 1 - 17 - enemies
        {
            CCSprite *tip1 = [CCSprite spriteWithFile:@"tip-world-1-level-17.png"];
            [tip1 setPosition:ccp(screenSize.width/2, screenSize.height/2)];
            [self addChild:tip1];
            
            CCMenu *menu_tip1 = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"tip-ok.png" selectedImage:@"tip-ok.png" block:^(id sender){
                tip1.visible = NO;
            }], nil];
            [menu_tip1 setAnchorPoint:ccp(0,0)];
            [menu_tip1 setPosition:ccp(tip1.contentSize.width/2,27)];
            [tip1 addChild:menu_tip1];
        }

        if ( self.world == 2 && self.level == 1 ) // level 2 - 1 - falling
        {
            CCSprite *tip1 = [CCSprite spriteWithFile:@"tip-world-2-level-1.png"];
            [tip1 setPosition:ccp(screenSize.width/2, screenSize.height/2)];
            [self addChild:tip1];
            
            CCMenu *menu_tip1 = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"tip-ok.png" selectedImage:@"tip-ok.png" block:^(id sender){
                tip1.visible = NO;
            }], nil];
            [menu_tip1 setAnchorPoint:ccp(0,0)];
            [menu_tip1 setPosition:ccp(tip1.contentSize.width/2,27)];
            [tip1 addChild:menu_tip1];
        }

        if ( self.world == 3 && self.level == 9 ) // level 3 - 9 - bubbles
        {
            CCSprite *tip1 = [CCSprite spriteWithFile:@"tip-world-3-level-9.png"];
            [tip1 setPosition:ccp(screenSize.width/2, screenSize.height/2)];
            [self addChild:tip1];
            
            CCMenu *menu_tip1 = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"tip-ok.png" selectedImage:@"tip-ok.png" block:^(id sender){
                tip1.visible = NO;
            }], nil];
            [menu_tip1 setAnchorPoint:ccp(0,0)];
            [menu_tip1 setPosition:ccp(tip1.contentSize.width/2,27)];
            [tip1 addChild:menu_tip1];
        }
        
        if ( self.world == 4 && self.level == 1 ) // level 3 - 9 - bubbles
        {
            CCSprite *tip1 = [CCSprite spriteWithFile:@"tip-world-4-level-1.png"];
            [tip1 setPosition:ccp(screenSize.width/2, screenSize.height/2)];
            [self addChild:tip1];
            
            CCMenu *menu_tip1 = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"tip-ok.png" selectedImage:@"tip-ok.png" block:^(id sender){
                tip1.visible = NO;
            }], nil];
            [menu_tip1 setAnchorPoint:ccp(0,0)];
            [menu_tip1 setPosition:ccp(tip1.contentSize.width/2,27)];
            [tip1 addChild:menu_tip1];
        }
        if ( self.world == 4 && self.level == 9 ) // level 3 - 9 - bubbles
        {
            CCSprite *tip1 = [CCSprite spriteWithFile:@"tip-world-4-level-9.png"];
            [tip1 setPosition:ccp(screenSize.width/2, screenSize.height/2)];
            [self addChild:tip1];
            
            CCMenu *menu_tip1 = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"tip-ok.png" selectedImage:@"tip-ok.png" block:^(id sender){
                tip1.visible = NO;
            }], nil];
            [menu_tip1 setAnchorPoint:ccp(0,0)];
            [menu_tip1 setPosition:ccp(tip1.contentSize.width/2,27)];
            [tip1 addChild:menu_tip1];
        }
    }
}

- (void) tap_reload
{
    [[CCDirector sharedDirector] replaceScene:[GameScene sceneWithWorld:self.world andLevel:self.level isRestart:TRUE restartMusic:NO]];
}

- (void) tap_pause
{
    [[CCDirector sharedDirector] pause];
    pause_bg.visible = TRUE;
}

- (void) tap_unpause
{
    [[CCDirector sharedDirector] resume];
    pause_bg.visible = FALSE;
}

- (void) tap_mainmenu
{
}

- (void) update:(Game*)game
{
    menu_second_chance.visible = (game.player.velocity.y < -8 && self.saves > 0 && game.player.position.y >= -80);
    
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

-(void)draw
{
    [super draw];
    
    if ( self.world == 20 )
    {
        int r = arc4random() % 100;
        if ( r >= 94 )
        {
            int tmpx = arc4random() % (int)[CCDirector sharedDirector].winSize.width;
            int tmpystart= arc4random() % (int)[CCDirector sharedDirector].winSize.height;
            int tmpyend = arc4random() % (int)[CCDirector sharedDirector].winSize.height;
            int tmpwidth = arc4random() % 2;
            ccDrawColor4B(255, 255, 255, 35);//Color of the line RGBA
            glLineWidth(tmpwidth); //Stroke width of the line
            ccDrawLine(ccp(tmpx, tmpystart), ccp(tmpx, tmpyend));
        }
    }
}


@end