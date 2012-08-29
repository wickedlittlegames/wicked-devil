//
//  BGLayer.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

@interface BGLayer : CCLayer 
{
    CCSprite *top, *middle, *middle2, *bottom;
}

- (void) createWorldSpecificBackgrounds:(int)world;
- (void) update:(float)threshold;

@end
