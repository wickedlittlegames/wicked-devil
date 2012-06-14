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
    }
    return self;
}


@end
