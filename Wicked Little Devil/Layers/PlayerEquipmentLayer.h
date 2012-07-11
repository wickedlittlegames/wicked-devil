//
//  PlayerEquipmentLayer.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 11/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "User.h"
#import "Card.h"

@interface PlayerEquipmentLayer : CCLayer 
{
    User *user;
}

- (void) appear;
- (void) disappear;

@end
