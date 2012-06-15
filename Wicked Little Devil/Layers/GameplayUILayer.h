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
                                        *lbl_gametime,          
                                        *lbl_player_health, 
                                        *lbl_gameover,
                                        *lbl_gameover_bigcollected,
                                        *lbl_gameover_collected,
                                        *lbl_gameover_score,
                                        *lbl_gameover_highscore,
                                        *lbl_gameover_timebonus;
@property (nonatomic, retain) CCMenu *menu_gameover;
@end
