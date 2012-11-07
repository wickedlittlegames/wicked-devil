//
//  StartScreen.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//
#import <GameKit/GameKit.h>
#import "GameKitHelper.h"
#import "cocos2d.h"
#import <Parse/Parse.h>

@class User, AppController;
@interface StartScene : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate, GameKitHelperProtocol, PF_FBRequestDelegate, NSURLConnectionDelegate>
{
    CCMenuItem *btn_mute, *btn_muted;
    GameKitHelper *gkHelper;
    User *user;
    AppController *app;
    CCMenuItemSprite *btn_facebooksignin;
    CCSprite *prompt_facebook;
    CCSprite *bg_behind_fb;
    
    NSMutableData *imageData;
    NSURLConnection *urlConnection;
    
    bool secret_visible;
}
+(CCScene *) scene;
@end