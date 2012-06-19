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
@synthesize isEffectActive;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        // defaults
        self.visible = FALSE;
        self.isEffectActive = FALSE;
    }
    return self;
}

- (BOOL) isIntersectingPlayer:(Player*)player
{
    if ( CGRectIntersectsRect([self worldBoundingBox], [player worldBoundingBox]) && player.velocity.y < 0 && self.visible ) 
    {
        return TRUE;
    }
    return FALSE;
}

- (void) toggleEffect
{
    // do the partical effect
    self.isEffectActive = !self.isEffectActive;
    if (isEffectActive)
    {
        // do effect
    }
    else 
    {
        // do effect
    }
}

- (void) damageToPlayer:(Player*)player
{
    player.health = player.health - 1.0;
}

@end
