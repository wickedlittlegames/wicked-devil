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

- (id) init
{
	if( (self=[super init]) ) 
    {

    }
	return self;
}

- (void) setupStartGFX:(int)character
{
    NSString *filename = @"";
    switch (character)
    {
        case 0: filename = @"jump1_detective.png";
        break;
            
        case 1: filename = @"pixel-devil-game.png";
            break;
            
        case 2: filename = @"zombie-jump1.png";
            break;
            
        case 3: filename = @"ninjadevil.png";
            break;
            
        case 4: filename = @"pirate-jump1.png";
            break;
            
        case 5: filename = @"angel-dev-ingame.png";
            break;
            
        case 666: filename = @"jump1.png";
            break;
    }
    self.player = [Player spriteWithFile:[NSString stringWithFormat:@"%@",filename]];
    [self.player setPosition:ccp ( [[CCDirector sharedDirector] winSize].width/2 , (IS_IPHONE5 ? 65 : 60))];
    [self addChild:self.player];
}

@end
