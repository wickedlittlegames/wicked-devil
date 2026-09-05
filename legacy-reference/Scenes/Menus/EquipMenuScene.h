//
//  EquipMenuScene.h
//  Wicked Little Devil
//
//  Created by Andy on 13/11/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "User.h"

@interface EquipMenuScene : CCLayer
{
    User *user;
    CCLabelTTF *lbl_user_collected;
}

+(CCScene *) scene;

@end