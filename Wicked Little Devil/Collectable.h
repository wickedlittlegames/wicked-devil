//
//  Collectable.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 29/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "GameObject.h"
#import "Player.h"

@interface Collectable : GameObject {}
    
- (BOOL) isIntersectingPlayer:(Player*)player;

@end

@interface BigCollectable : GameObject {} 

- (BOOL) isIntersectingPlayer:(Player*)player;

@end