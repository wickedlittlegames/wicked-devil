//
//  OptionsScene.m
//  Wicked Little Devil
//
//  This scene shows the store for purchasing objects (individual or pack)
//
//  Created by Andrew Girvan on 06/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "ShopScene.h"


@implementation ShopScene

+(CCScene *) scene
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    // Grab the layers
	ShopScene *current = [ShopScene node];
    
    // Fill the scene
	[scene addChild:current z:10];
    
    // Show the scene
	return scene;
}

-(id) init
{
    if( (self=[super init]) ) {
        //User *user = [[User alloc] init];
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        CCMenuItem *back = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"BACK" fontName:@"Marker Felt" fontSize:20] target:self selector:@selector(tap_back)];
        CCMenu *menu = [CCMenu menuWithItems:back, nil];
        menu.position = ccp ( screenSize.width - 80, 10 );
        
        [self addChild:menu];

    }
    return self;
}

- (void) tap_back
{
    [[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene]];
}


@end
