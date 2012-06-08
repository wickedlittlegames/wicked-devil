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
        // defaults
        self.health = 500.0;
        self.visible = TRUE;
        self.zOrder = 100;
        self.opacity = 1;
        NSLog(@"Does this fire?");
    }
    return self;
}

-(BOOL) isIntersectingPlayer:(Player*)player
{
    if ( CGRectIntersectsRect(player.boundingBox, self.boundingBox) && self.visible == TRUE && player.velocity.y < 0) 
    {
        self.health = self.health - player.damage;
        if (self.health == 0) self.visible = FALSE;
        
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