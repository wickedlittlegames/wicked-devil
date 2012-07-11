//
//  Card.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 11/07/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

@interface Card : CCLayer 
{
    CCMenu *menu;
    CCSprite *image;
    CCLabelTTF *label_name, *label_desc, *label_cost;
    NSString *name, *desc;
    int cost;
    bool unlocked;
}

-(id) initWithName:(NSString*)_name Description:(NSString*)_desc Cost:(int)_cost Unlocked:(bool)_unlocked Image:(NSString*)_image;

@end
