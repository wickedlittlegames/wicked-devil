//
//  GameoverUILayer.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 18/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "User.h"
#import "Player.h"

@interface GameoverUILayer : CCLayer 
{
    int tmp_score_increment, tmp_player_score, tmp_player_bigcollected, score_multiplier_check, tmp_user_highscore;
}
@property (nonatomic, assign) int world, level, next_world, next_level, score;
@property (nonatomic,retain) CCLabelTTF *lbl_gameover,
                                        *lbl_gameover_bigcollected,
                                        *lbl_gameover_collected,
                                        *lbl_gameover_score;
@property (nonatomic, retain) CCMenu *menu_failed, *menu_success;

- (void) doFinalScoreAnimationsforUser:(User*)user andPlayer:(Player*)player;

@end
