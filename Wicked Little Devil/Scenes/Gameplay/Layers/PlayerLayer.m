//
//  PlayerLayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "PlayerLayer.h"
#import "Player.h"

@implementation PlayerLayer
@synthesize player;

- (id) init
{
	if( (self=[super init]) ) 
    {
        player = [Player spriteWithFile:@"Demon_jumping_50X75_1.png"];
        [player setPosition:ccp ( 320/2 , 130 )];
        [self addChild:player];              
    }
	return self;
}

@end
