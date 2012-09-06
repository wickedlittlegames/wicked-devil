//
//  UILayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "UILayer.h"

@implementation UILayer
@synthesize label_bigs, label_score, label_health; //cclabelttfs

- (id) init
{
	if( (self=[super init]) ) 
    {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        NSString *font = @"Marker Felt";
        int fontsize = 14;
        
        label_bigs = [CCLabelTTF labelWithString:@"BIG: 0" fontName:font fontSize:fontsize];
        label_health = [CCLabelTTF labelWithString:@"HEALTH: 3" fontName:font fontSize:fontsize];
        label_score  = [CCLabelTTF labelWithString:@"SCORE: 0" fontName:font fontSize:fontsize];
        
        [label_bigs setPosition:ccp(95, screenSize.height - 25)];
        [label_health setPosition:ccp(95, screenSize.height - 95)];
        [label_score setPosition:ccp(screenSize.width - 50, screenSize.height - 25)];
        
        [self addChild:label_bigs];
        [self addChild:label_health];
        [self addChild:label_score];
    }
	return self;
}

- (void) update:(Player*)player
{

}

@end
