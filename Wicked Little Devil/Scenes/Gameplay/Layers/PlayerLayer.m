//
//  PlayerLayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "PlayerLayer.h"


@implementation PlayerLayer
@synthesize player;

- (id) init
{
	if( (self=[super init]) ) 
    {
        self.isTouchEnabled = YES;
        
        player = [Player spriteWithFile:@"devil2.png"];
        [player setPosition:ccp ( 160 , 110 )];
        [self addChild:player];
        
    }
	return self;
}

@end