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
    if ( CGRectIntersectsRect([self worldBoundingBox], [player worldBoundingBox]) && self.visible == TRUE ) 
    {
        self.visible = FALSE;
        return TRUE;
    }
    return FALSE;
}

@end

@implementation BigCollectable 

- (BOOL) isIntersectingPlayer:(Player*)player
{
    if ( CGRectIntersectsRect([self worldBoundingBox], [player worldBoundingBox]) && self.visible == TRUE ) 
    {
        self.visible = FALSE;
        return TRUE;
    }
    return FALSE;
}

@end
