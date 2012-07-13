//
//  StatsScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 13/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "User.h"
#import "LevelSelectScene.h"
#import "AppDelegate.h"

@interface StatsScene : CCLayer  <UITableViewDelegate, UITableViewDataSource> 
{
    User *user;
    UIView *view;
    UITableView *table;
    NSArray *data, *data2;
    AppController *app;
}
+(CCScene *) scene;
@end
