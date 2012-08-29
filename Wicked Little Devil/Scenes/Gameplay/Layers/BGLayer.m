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
    parallax = [CCParallaxScrollNode node];

    top = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background-%i-top.png",world]];
    middle = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background-%i-middle.png",world]];
    middle2 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background-%i-middle2.png",world]];
    bottom = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background-%i-bottom.png",world]];
    
    [parallax addInfiniteScrollYWithZ:0 Ratio:ccp(0.5,0.5) Pos:ccp([[CCDirector sharedDirector] winSize].width/2,0) Objects:top,middle,middle2,bottom, nil];
    
    [self addChild:parallax z:-1];
}

- (void) update:(float)threshold
{
    [parallax updateWithVelocity:ccp(0,-4) AndDelta:0.01];
}

@end
