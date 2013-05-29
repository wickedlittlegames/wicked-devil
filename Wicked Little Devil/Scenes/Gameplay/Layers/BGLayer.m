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
    CCSprite *bg = nil;
    
    if ( world == 11 )
        bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"bg_%i.png", 1]];
    else
        bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"bg_%i%@.png", world, (IS_IPHONE5 ? @"-iphone5" : @"")]];
 
    
    [bg setPosition:ccp([[CCDirector sharedDirector] winSize].width/2, [[CCDirector sharedDirector] winSize].height/2)];
    [self addChild:bg z:1];
}

@end
