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

        // 0 - mine explosion
        CCParticleSystemQuad *fx0 = [CCParticleSystemQuad particleWithFile:@"Explosion.plist"];
        [self.effects addObject:fx0];
        
        // 1 - big collectable collect
        CCParticleSystemQuad *fx1 = [CCParticleSystemQuad particleWithFile:@"Explosion.plist"];
        [self.effects addObject:fx1];
        
        // 2 - big collectable zap to to left
        CCParticleSystemQuad *fx2 = [CCParticleSystemQuad particleWithFile:@"Explosion.plist"];
        [self.effects addObject:fx2];
        
        // 3 - angel blast
        CCParticleSystemQuad *fx3 = [CCParticleSystemQuad particleWithFile:@"Explosion.plist"];
        [self.effects addObject:fx3];
        
        // 4 - falling bricks
        CCParticleSystemQuad *fx4 = [CCParticleSystemQuad particleWithFile:@"Explosion.plist"];
        [self.effects addObject:fx4];
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

- (void) showWarningAtPosition:(CGPoint)tmp_pos
{
    CCSprite *warning = [CCSprite spriteWithFile:@"helpertext-collectsouls.png"];
    [warning setPosition:ccp(tmp_pos.x + [warning contentSize].width, tmp_pos.y)];
    [self addChild:warning];
    
    id delay = [CCDelayTime actionWithDuration:1.0];
    id fadeOut = [CCFadeOut actionWithDuration:0.5];
    id killSprite = [CCCallBlock actionWithBlock:^(void){ [self removeFromParentAndCleanup:YES]; } ];
    
    [warning runAction:[CCSequence actions:delay, fadeOut, killSprite, nil]];
}

@end