//
//  Platform.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Platform.h"

@implementation Platform
@synthesize health, type;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        self.scaleY = -1;
    }
    return self;
}

-(BOOL) isIntersectingPlayer:(Player*)player
{
    if ( CGRectIntersectsRect(player.boundingBox, self.boundingBox) && self.health > 0 && player.velocity.y > 0 ) 
    {
        self.health = self.health - player.damage;
        if (self.health == 0) self.visible = FALSE;
        
        return TRUE;
    }
    return FALSE;
}

- (void) movementWithThreshold:(float)levelThreshold 
{
    if (levelThreshold >= 0)
    {
        self.position = ccp(self.position.x, self.position.y + levelThreshold);
    }
}

- (void) offScreenCleanup
{
    if ( self.position.y > 700 ) 
    {
        [self.parent removeChild:self cleanup:YES];        
    }
}

@end