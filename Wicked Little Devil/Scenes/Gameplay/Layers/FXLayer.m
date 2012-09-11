//
//  FXLayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "FXLayer.h"


@implementation FXLayer
@synthesize effects, running;

- (id) init
{
	if( (self=[super init]) ) 
    {
        self.running = NO;
        [self initAllEffects];
    }
	return self;
}

- (void) doEffect:(int)effect atPosition:(CGPoint)fx_pos
{
    CCParticleSystemQuad *fx = (CCParticleSystemQuad*)[self.effects objectAtIndex:effect];
    [fx setPosition:fx_pos];
    if ( ![self getChildByTag:effect] )
    {
        [self addChild:fx z:10 tag:effect];
    } 
    else 
    {
        [fx resetSystem];
    }
}

- (void) stopAllEffects
{
        
}

- (void) initAllEffects 
{
    self.effects = [CCArray arrayWithCapacity:100];
    
    // Explosion
    CCParticleSystemQuad *explosion = [CCParticleSystemQuad particleWithFile:@"Explosion.plist"];
    [self.effects addObject:explosion];
    
    // Soul collect
    CCParticleSystem *angelblast = [CCParticleSystemQuad particleWithFile:@"AngelBlast.plist"];
    [self.effects addObject:angelblast];
    
    CCParticleSystem *bigcollectableblast = [CCParticleSystemQuad particleWithFile:@"SoulCollected.plist"];
    [self.effects addObject:bigcollectableblast];    

}

- (void) update:(float)threshold{}

@end
