//
//  GameplayUILayer.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 14/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

@interface GameplayUILayer : CCLayer {}
@property (nonatomic,retain) CCLabelTTF *lbl_collected,
                                        *lbl_score,          
                                        *lbl_player_health;
@end
