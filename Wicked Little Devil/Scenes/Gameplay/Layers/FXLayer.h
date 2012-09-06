//
//  FXLayer.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

@interface FXLayer : CCLayer {}

@property (nonatomic, retain) CCArray *effects;
@property (nonatomic, assign) BOOL running;

- (void) doEffect:(int)effect atPosition:(CGPoint)fx_pos;
- (void) stopAllEffects;
- (void) update:(float)threshold;

@end
