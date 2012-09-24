//
//  Game.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 19/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Game.h"
#import "Player.h"
#import "User.h"


@implementation Game
@synthesize isGameover, didWin, world, level, isStarted, isIntro, player, user, fx;

-(id) init
{
	if( (self=[super init]) )
    {
        self.audioPlayer = [SimpleAudioEngine sharedEngine];
    }
    return self;
}


@end
