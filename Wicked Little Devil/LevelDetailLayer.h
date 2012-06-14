//
//  LevelDetailLayer.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 12/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//
#import "GameCenterConstants.h"
#import "cocos2d.h"
#import "User.h"

@interface LevelDetailLayer : CCLayer {}

- (void) setupDetailsForWorld:(int)world level:(int)level withUserData:(User*)user;
- (void) slideIn;
- (void) slideOut;

@end
