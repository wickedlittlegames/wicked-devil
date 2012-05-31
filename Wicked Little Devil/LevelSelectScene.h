//
//  LevelSelectScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "cocos2d.h"
#import "User.h"

@interface LevelSelectScene : CCLayer {
    User *user;
}
+(CCScene *) scene;
@end
