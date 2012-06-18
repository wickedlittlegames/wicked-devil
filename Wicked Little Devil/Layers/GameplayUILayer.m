//
//  GameplayUILayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 14/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "GameplayUILayer.h"
#import "LevelScene.h"
#import "LevelSelectScene.h"

@implementation GameplayUILayer
@synthesize lbl_player_health, lbl_gametime, lbl_collected;

-(id) init
{
	if( (self=[super init]) ) {
        
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
        NSString *font = @"Arial";
        int fontsize = 18;
        
        lbl_collected = [CCLabelTTF labelWithString:@"Collected: " fontName:font fontSize:fontsize];
        lbl_collected.position = ccp (screenSize.width - 100, screenSize.height - 20);
        [self addChild:lbl_collected];
        
        lbl_gametime = [CCLabelTTF labelWithString:@"100" fontName:font fontSize:fontsize];
        lbl_gametime.position = ccp ( 20, screenSize.height - 20);
        [self addChild:lbl_gametime];
    }
	return self;    
}

@end
