//
//  AdventureSelectScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 11/09/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//
#import <GameKit/GameKit.h>
#import "GameKitHelper.h"
#import "cocos2d.h"
#import "CCScrollLayer.h"
#import "PlayHavenSDK.h"
#import "FlurryAnalytics.h"
#import <Parse/Parse.h>

@class User;
@class ShopScene;
@class AppController;
@interface AdventureSelectScene : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate, GameKitHelperProtocol, PF_FBRequestDelegate, NSURLConnectionDelegate>
{
    CGSize screenSize;
    NSString *font;
    int fontsize;
    
    User *user;
    NSMutableArray *worlds;
    CCScrollLayer *scroller;
    CCLabelTTF *label_collected;
    CCSprite *locked_sprite;
    CCMenu *unlock_menu;
    
    AppController *app;
    CCMenuItemSprite *btn_facebooksignin;
    CCSprite *bg_behind_fb;
    GameKitHelper *gkHelper;
    PHNotificationView *notificationView;
    CCMenuItemImage *button;
    
    NSMutableData *imageData;
    NSURLConnection *urlConnection;
    
    int tmp_collectables, tmp_collectable_increment;
}

+(CCScene *) scene;

@end
