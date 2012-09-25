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
	if( (self=[super init]) ) {}
	return self;
}

- (void) createWorldSpecificBackgrounds:(int)world
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    CCSprite *bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"bg_%i.png", world]];
    [bg setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    [self addChild:bg z:1];
}

@end
