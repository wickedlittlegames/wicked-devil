//
//  UILayer.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "Player.h"

@interface UILayer : CCLayer {}
@property (nonatomic, retain) CCLabelTTF *label_score, *label_health, *label_bigs;

- (void) update:(Player*)player;

@end
