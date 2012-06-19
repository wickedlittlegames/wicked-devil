//
//  PlayerStatsScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 19/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "cocos2d.h"
#import "User.h"

@interface PlayerStatsScene : CCLayer  <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate> {}

+(CCScene *) scene;
@end
