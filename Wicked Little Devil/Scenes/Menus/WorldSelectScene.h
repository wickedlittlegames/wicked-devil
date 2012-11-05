//
//  WorldSelectScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 11/09/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "CCScrollLayer.h"

@class User;
@class ShopScene;
@class AppController;
@interface WorldSelectScene : CCLayer
{
    CGSize screenSize;
    NSString *font;
    int fontsize;
    
    User *user;
    NSMutableArray *worlds;
    CCScrollLayer *scroller;
}

+(CCScene *) scene;

@end
