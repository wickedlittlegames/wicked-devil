//
//  ShopScene.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 06/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "User.h"

@interface ShopScene : CCLayer {
    User *user;
}
+(CCScene *) scene;
@end