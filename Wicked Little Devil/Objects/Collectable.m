//
//  Collectable.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 29/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Collectable.h"


@implementation Collectable

- (BOOL) isIntersectingPlayer:(Player*)player
{
    if ( CGRectIntersectsRect(player.boundingBox, self.boundingBox) && self.visible == TRUE ) 
    {
        self.visible = FALSE;
        return TRUE;
    }
    return FALSE;
}

- (void) movementWithThreshold:(float)levelThreshold 
{
    if (levelThreshold < 0)
    {
        self.position = ccp(self.position.x, self.position.y + levelThreshold);
    }
}

@end

@implementation BigCollectable @end