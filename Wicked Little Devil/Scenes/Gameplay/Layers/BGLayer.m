//
//  BGLayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "BGLayer.h"


@implementation BGLayer

- (id) init
{
	if( (self=[super init]) ) 
    {

    }
	return self;
}

- (void) createWorldSpecificBackgrounds:(int)world
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    CCSprite *middle = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background-%i-middle.png",world]];
    CCSprite *middle2 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background-%i-middle2.png",world]];
    CCSprite *bottom = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background-%i-bottom.png",world]];

    [middle setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    [middle2 setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    [bottom setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    
    [self addChild:middle z:2];
    [self addChild:middle2 z:3];
    [self addChild:bottom z:1];
}

@end
