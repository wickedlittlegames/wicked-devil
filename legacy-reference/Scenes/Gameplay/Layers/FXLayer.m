//
//  FXLayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 17/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "FXLayer.h"

@implementation FXLayer

- (id) init
{
	if( (self=[super init]) ) 
    {
        [self stopAll];
        
        self.effects = [CCArray arrayWithCapacity:100];

        // 0 - mine explosion
        CCParticleSystemQuad *fx0 = [CCParticleSystemQuad particleWithFile:@"AnimExplosion.plist"];
        fx0.positionType = kCCPositionTypeGrouped;
        fx0.blendAdditive = FALSE;
        [fx0 stopSystem];
        [self addChild:fx0];
        [self.effects addObject:fx0];
        
        // 1 - big collectable collect
        CCParticleSystemQuad *fx1 = [CCParticleSystemQuad particleWithFile:@"CollectedBig.plist"];
        fx1.positionType = kCCPositionTypeGrouped;
        fx1.blendAdditive = FALSE;
        [fx1 stopSystem];
        [self addChild:fx1];
        [self.effects addObject:fx1];
        
        // 2 - halo collectable collect
        CCParticleSystemQuad *fx3 = [CCParticleSystemQuad particleWithFile:@"haloCollect.plist"];
        fx3.positionType = kCCPositionTypeGrouped;
        fx3.blendAdditive = FALSE;
        [fx3 stopSystem];
        [self addChild:fx3];
        [self.effects addObject:fx3];
    }
	return self;
}

- (void) start:(int)effect position:(CGPoint)pos
{
    id fx = [self.effects objectAtIndex:effect];
    [fx setPosition:pos];
    [fx resetSystem];
}

- (void) stopAll
{
    CCParticleSystemQuad *tmp_fx = nil;
    CCARRAY_FOREACH([self children], tmp_fx ) 
    {
        [tmp_fx stopSystem];
    }
}

- (void) showWarningAtPosition:(CGPoint)tmp_pos
{
    CCSprite *warning = [CCSprite spriteWithFile:@"ingame-rocket-warning.png"];
    [warning setPosition:ccp(tmp_pos.x, tmp_pos.y)];
    [self addChild:warning z:1000];
    
    id delay = [CCDelayTime actionWithDuration:1.0];
    id fadeOut = [CCFadeOut actionWithDuration:0.5];
    id killSprite = [CCCallBlock actionWithBlock:^(void){ [self removeFromParentAndCleanup:YES]; } ];
    
    [warning runAction:[CCSequence actions:delay, fadeOut, killSprite, nil]];
}

@end