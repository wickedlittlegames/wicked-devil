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
    CCSprite *bg = [CCSprite spriteWithFile:(([[UIScreen mainScreen] bounds].size.height == 568) ? [NSString stringWithFormat:@"bg_%i-iphone5.png", world] : [NSString stringWithFormat:@"bg_%i.png", world])];
    [bg setPosition:ccp([[CCDirector sharedDirector] winSize].width/2, [[CCDirector sharedDirector] winSize].height/2)];
    [self addChild:bg z:1];
}

@end
