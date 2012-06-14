//
//  Platform.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Platform.h"
#import "CCNode+CoordHelpers.h"

@implementation Platform
@synthesize health, type, animating,original_position,active;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        self.health = 1.0;
        self.animating = FALSE;
        self.active = TRUE;
        self.original_position = ccp(self.position.x, self.position.y);
    }
    return self;
}

-(BOOL) isIntersectingPlayer:(Player*)player
{   
    return (CGRectIntersectsRect([self worldBoundingBox], [player worldBoundingBox]) && player.velocity.y < 0 && self.visible);
}

-(void)takeDamagefromPlayer:(Player*)player
{
    self.health = self.health - player.damage;
    self.visible = (self.health == 0 ? FALSE : TRUE);
}

-(BOOL)isAlive
{
    return ( self.health > 0.0 ? TRUE : FALSE );
}

@end