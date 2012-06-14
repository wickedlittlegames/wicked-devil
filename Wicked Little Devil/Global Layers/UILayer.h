//
//  MyCocos2DClass.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 24/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

@interface UILayer : CCLayer {}

@property (nonatomic, assign) CCLabelTTF *lbl_user_collected, *lbl_player_collected,
                                         *lbl_game_time, *lbl_player_health;
@end
