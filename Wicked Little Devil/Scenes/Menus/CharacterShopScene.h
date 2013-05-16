//
//  CharacterShopScene.h
//  Wicked Little Devil
//
//  Created by Andy on 16/05/2013.
//  Copyright (c) 2013 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "CCScrollLayer.h"
#import "LevelSelectScene.h"
#import "AppDelegate.h"

#import "User.h"

@interface CharacterShopScene : CCLayer <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
{
    UIView *view;
    UITableView *table;
    NSMutableArray *data, *data2, *data3, *data4;
    AppController *app;
    CCLabelTTF *lbl_user_collected;
    User *user;
    CCMenu *resetAll;
    
    int tmp_collectables, tmp_collectable_increment;
}

+(CCScene *) scene;
@end
