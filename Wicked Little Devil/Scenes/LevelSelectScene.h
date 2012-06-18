//
//  LevelSelectScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "cocos2d.h"
#import "CCScrollLayer.h"
#import "GameCenterConstants.h"

#import "ShopScene.h"
#import "LevelDetailLayer.h"

#import "User.h"

@interface LevelSelectScene : CCLayer {
    User *user;
    LevelDetailLayer *detail;
}

+(CCScene *) scene;

@end
