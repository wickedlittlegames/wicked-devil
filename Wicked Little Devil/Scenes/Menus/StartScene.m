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
	if( (self=[super init]) ) {
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        CCMenuItem *start = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"START" fontName:@"Marker Felt" fontSize:20] target:self selector:@selector(tap_start:)];
        CCMenu *menu = [CCMenu menuWithItems:start, nil];
        menu.position = ccp ( screenSize.width/2, screenSize.height/2 );
        
        [self addChild:menu];
    }
	return self;    
}

- (void)tap_start:(id)sender {
    [[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene]];
}

@end
