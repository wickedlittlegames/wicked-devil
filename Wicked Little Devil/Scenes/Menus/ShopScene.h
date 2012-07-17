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

#import "User.h"

@interface ShopScene : CCLayer <UITableViewDelegate, UITableViewDataSource> 
{
    UIView *view;
    UITableView *table;
    NSArray *data, *data2;
    AppController *app;
    CCLabelTTF *lbl_user_collected;
}
+(CCScene *) scene;
- (void) tap_purchase:(int)item;
@end
