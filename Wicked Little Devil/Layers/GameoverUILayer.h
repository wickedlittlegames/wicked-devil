//
//  GameoverUILayer.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 18/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

@interface GameoverUILayer : CCLayer {}
@property (nonatomic,retain) CCLabelTTF *lbl_gameover,
                                        *lbl_gameover_bigcollected,
                                        *lbl_gameover_collected,
                                        *lbl_gameover_score,
                                        *lbl_gameover_highscore;


@end
