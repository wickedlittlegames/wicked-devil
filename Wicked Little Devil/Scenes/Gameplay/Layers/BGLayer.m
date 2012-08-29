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
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    top = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background-%i-top.png",world]];
    [top setPosition:ccp(screenSize.width/2,0)];
    [self addChild:top z:4];
    
    middle = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background-%i-middle.png",world]];
    [middle setPosition:ccp(screenSize.width/2,0)];
    [self addChild:middle z:3];
    
    middle2 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background-%i-middle2.png",world]];
    [middle2 setPosition:ccp(screenSize.width/2,0)];
    [self addChild:middle2 z:2];
    
    bottom = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background-%i-bottom.png",world]];
    [bottom setPosition:ccp(screenSize.width/2,0)];
    [self addChild:bottom z:1];    
}

- (void) update:(float)threshold
{
    
}

@end
