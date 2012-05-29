//
//  Collectable.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 29/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Collectable.h"


@implementation Collectable

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        self.scaleY = -1;
    }
    return self;
}

- (BOOL) isIntersectingPlayer:(Player*)player
{
    if ( CGRectIntersectsRect(player.boundingBox, self.boundingBox) && self.visible == TRUE ) 
    {
        self.visible = FALSE;
        return TRUE;
    }
    return FALSE;
}

@end
