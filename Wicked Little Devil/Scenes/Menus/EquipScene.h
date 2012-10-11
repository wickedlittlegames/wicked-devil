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
    NSArray *items, *descriptions, *prices;
    AppController *app;
    CCLabelTTF *lbl_user_collected;
    User *user;
    
    int tmp_collectables, tmp_collectable_increment;
    CCLayer *layer_shop, *layer_equip;
}

+(CCScene *) scene;
@end
