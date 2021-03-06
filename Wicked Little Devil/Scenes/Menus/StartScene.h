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
#import "PlayHavenSDK.h"
#import <Parse/Parse.h>
#import "User.h"
#import "BlockAlertView.h"

@class AppController;
@interface StartScene : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate, GameKitHelperProtocol, NSURLConnectionDelegate, PHPublisherContentRequestDelegate>
{
    CCMenuItem *btn_mute, *btn_muted;
    GameKitHelper *gkHelper;
    User *user;
    AppController *app;
    CCMenuItemSprite *btn_facebooksignin;
    CCSprite *prompt_facebook;
    CCSprite *bg_behind_fb;
    PHNotificationView *notificationView;
    CCMenu *menu_connect;
    CCMenu *menu_adventures;
    BlockAlertView *alert;
    
    NSMutableData *imageData;
    NSURLConnection *urlConnection;
    
    bool secret_visible;
}
+(CCScene *) scene;
@end