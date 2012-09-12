//
//  StartScreen.m
//  Wicked Little Devil
//
//  This SCENE is the Angry Birds-style "Start" button that takes you to the world selector
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "AppDelegate.h"
#import "StartScene.h"
#import "WorldSelectScene.h"

@implementation StartScene

+(CCScene *) scene
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    // Grab the layers
	StartScene *current = [StartScene node];
    
    // Fill the scene
	[scene addChild:current];
    
    // Show the scene
	return scene;
}

-(id) init
{
	if( (self=[super init]) ) 
    {
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        CCSprite *bg = [CCSprite spriteWithFile:@"screen-start.png"];
        [bg setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        [self addChild:bg];

        CCMenu *menu_start = [CCMenu menuWithItems:nil];
        CCMenuItem *btn_start = [CCMenuItemImage 
                                 itemWithNormalImage:@"button-start.png"
                                 selectedImage:@"button-start.png"
                                 disabledImage:@"button-start.png"
                                 target:self 
                                 selector:@selector(tap_start:)];
        [menu_start setPosition:ccp(screenSize.width/2, 80)];
        [menu_start addChild:btn_start];
        [self addChild:menu_start];
    }
	return self;    
}

- (void)tap_start:(id)sender {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[WorldSelectScene scene]]];
}

@end
