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
#import "User.h"

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
        CCMenu *menu_store              = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-powerup.png" selectedImage:@"btn-powerup.png"    target:self selector:@selector(tap_store:)],nil];
        
        // Positioning
        [menu_back              setPosition:ccp(25, 25)];
        [menu_store             setPosition:ccp(25, screenSize.height - 25)];
        [icon_bigcollectable    setPosition:ccp(screenSize.width - 20, screenSize.height - 20)];
        [icon_collectable       setPosition:ccp(screenSize.width - 20, icon_bigcollectable.position.y - 26)];
        [label_bigcollected     setPosition:ccp(screenSize.width/2, screenSize.height - 22)];
        [label_collected        setPosition:ccp(screenSize.width/2, label_bigcollected.position.y - 24)];
        
        // Add world layers to the scroller
        [worlds addObject:[self hell]];
        [worlds addObject:[self underground]];
        [worlds addObject:[self ocean]];
        [worlds addObject:[self land]];
        [worlds addObject:[self space]];
        [worlds addObject:[self afterlife]];
        scroller = [[CCScrollLayer alloc] initWithLayers:worlds widthOffset: 0];
        [scroller selectPage:user.cache_current_world-1];
        
        // Put the children to the screen
        [self addChild:scroller];               // World scroller to go through the level
        [self addChild:menu_store];             // back button
        [self addChild:menu_back];              // store button
        [self addChild:icon_bigcollectable];    // icon for big collectable near the world collected total
        [self addChild:icon_collectable];
        [self addChild:label_bigcollected];     // label for collected total - eg: 3/360
        [self addChild:label_collected];
    }
	return self;    
}

#pragma mark TAPS

- (void) tap_world:(CCMenuItemFont*)sender
{
    user.cache_current_world = sender.tag;
    [user sync_cache_current_world];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[LevelSelectScene sceneWithWorld:sender.tag]]];
}

- (void) tap_store:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[ShopScene scene]]];
}

- (void) tap_back:(CCMenuItem*)sender
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[StartScene scene]]];
}

#pragma mark WORLDS

- (CCLayer*) hell
{
    CCLayer *layer          = [CCLayer node];
    CCSprite *bg            = [CCSprite spriteWithFile:@"bg-menu-hell.png"];
    CCMenuItemImage *button = [CCMenuItemImage itemWithNormalImage:@"btn-start.png" selectedImage:@"btn-start.png" disabledImage:@"btn-start.png" target:self selector:@selector(tap_world:)];
    CCMenu *menu            = [CCMenu menuWithItems:button, nil]; button.tag = 1; button.opacity = 0; button.scale *= 2; button.isEnabled = ( user.worldprogress >= button.tag );
    
    bg.position     = ccp (screenSize.width/2, screenSize.height/2);
    menu.position   = ccp ( screenSize.width/2, screenSize.height/2 );

    [layer addChild:bg];
    [layer addChild:menu];
    
    return layer;
}

- (CCLayer*) underground
{
    CCLayer *layer          = [CCLayer node];
    CCSprite *bg            = [CCSprite spriteWithFile:@"bg-menu-underground.png"];
    CCMenuItemImage *button = [CCMenuItemImage itemWithNormalImage:@"btn-start.png" selectedImage:@"btn-start.png" disabledImage:@"btn-start.png" target:self selector:@selector(tap_world:)];
    CCMenu *menu            = [CCMenu menuWithItems:button, nil]; button.tag = 2; button.opacity = 0; button.scale *= 2; button.isEnabled = ( user.worldprogress >= button.tag );
    
    bg.position     = ccp (screenSize.width/2, screenSize.height/2);
    menu.position   = ccp ( screenSize.width/2, screenSize.height/2 );
    
    [layer addChild:bg];
    [layer addChild:menu];
    
    return layer;
}

- (CCLayer*) ocean
{
    CCLayer *layer          = [CCLayer node];
    CCSprite *bg            = [CCSprite spriteWithFile:@"bg-menu-ocean.png"];
    CCMenuItemImage *button = [CCMenuItemImage itemWithNormalImage:@"btn-start.png" selectedImage:@"btn-start.png" disabledImage:@"btn-start.png" target:self selector:@selector(tap_world:)];
    CCMenu *menu            = [CCMenu menuWithItems:button, nil]; button.tag = 3; button.opacity = 0; button.scale *= 2; button.isEnabled = ( user.worldprogress >= button.tag );
    
    bg.position     = ccp (screenSize.width/2, screenSize.height/2);
    menu.position   = ccp ( screenSize.width/2, screenSize.height/2 );
    
    [layer addChild:bg];
    [layer addChild:menu];
    
    return layer;
}

- (CCLayer*) land
{
    CCLayer *layer          = [CCLayer node];
    CCSprite *bg            = [CCSprite spriteWithFile:@"bg-menu-land.png"];
    CCMenuItemImage *button = [CCMenuItemImage itemWithNormalImage:@"btn-start.png" selectedImage:@"btn-start.png" disabledImage:@"btn-start.png" target:self selector:@selector(tap_world:)];
    CCMenu *menu            = [CCMenu menuWithItems:button, nil]; button.tag = 4; button.opacity = 0; button.scale *= 2; button.isEnabled = ( user.worldprogress >= button.tag );
    
    bg.position     = ccp (screenSize.width/2, screenSize.height/2);
    menu.position   = ccp ( screenSize.width/2, screenSize.height/2 );
    
    [layer addChild:bg];
    [layer addChild:menu];
    
    return layer;
}

// NOT YET NEEDED FOR 1.0
- (CCLayer*) space
{
    CCLayer *layer          = [CCLayer node];
    CCSprite *bg            = [CCSprite spriteWithFile:@"bg-menu-space.png"];
    //CCSprite *bg            = [CCSprite spriteWithFile:@"bg-menu-space-comingsoon.png"];
    CCMenuItemImage *button = [CCMenuItemImage itemWithNormalImage:@"btn-start.png" selectedImage:@"btn-start.png" disabledImage:@"btn-start.png" target:self selector:@selector(tap_world:)];
    CCMenu *menu            = [CCMenu menuWithItems:button, nil]; button.tag = 5; button.opacity = 0; button.scale *= 2; //button.isEnabled = ( user.worldprogress >= button.tag );
    button.isEnabled = FALSE;
    
    bg.position     = ccp (screenSize.width/2, screenSize.height/2);
    menu.position   = ccp ( screenSize.width/2, screenSize.height/2 );
    
    [layer addChild:bg];
    [layer addChild:menu];
    
    return layer;
}

// NOT YET NEEDED FOR 1.0
- (CCLayer*) afterlife
{
    CCLayer *layer          = [CCLayer node];
    CCSprite *bg            = [CCSprite spriteWithFile:@"bg-menu-afterlife.png"];
    //CCSprite *bg            = [CCSprite spriteWithFile:@"bg-menu-afterlife-comingsoon.png"];
    CCMenuItemImage *button = [CCMenuItemImage itemWithNormalImage:@"btn-start.png" selectedImage:@"btn-start.png" disabledImage:@"btn-start.png" target:self selector:@selector(tap_world:)];
    CCMenu *menu            = [CCMenu menuWithItems:button, nil]; button.tag = 6; button.opacity = 0; button.scale *= 2; //button.isEnabled = ( user.worldprogress >= button.tag );
    button.isEnabled = FALSE;
    
    bg.position     = ccp (screenSize.width/2, screenSize.height/2);
    menu.position   = ccp ( screenSize.width/2, screenSize.height/2 );
    
    [layer addChild:bg];
    [layer addChild:menu];
    
    return layer;
}

@end