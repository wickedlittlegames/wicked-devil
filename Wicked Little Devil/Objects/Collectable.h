//
//  Collectable.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 29/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "Player.h"

@interface Collectable : CCSprite {}
    
- (BOOL) isIntersectingPlayer:(Player*)player;

@end

@interface BigCollectable : Collectable {} @end