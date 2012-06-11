//
//  GameObject.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 11/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

@interface GameObject : CCSprite {
    
}

- (void) movementWithThreshold:(float)levelThreshold;

@end
