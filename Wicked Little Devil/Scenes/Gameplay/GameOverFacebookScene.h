//
//  GameOverFacebookScene.h
//  Wicked Little Devil
//
//  Created by Andy on 05/10/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import <Parse/Parse.h>

@class Game, GameOverScene, AppController;
@interface GameOverFacebookScene : CCLayer <PF_FBRequestDelegate>
{
    AppController *app;
}
@property (nonatomic, assign) int request_tag;

+(CCScene *) sceneWithGame:(Game*)game;
- (id) initWithGame:(Game*)game;

@end
