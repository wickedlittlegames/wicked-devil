//
//  StartScreen.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//
#import <GameKit/GameKit.h>
#import "cocos2d.h"

@class User;
@interface StartScene : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    CCMenuItem *btn_mute, *btn_muted;
    User *user;
    SimpleAudioEngine *audioPlayer;
}
+(CCScene *) scene;
@end