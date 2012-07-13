//
//  EquipScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 13/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "EquipScene.h"


@implementation EquipScene

+(CCScene *) scene
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    // Grab the layers
	EquipScene *current = [EquipScene node];
    
    // Fill the scene
	[scene addChild:current];
    
    // Show the scene
	return scene;
}

-(id) init
{
    if( (self=[super init]) ) {
        // CGSize screenSize = [CCDirector sharedDirector].winSize;
    }
    return self;
}

@end
