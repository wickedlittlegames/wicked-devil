//
//  Trigger.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 06/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"

#import "GameObject.h"
#import "Player.h"

@interface Trigger : GameObject {
    
}
- (BOOL) isIntersectingPlayer:(Player*)player;

@end