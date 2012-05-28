//
//  Platform.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Platform.h"

@implementation Platform

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {

    }
    return self;
}

-(BOOL) isIntersectingPlayer:(Player*)player
{
    if ( CGRectIntersectsRect(player.boundingBox, self.boundingBox) )
    {
        return TRUE;
    }
    return FALSE;
}

- (void) movementWithThreshold:(float)levelThreshold 
{
    if (levelThreshold <= 0)
    {
        self.position = ccp(self.position.x, self.position.y + levelThreshold);
    }
}

@end
