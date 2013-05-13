//
//  PlayerLayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "DetectivePlayerLayer.h"
#import "Player.h"

@implementation DetectivePlayerLayer

- (id) init
{
	if( (self=[super init]) )
    {
        self.player = [Player spriteWithFile:@"jump1_detective.png"];
        [self.player setPosition:ccp ( [[CCDirector sharedDirector] winSize].width/2 , 60 )];
        [self addChild:self.player];
    }
	return self;
}

@end
