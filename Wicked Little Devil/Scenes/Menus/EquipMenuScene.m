//
//  EquipMenuScene.m
//  Wicked Little Devil
//
//  Created by Andy on 13/11/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//

#import "EquipMenuScene.h"
#import "EquipScene.h"
#import "EquipSpecialScene.h"
#import "ShopScene.h"
#import "CharacterShopScene.h"
#import "WorldSelectScene.h"

@implementation EquipMenuScene

+(CCScene *) scene
{
	CCScene *scene          = [CCScene node];
	EquipMenuScene *current     = [EquipMenuScene node];
	[scene addChild:current];
	return scene;
}

-(id) init
{
	if( (self=[super init]) )
    {
        user = [[User alloc] init];
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        NSString *font = @"CrashLanding BB";
        
        if ( [user isOnline] )
        {
            PHPublisherContentRequest *request = [PHPublisherContentRequest requestForApp:(NSString *)WDPHToken secret:(NSString *)WDPHSecret placement:(NSString *)@"equip_menu" delegate:(id)self];
            request.showsOverlayImmediately = NO;
            [request send];
        }
        
        CCMenuItemImage *btn_devil      = [CCMenuItemImage itemWithNormalImage:@"btn-devil-upgrades.png" selectedImage:@"btn-devil-upgrades.png" target:self selector:@selector(tap_devil)];
        CCMenuItemImage *btn_special    = [CCMenuItemImage itemWithNormalImage:@"btn-special-upgrades.png" selectedImage:@"btn-special-upgrades.png" target:self selector:@selector(tap_special)];
        CCMenuItemImage *btn_purchase   = [CCMenuItemImage itemWithNormalImage:@"btn-purchase-souls.png" selectedImage:@"btn-purchase-souls.png" target:self selector:@selector(tap_purchase)];
        CCMenuItemImage *btn_character   = [CCMenuItemImage itemWithNormalImage:@"btn-character-upgrades.png" selectedImage:@"btn-character-upgrades.png" target:self selector:@selector(tap_character)];
            
        CCMenu *menu_option             = [CCMenu menuWithItems:btn_devil,btn_special,btn_character,btn_purchase, nil];
//        CCMenu *menu_purchase           = [CCMenu menuWithItems:btn_purchase, nil];
//        CCMenu *menu_character           = [CCMenu menuWithItems:btn_character, nil];
        CCSprite *bg                    = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@", (IS_IPHONE5 ? @"bg-store-home-iphone5.png" : @"bg-store-iphone5.png" )]];
        CCMenu *menu_back               = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-back.png"    selectedImage:@"btn-back.png"       target:self selector:@selector(tap_back)], nil];
        lbl_user_collected              = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"SOULS: %i",user.collected] fontName:font fontSize:48];
        CCLabelTTF *lbl_title              = [CCLabelTTF labelWithString:@"STORE" fontName:font fontSize:68];
        
        [bg                 setPosition:ccp(screenSize.width/2,screenSize.height/2)];
        [menu_back          setPosition:ccp(25, 25)];
        [lbl_title          setPosition:ccp(screenSize.width/2, screenSize.height - 35)];
        [lbl_user_collected setPosition:ccp(screenSize.width/2, screenSize.height - 85)];
        [menu_option setPosition:ccp( screenSize.width/2, screenSize.height - 250)];
        [menu_option alignItemsVerticallyWithPadding:10];
        
        [self addChild:bg];
        [self addChild:menu_back z:1000];
        [self  addChild:lbl_title];
        [self addChild:lbl_user_collected z:100];
        [self addChild:menu_option];
    }
	return self;
}

- (void) tap_devil
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:0.2f scene:[EquipScene scene]]];
}

- (void) tap_special
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:0.2f scene:[EquipSpecialScene scene]]];
}

- (void) tap_purchase
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:0.2f scene:[ShopScene scene]]];
}

- (void) tap_character
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:0.2f scene:[CharacterShopScene scene]]];
}

- (void) tap_back
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [[CCDirector sharedDirector] popScene];
}

@end
