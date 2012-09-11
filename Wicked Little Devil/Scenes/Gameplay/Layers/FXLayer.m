//
//  FXLayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "FXLayer.h"


@implementation FXLayer
@synthesize effects;

- (id) init
{
	if( (self=[super init]) ) 
    {
        self.effects = [CCArray arrayWithCapacity:100];

        CCParticleSystemQuad *explosion = [CCParticleSystemQuad particleWithFile:@"Explosion.plist"];
        [self.effects addObject:explosion];
        
    }
	return self;
}

- (void) start:(int)effect position:(CGPoint)pos
{
    CCParticleSystemQuad *fx = [self.effects objectAtIndex:effect];
    [fx setPosition:pos];
    
    if ( ![self getChildByTag:effect] ) 
    {
        [self addChild:fx z:10 tag:effect];
    }
    
    else 
    { 
        [fx resetSystem]; 
    }
}

- (void) stopAll
{
    CCParticleSystemQuad *tmp_fx = nil;
    CCARRAY_FOREACH([self children], tmp_fx ) 
    {
        [tmp_fx stopSystem];
    }

}

@end