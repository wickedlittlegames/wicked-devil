//
//  Projectile.m
//  Wicked Little Devil
//
//  Created by Andy on 26/09/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "Projectile.h"
#import "Player.h"
#import "Enemy.h"
@implementation Projectile

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect])) {}
    return self;
}

- (BOOL) isIntersectingPlayer:(Player*)player
{
    return ( CGRectIntersectsRect([self worldBoundingBox], [player worldBoundingBox]) && self.visible );
}

- (BOOL) isIntersectingParent:(Enemy*)enemy
{
    return ( CGRectIntersectsRect([self worldBoundingBox], [enemy worldBoundingBox]) && enemy.visible );
}
@end

@implementation EnemyFX

- (BOOL) isIntersectingPlayer:(Player*)player
{
    return ( CGRectIntersectsRect([self worldBoundingBox], [player worldBoundingBox]) && self.visible );
}

@end

