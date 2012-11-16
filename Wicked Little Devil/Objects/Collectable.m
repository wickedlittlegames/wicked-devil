//
//  Collectable.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 29/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Collectable.h"
#import "Player.h"

@implementation Collectable
- (BOOL) isIntersectingPlayer:(Player*)player
{
    if ( CGRectIntersectsRect([self worldBoundingBox], [player worldBoundingBox]) && self.visible == TRUE ) 
    {
        return TRUE;
    }
    return FALSE;
}

- (BOOL) isClosetoPlayer:(Player*)player
{
    if ( [self radiusCheck:player] && self.visible )
    {
        return TRUE;
    }
    return FALSE;
}

- (void) moveTowardsPlayer:(Player*)player
{
    float xdif = [self worldBoundingBox].origin.x - [player worldBoundingBox].origin.x;
    float ydif = [self worldBoundingBox].origin.y - [player worldBoundingBox].origin.y;
    
    self.position = ccp(self.position.x - xdif/10, self.position.y - ydif/10);
}

- (bool) radiusCheck:(Player*)player
{
    float xdif = [self worldBoundingBox].origin.x - [player worldBoundingBox].origin.x;
    float ydif = [self worldBoundingBox].origin.y - [player worldBoundingBox].origin.y;
    float radius = 80;
    float radiusTwo = 1;
    
    float distance = sqrt(xdif*xdif+ydif*ydif);
    
    if(distance <= radius+radiusTwo)
        return YES;
    
    return NO;
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
