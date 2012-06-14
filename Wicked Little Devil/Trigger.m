//
//  Trigger.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 06/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Trigger.h"
#import "CCNode+CoordHelpers.h"

@implementation Trigger

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        // defaults
        self.visible = FALSE;
    }
    return self;
}

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
