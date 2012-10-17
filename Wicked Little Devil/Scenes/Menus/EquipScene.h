//
//  ShopScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 06/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "CCScrollLayer.h"
#import "LevelSelectScene.h"
#import "AppDelegate.h"
#import "MKStoreManager.h"

#import "User.h"

@interface EquipScene : CCLayer <UITableViewDelegate, UITableViewDataSource>
{
    UIView *view;
    UITableView *table;
    NSMutableArray *data, *data2, *data3;
    AppController *app;
    CCLabelTTF *lbl_user_collected;
    User *user;
    CCMenu *resetAll;
    
    int tmp_collectables, tmp_collectable_increment;
}

+(CCScene *) scene;
@end
