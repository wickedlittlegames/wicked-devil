//
//  PlayerLayer.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

@class Player;
@interface DetectivePlayerLayer : CCLayer {}
@property (nonatomic, retain) Player *player;

- (void) setupStartGFX:(int)character;

@end