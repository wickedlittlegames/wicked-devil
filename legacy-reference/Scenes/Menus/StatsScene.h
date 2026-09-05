//
//  StatsScene.h
//  Wicked Little Devil
//
//  Created by Andy on 14/05/2013.
//  Copyright (c) 2013 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "User.h"

@class AppController;
@interface StatsScene : CCLayer <UITableViewDelegate, UITableViewDataSource>
{
    AppController *app;
    UIView *view;
    UITableView *table;
    User *user;
    NSArray *tableTitles, *tableData;
}
+(CCScene *) scene;
@end
