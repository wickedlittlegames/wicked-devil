//
//  EquipScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 13/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "CCScrollLayer.h"

#import "User.h"

@interface EquipScene : CCLayer 
{
    User *user;
    CGSize screenSize;
}

+(CCScene *) scene;
@end