//
//  OptionsScene.m
//  Wicked Little Devil
//
//  This scene shows the store for purchasing objects (individual or pack)
//
//  Created by Andrew Girvan on 06/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "UILayer.h"
#import "CCScrollLayer.h"
#import "ShopScene.h"


@implementation ShopScene

+(CCScene *) scene
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    // Grab the layers
    UILayer *ui = [UILayer node];
	ShopScene *current = [ShopScene node];
    
    // Fill the scene
    [scene addChild:ui z:100];
	[scene addChild:current z:10];
    
    // Show the scene
	return scene;
}

-(id) init
{
    if( (self=[super init]) ) {
        // Get the user
        user = [[User alloc] init];
        
        // Screen Size
        //CGSize screenSize = [CCDirector sharedDirector].winSize;
        //float menu_x = (screenSize.width/2) - 23;
        //float menu_y = 275;

        //CCScrollLayer *scroller = [[CCScrollLayer alloc] initWithLayers:[NSMutableArray arrayWithObjects: nil] widthOffset: 0];
        //[self addChild:scroller];
    }
    return self;
}


@end
