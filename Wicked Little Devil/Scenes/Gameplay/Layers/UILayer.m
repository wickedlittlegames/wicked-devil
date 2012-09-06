//
//  UILayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "UILayer.h"
#import "Game.h"
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
    
    CCLOG(@"%i, %i", self.world, self.level);
    
    CCMenuItem *button_restart = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"RESTART" fontName:@"Marker Felt" fontSize:14] target:self selector:@selector(tap_restart)];
    CCMenu *menu_restart = [CCMenu menuWithItems:button_restart, nil];
    [menu_restart  setPosition:ccp(screenSize.width - 50, screenSize.height - 25 )];
    
    CCMenuItem *button_menu = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"MENU" fontName:@"Marker Felt" fontSize:14] target:self selector:@selector(tap_pause)];
    CCMenu *menu_menu = [CCMenu menuWithItems:button_menu, nil];
    [menu_menu  setPosition:ccp(screenSize.width - 120, screenSize.height - 25 )];    
    
    [self addChild:menu_restart z:100];
    [self addChild:menu_menu z:100];
}

- (void) tap_restart
{
    [[CCDirector sharedDirector] replaceScene:[GameScene sceneWithWorld:self.world andLevel:self.level]];
}

- (void) tap_pause
{
    [[CCDirector sharedDirector] pause];
}

- (void) update:(Game*)game
{

}

@end
