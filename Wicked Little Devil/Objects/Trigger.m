//
//  Trigger.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 06/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Trigger.h"
#import "Player.h"

@implementation Trigger


-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect])) {}
    return self;
}

- (BOOL) isIntersectingPlayer:(Player*)player
{
    return ( CGRectIntersectsRect([self worldBoundingBox], [player worldBoundingBox]) && player.velocity.y < 0 && self.visible );
}

@end

@implementation Tip
@synthesize  faded;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect])) {}
    return self;
}
@end
