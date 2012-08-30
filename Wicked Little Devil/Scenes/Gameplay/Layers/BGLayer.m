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
    CCSprite *top = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background-%i-top.png",world]];
    CCSprite *top2 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background-%i-top.png",world]];
    CCSprite *middle = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background-%i-middle.png",world]];
    CCSprite *middle2 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background-%i-middle2.png",world]];
    CCSprite *bottom = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background-%i-bottom.png",world]];
    
    parallax = [CCParallaxScrollNode node];
    float totalHeight =  top.contentSize.height;    
    
    [parallax addChild:top z:4 Ratio:ccp(0.05,0.5) Pos:ccp(0,0) ScrollOffset:ccp(0,totalHeight)];
    [parallax addChild:top2 z:4 Ratio:ccp(0.05,0.5) Pos:ccp(0,totalHeight-120) ScrollOffset:ccp(0,totalHeight)];
    [parallax addChild:middle2 z:3 Ratio:ccp(0.5,0.1) Pos:ccp(0,0) ScrollOffset:ccp(0,totalHeight)];
    [parallax addChild:middle z:2 Ratio:ccp(0.5,0.05) Pos:ccp(0,0) ScrollOffset:ccp(0,totalHeight)];
    [parallax addChild:bottom z:1 Ratio:ccp(0,0) Pos:ccp(0,0) ScrollOffset:ccp(0,totalHeight)];
        
    [self addChild:parallax];
}

- (void) update:(float)threshold delta:(float)dt
{
    CCLOG(@"%d",threshold);
    if ( threshold < 0 )
    {
        [parallax updateWithYPosition:parallax.position.y - threshold AndDelta:dt];
    }
}

@end
