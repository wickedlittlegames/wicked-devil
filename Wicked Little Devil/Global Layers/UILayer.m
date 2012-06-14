//
//  MyCocos2DClass.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 24/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "UILayer.h"


@implementation UILayer
@synthesize lbl_user_collected, 
            lbl_player_collected,
            lbl_game_time, 
            lbl_player_health;

- (id) init {
    self = [super init];
    if (self != nil) {
        //label = [CCLabelTTF labelWithString:@"Menu" fontName:@"Arial" fontSize:32];
		//label.color = ccc3(255,255,255);
		//label.position = ccp(200, 300);
		//[self addChild:label];
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        NSString *font = @"Arial";
        int size = 18;
        
        lbl_game_time = [CCLabelTTF labelWithString:@"Gametime" fontName:font fontSize:size];
        lbl_game_time.position = ccp ( screenSize.width - 200, screenSize.height - 20); 
        [self addChild:lbl_game_time];
        
        lbl_player_health = [CCLabelTTF labelWithString:@"Player health: " fontName:font fontSize:size];
        lbl_player_health.position = ccp ( screenSize.width - 250, screenSize.height - 20); 
        [self addChild:lbl_player_health];        
        
    }
    return self;
}

- (id) initWithAds {
    self = [super init];
    if (self != nil) {
        
    }
    return self;
}

@end