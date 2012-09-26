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

- (void) start:(int)effect position:(CGPoint)pos;
- (void) stopAll;
- (void) showWarningAtPosition:(CGPoint)tmp_pos;

@end
