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
@interface WorldSelectScene : CCLayer 
{
    User *user;
    
    CGSize screenSize;
    NSMutableArray *worlds;
    NSString *font;
    int fontsize;
    
    CCScrollLayer *scroller;    
}

+(CCScene *) scene;

@end
