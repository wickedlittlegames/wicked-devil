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

@interface ShopScene : CCLayer <UITableViewDelegate, UITableViewDataSource>
{
    UIView *view;
    UITableView *table;
    NSArray *data, *data2, *data3;
    AppController *app, *appHUD;
    CCLabelTTF *lbl_user_collected;
    User *user;
    bool purchased;
    int tmp_collectables, tmp_collectable_increment, timeout_check;
    CCLayer *layer_shop, *layer_equip;
}

+(CCScene *) scene;
@end
