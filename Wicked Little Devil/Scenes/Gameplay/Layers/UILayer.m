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
#import "FlurryAnalytics.h"

@implementation UILayer
@synthesize world, level, saves;

- (id) init {if( (self=[super init]) ) {} return self;}

- (void) setupItemsforGame:(Game*)game
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    self.world = game.world;
    self.level = game.level;
    self.saves = 0;
    
    if (game.user.bought_powerups && game.user.powerup == 0) self.saves = 1;
    if (game.user.bought_powerups && game.user.powerup == 1) self.saves = 2;
    if (game.user.bought_powerups && game.user.powerup == 2) self.saves = 3;
    if (game.user.bought_powerups && game.user.powerup == 3) self.saves = 10;
    
    CCLabelTTF *gamenumber = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i - %i",world,level] fontName:@"CrashLanding BB" fontSize:24];
    gamenumber.color = ccBLACK;
    [gamenumber setPosition:ccp(screenSize.width/2,screenSize.height - 15)];

    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        pause_bg = [CCSprite spriteWithFile:@"bg-pauseoverlay-iphone5.png"];
        pause_bg.position = ccp ( screenSize.width/2, screenSize.height/2 );
        [self addChild:pause_bg];
        pause_bg.visible = FALSE;
    } else {
        
        pause_bg = [CCSprite spriteWithFile:@"bg-pauseoverlay.png"];
        pause_bg.position = ccp ( screenSize.width/2, screenSize.height/2 );
        [self addChild:pause_bg];
        pause_bg.visible = FALSE;
    }
    
    if (screenBounds.size.height == 568) {
        CCSprite *uibg = [CCSprite spriteWithFile:@"bg-topbar-iphone5.png"];
        [uibg setPosition:ccp(screenSize.width/2, screenSize.height - 15)];
        [self addChild:uibg];
    } else {
        CCSprite *uibg = [CCSprite spriteWithFile:@"bg-topbar.png"];
        [uibg setPosition:ccp(screenSize.width/2, screenSize.height - 15)];
        [self addChild:uibg];
    }

    
    [self addChild:gamenumber];
    
    menu_second_chance = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-second-chance.png" selectedImage:@"btn-second-chance.png" block:^(id sender) {
        [FlurryAnalytics logEvent:[NSString stringWithFormat:@"Used Second Chance"]];
        [game.player jump:game.player.jumpspeed*2.5];
        self.saves--;
        
        if ( self.saves == 0 )
        {
            menu_second_chance.visible = NO;
        }
    }], nil];
    [menu_second_chance setPosition:ccp(screenSize.width/2,screenSize.height/2 - 200)];
    menu_second_chance.visible = FALSE;
    [self addChild:menu_second_chance];
    
    NSString *powerup_txt = @"";
    if ( !game.user.bought_powerups  )
    {
        powerup_txt = @"POWERUP: None Equipped";
    }
    else
    {
        
        NSArray *contentArray = [[NSDictionary
                                  dictionaryWithContentsOfFile:[[NSBundle mainBundle]
                                                                pathForResource:@"Powerups"
                                                                ofType:@"plist"]
                                  ] objectForKey:@"Powerups"];
        NSDictionary *powerup_dict = [contentArray objectAtIndex:game.user.powerup];
        powerup_txt = [NSString stringWithFormat:@"POWERUP: %@",[powerup_dict objectForKey:@"Name"]];
    }
    NSString *highscore = [NSString stringWithFormat:@"BEST: %i",[game.user getHighscoreforWorld:world level:level]];
    NSString *gamenumber_pause = [NSString stringWithFormat:@"%i - %i",world,level];
    CCLabelTTF *label_resume = [CCLabelTTF labelWithString:@"RESUME GAME" fontName:@"CrashLanding BB" fontSize:36];
    CCLabelTTF *label_levelselect = [CCLabelTTF labelWithString:@"BACK TO LEVEL SELECT" fontName:@"CrashLanding BB" fontSize:36];
    [label_resume setColor:ccc3(205, 51, 51)];
    [label_levelselect setColor:ccc3(205, 51, 51)];
    
    CCLabelTTF *label_gamenumber = [CCLabelTTF labelWithString:gamenumber_pause dimensions:CGSizeMake(screenSize.width -5, 30) hAlignment:kCCTextAlignmentLeft fontName:@"CrashLanding BB" fontSize:30.0f];
    CCLabelTTF *label_best = [CCLabelTTF labelWithString:highscore dimensions:CGSizeMake(screenSize.width - 7, 30) hAlignment:kCCTextAlignmentRight fontName:@"CrashLanding BB" fontSize:30.0f];
    CCLabelTTF *label_powerup = [CCLabelTTF labelWithString:powerup_txt dimensions:CGSizeMake(screenSize.width -5, 30) hAlignment:kCCTextAlignmentLeft fontName:@"CrashLanding BB" fontSize:30.0f];
    
    CCMenuItem *button_unpause = [CCMenuItemFont itemWithLabel:label_resume target:self selector:@selector(tap_unpause)];
    CCMenuItem *button_mainmenu = [CCMenuItemFont itemWithLabel:label_levelselect target:self selector:@selector(tap_mainmenu)];
    label_best.anchorPoint = ccp(0,0);
    label_gamenumber.anchorPoint = ccp(0,0);
    label_powerup.anchorPoint = ccp ( 0,0);
    [label_best setPosition:ccp(5, screenSize.height - 149)];
    [label_gamenumber setPosition:label_best.position];
    [label_powerup setPosition:ccp(label_gamenumber.position.x, label_gamenumber.position.y - 30)];
    pause_screen = [CCMenu menuWithItems:button_unpause, button_mainmenu, nil];
    [pause_screen setPosition:ccp(screenSize.width/2, screenSize.height/2 - 75)];
    [pause_screen alignItemsVerticallyWithPadding:-3];
    [pause_bg addChild:label_best];
    [pause_bg addChild:label_gamenumber];
    [pause_bg addChild:label_powerup];
    [pause_bg addChild:pause_screen];
    
    CCMenuItemImage *btn_reload = [CCMenuItemImage itemWithNormalImage:@"btn-pause.png" selectedImage:@"btn-pause.png" disabledImage:@"btn-pause.png" target:self selector:@selector(tap_reload)];
    CCMenuItemImage *btn_menu   = [CCMenuItemImage itemWithNormalImage:@"btn-gameplay-menu.png" selectedImage:@"btn-gameplay-menu.png" disabledImage:@"btn-gameplay-menu.png" target:self selector:@selector(tap_pause)];
    CCMenu *gameplay_menu = [CCMenu menuWithItems:btn_reload,btn_menu, nil];
    [gameplay_menu alignItemsHorizontallyWithPadding:20];
    gameplay_menu.position = ccp(screenSize.width - 48, screenSize.height - 16);
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
    [FlurryAnalytics logEvent:[NSString stringWithFormat:@"Reloaded the game"]];    
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
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
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
    if ( game.player.velocity.y < -8 && self.saves > 0 )
    {
        menu_second_chance.visible = YES;
    }
    else
    {
        menu_second_chance.visible = NO;
    }
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