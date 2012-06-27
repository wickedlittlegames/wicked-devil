//
//  LevelSelectScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "cocos2d.h"
#import "AppDelegate.h"
#import "CCScrollLayer.h"
#import "GameCenterConstants.h"

#import "ShopScene.h"
#import "LevelScene.h"
#import "LevelDetailLayer.h"

#import "User.h"

@interface LevelSelectScene : CCLayer <PF_FBRequestDelegate, GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate> {
    User *user;
    LevelDetailLayer *detail;
    CCMenu *menu_facebook, *menu_unlock;
    CCLabelTTF *lbl_user_collected;
}

+(CCScene *) scene;

@end
