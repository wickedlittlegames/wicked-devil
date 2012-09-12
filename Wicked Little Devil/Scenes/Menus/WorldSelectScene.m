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
#import "User.h"

@implementation WorldSelectScene

+(CCScene *) scene
{
    // Create a Scene
	CCScene *scene = [CCScene node];
	WorldSelectScene *current = [WorldSelectScene node];
    
    // Fill the scene
	[scene addChild:current];
    
    // Show the scene
	return scene;
}

-(id) init
{
	if( (self=[super init]) ) 
    {
        user = [[User alloc] init];
        
        // World Selection
        [self setup];
        
        // Back Button
        CCMenu *menu_back = [CCMenu menuWithItems:nil];
        CCMenuItem *btn_back = [CCMenuItemImage 
                                 itemWithNormalImage:@"button-back2.png"
                                 selectedImage:@"button-back2.png"
                                 disabledImage:@"button-back2.png"
                                 target:self 
                                 selector:@selector(tap_back:)];
        [menu_back setPosition:ccp(30, 30)];
        [menu_back addChild:btn_back];
        [self addChild:menu_back];
    }
	return self;    
}

- (void) setup
{
    screenSize = [CCDirector sharedDirector].winSize;
    font = @"CrashLanding BB";
    fontsize = 36;
    
    worlds = [NSMutableArray arrayWithCapacity:100];
    
    // HELL to HEAVEN WORLDS
    [worlds addObject:[self escapefromhell]];
    [worlds addObject:[self escapefromunderground]];
    [worlds addObject:[self escapefromocean]];
    [worlds addObject:[self escapefromearth]];
    [worlds addObject:[self escapefromspace]];
    [worlds addObject:[self escapefromafterlife]];
    [worlds addObject:[self halloween]];
    
    scroller = [[CCScrollLayer alloc] initWithLayers:worlds widthOffset: 0];
    [self addChild:scroller];
}

- (CCLayer*) escapefromhell
{
    CCLayer *layer = [CCLayer node];
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"HELL" fontName:font fontSize:fontsize];
    CCMenuItemFont *button = [CCMenuItemFont itemWithLabel:label target:self selector:@selector(click:)];
    button.tag = 1;
    CCMenu *menu = [CCMenu menuWithItems:button, nil];
    
    menu.position = ccp ( screenSize.width/2, screenSize.height/2 );
    [layer addChild:menu];
    
    return layer;
}

- (CCLayer*) escapefromunderground
{
    CCLayer *layer = [CCLayer node];
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"UNDERGROUND" fontName:font fontSize:fontsize];
    CCMenuItemFont *button = [CCMenuItemFont itemWithLabel:label target:self selector:@selector(click:)];
    button.tag = 2;
    button.isEnabled = ( user.worldprogress >= button.tag );
    CCMenu *menu = [CCMenu menuWithItems:button, nil];
    
    menu.position = ccp ( screenSize.width/2, screenSize.height/2 );
    [layer addChild:menu];
    
    return layer;
}

- (CCLayer*) escapefromocean
{
    CCLayer *layer = [CCLayer node];
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"OCEAN" fontName:font fontSize:fontsize];
    CCMenuItemFont *button = [CCMenuItemFont itemWithLabel:label target:self selector:@selector(click:)];
    button.tag = 3;
    button.isEnabled = ( user.worldprogress >= button.tag );    
    CCMenu *menu = [CCMenu menuWithItems:button, nil];
    
    menu.position = ccp ( screenSize.width/2, screenSize.height/2 );
    [layer addChild:menu];
    
    return layer;
}

- (CCLayer*) escapefromearth
{
    CCLayer *layer = [CCLayer node];
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"EARTH" fontName:font fontSize:fontsize];
    CCMenuItemFont *button = [CCMenuItemFont itemWithLabel:label target:self selector:@selector(click:)];
    button.tag = 4;
    button.isEnabled = ( user.worldprogress >= button.tag );    
    CCMenu *menu = [CCMenu menuWithItems:button, nil];
    
    menu.position = ccp ( screenSize.width/2, screenSize.height/2 );
    [layer addChild:menu];
    
    return layer;
}

- (CCLayer*) escapefromspace
{
    CCLayer *layer = [CCLayer node];
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"SPACE" fontName:font fontSize:fontsize];
    CCMenuItemFont *button = [CCMenuItemFont itemWithLabel:label target:self selector:@selector(click:)];
    button.tag = 5;
    button.isEnabled = ( user.worldprogress >= button.tag );    
    CCMenu *menu = [CCMenu menuWithItems:button, nil];
    
    menu.position = ccp ( screenSize.width/2, screenSize.height/2 );
    [layer addChild:menu];
    
    return layer;
}

- (CCLayer*) escapefromafterlife
{
    CCLayer *layer = [CCLayer node];
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"AFTERLIFE" fontName:font fontSize:fontsize];
    CCMenuItemFont *button = [CCMenuItemFont itemWithLabel:label target:self selector:@selector(click:)];
    button.tag = 6;
    button.isEnabled = ( user.worldprogress >= button.tag );    
    CCMenu *menu = [CCMenu menuWithItems:button, nil];
    
    menu.position = ccp ( screenSize.width/2, screenSize.height/2 );
    [layer addChild:menu];
    
    return layer;
}

/*
 
 STILL WORKING ON REBUILDING THE MENUS AND MECHANICS. NEED TO ADD IN BUTTONS LIKE SETTINGS ETC
 
 */


- (CCLayer*) halloween
{
    CCLayer *layer = [CCLayer node];
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"HALLOWEEN 2012" fontName:font fontSize:fontsize];
    CCMenuItemFont *button = [CCMenuItemFont itemWithLabel:label target:self selector:@selector(click:)];
    button.tag = 7;
    CCMenu *menu = [CCMenu menuWithItems:button, nil];
    
    menu.position = ccp ( screenSize.width/2, screenSize.height/2 );
    [layer addChild:menu];
    
    return layer;
}

- (void) click:(CCMenuItemFont*)sender
{
    int item = sender.tag;
    
    switch(item)
    {
        case 7:
            CCLOG(@"HALLOWEEN");
            break;
        default:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[LevelSelectScene sceneWithWorld:item]]];
            break;
    }
}

- (void) tap_back:(CCMenuItem*)sender
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[StartScene scene]]];
}


@end