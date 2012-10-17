//
//  WorldSelectScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 11/09/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "WorldSelectScene.h"
#import "LevelSelectScene.h"
#import "StartScene.h"
#import "ShopScene.h"
#import "EquipScene.h"
#import "User.h"
#import "FlurryAnalytics.h"

@implementation WorldSelectScene

+(CCScene *) scene
{
	CCScene *scene              = [CCScene node];
	WorldSelectScene *current   = [WorldSelectScene node];
	[scene addChild:current];
	return scene;
}

-(id) init
{
	if( (self=[super init]) )
    {
        // 	Useable variables for this scene
        user            = [[User alloc] init];
        screenSize      = [CCDirector sharedDirector].winSize;
        font            = @"CrashLanding BB";
        fontsize        = 36;
        worlds          = [NSMutableArray arrayWithCapacity:100];
        int big_collectables_total  = (LEVELS_PER_WORLD * CURRENT_WORLDS_PER_GAME) * 3;
        int big_collectables_player = [user getSoulsforAll];
        
        // Object creation area
        CCSprite *icon_bigcollectable   = [CCSprite spriteWithFile:@"icon-bigcollectable-med.png"];
        CCSprite *icon_collectable      = [CCSprite spriteWithFile:@"ui-collectable.png"];  icon_collectable.scale = 2;      
        CCLabelTTF *label_bigcollected  = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i/%i", big_collectables_player, big_collectables_total] dimensions:CGSizeMake(screenSize.width - 80, 30) hAlignment:kCCTextAlignmentRight fontName:font fontSize:32];
        CCLabelTTF *label_collected     = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", user.collected] dimensions:CGSizeMake(screenSize.width - 80, 30) hAlignment:kCCTextAlignmentRight fontName:font fontSize:32];
        CCMenu *menu_back               = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-back.png"    selectedImage:@"btn-back.png"       target:self selector:@selector(tap_back:)], nil];
        CCMenu *menu_equip              = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-powerup.png" selectedImage:@"btn-powerup.png"    target:self selector:@selector(tap_equip:)],nil];
        CCMenu *menu_store              = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-store-world.png" selectedImage:@"btn-store-world.png"    target:self selector:@selector(tap_store:)],nil];
        
        // Positioning
        [menu_back              setPosition:ccp(25, 25)];
        [menu_equip             setPosition:ccp(25, screenSize.height - 25)];
        [menu_store             setPosition:ccp(70, screenSize.height - 25)];
        [icon_bigcollectable    setPosition:ccp(screenSize.width - 20, screenSize.height - 20)];
        [icon_collectable       setPosition:ccp(screenSize.width - 20, icon_bigcollectable.position.y - 26)];
        [label_bigcollected     setPosition:ccp(screenSize.width/2, screenSize.height - 22)];
        [label_collected        setPosition:ccp(screenSize.width/2, label_bigcollected.position.y - 24)];
        
        // Add world layers to the scroller
        [worlds addObject:[self hell]];
        [worlds addObject:[self underground]];
        [worlds addObject:[self ocean]];
        scroller = [[CCScrollLayer alloc] initWithLayers:worlds widthOffset: 0];
        [scroller selectPage:user.cache_current_world-1];
        
        // Put the children to the screen
        [self addChild:scroller];
        [self addChild:menu_equip];
        [self addChild:menu_back];
        [self addChild:icon_bigcollectable];
        [self addChild:icon_collectable];
        [self addChild:label_bigcollected];
        [self addChild:label_collected];
        
        if ( user.isOnline ) { [self addChild:menu_store]; }
    }
	return self;
}

#pragma mark TAPS

- (void) tap_world:(CCMenuItemFont*)sender
{
    [FlurryAnalytics logEvent:[NSString stringWithFormat:@"Player played World: %i", sender.tag]];
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    user.cache_current_world = sender.tag;
    [user sync_cache_current_world];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[LevelSelectScene sceneWithWorld:sender.tag]]];
}

- (void) tap_equip:(id)sender
{
    [FlurryAnalytics logEvent:[NSString stringWithFormat:@"Player visited EquipStore"]];
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[EquipScene scene]]];
}

- (void) tap_store:(id)sender
{
    [FlurryAnalytics logEvent:[NSString stringWithFormat:@"Player visited IAPStore"]];
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[ShopScene scene]]];
}

- (void) tap_back:(CCMenuItem*)sender
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[StartScene scene]]];
}

#pragma mark WORLDS

- (CCLayer*) hell
{
    CCLayer *layer          = [CCLayer node];
    CCSprite *bg            = [CCSprite spriteWithFile:(IS_IPHONE5 ? @"bg-world-hell-new-iphone5.png" : @"bg-world-hell-new.png")];
    CCMenuItemImage *button = [CCMenuItemImage itemWithNormalImage:@"btn-start.png" selectedImage:@"btn-start.png" disabledImage:@"btn-start.png" target:self selector:@selector(tap_world:)];
    CCMenu *menu            = [CCMenu menuWithItems:button, nil]; button.tag = 1; button.opacity = 0; button.scale *= 3; button.isEnabled = ( user.worldprogress >= button.tag ); button.isEnabled = ( button.tag <= CURRENT_WORLDS_PER_GAME );
    
    [bg   setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    [menu setPosition:ccp(screenSize.width/2, screenSize.height/2)];

    [layer addChild:bg];
    [layer addChild:menu];
    
    return layer;
}

- (CCLayer*) underground
{
    CCLayer *layer          = [CCLayer node];
    CCSprite *bg            = [CCSprite spriteWithFile:(IS_IPHONE5 ? @"bg-world-underground-new-iphone5.png" : @"bg-world-underground-new.png")];
    CCMenuItemImage *button = [CCMenuItemImage itemWithNormalImage:@"btn-start.png" selectedImage:@"btn-start.png" disabledImage:@"btn-start.png" target:self selector:@selector(tap_world:)];
    CCMenu *menu            = [CCMenu menuWithItems:button, nil]; button.tag = 2; button.opacity = 0; button.scale *= 3; button.isEnabled = ( user.worldprogress >= button.tag ); button.isEnabled = ( button.tag <= CURRENT_WORLDS_PER_GAME );
    
    [bg   setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    [menu setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    
    [layer addChild:bg];
    [layer addChild:menu];
    
    return layer;
}

- (CCLayer*) ocean
{
    CCLayer *layer          = [CCLayer node];
    CCSprite *bg            = [CCSprite spriteWithFile:(IS_IPHONE5 ? @"bg-coming-soon.png" : @"bg-coming-soon.png")];
    CCMenuItemImage *button = [CCMenuItemImage itemWithNormalImage:@"btn-start.png" selectedImage:@"btn-start.png" disabledImage:@"btn-start.png" target:self selector:@selector(tap_world:)];
    CCMenu *menu            = [CCMenu menuWithItems:button, nil]; button.tag = 3; button.opacity = 0; button.scale *= 3; button.isEnabled = ( user.worldprogress >= button.tag ); button.isEnabled = ( button.tag <= CURRENT_WORLDS_PER_GAME );
    
    [bg   setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    [menu setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    
    [layer addChild:bg];
    [layer addChild:menu];
    
    return layer;
}

@end