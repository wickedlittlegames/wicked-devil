//
//  GameOverScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 13/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "GameOverScene.h"


@implementation GameOverScene
@synthesize score, timebonus, bigs, world, level;

+(CCScene *) sceneWithScore:(int)_score timebonus:(int)_timebonus bigs:(int)_bigs forWorld:(int)_world andLevel:(int)_level
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    // Grab the layers
	GameOverScene *current = [GameOverScene node];
    [current setScore:_score];
    [current setTimebonus:_timebonus];
    [current setBigs:_bigs];
    [current setWorld:_world];
    [current setLevel:_level];
    
    // Fill the scene
	[scene addChild:current];
    [current do_scores];
    
    // Show the scene
	return scene;
}

-(id) init
{
    if( (self=[super init]) ) 
    {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        NSString *font = @"Marker Felt";
        int fontsize = 18;
        
        user = [[User alloc] init];
        
        CCMenuItem *back = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"BACK" fontName:font fontSize:fontsize] target:self selector:@selector(tap_back)];
        CCMenu *menu_back = [CCMenu menuWithItems:back, nil];
        menu_back.position = ccp ( screenSize.width - 80, 10 );
        [self addChild:menu_back z:100];
        
    }
    return self;
}

- (void) tap_back
{
    [[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene]];
}

- (void) do_scores
{
    if ( bigs >= 1 )
    {
        int facebook_bonus = ( user.isConnectedToFacebook ? 200 : 0 );
        
        total = (score * bigs) + timebonus + facebook_bonus;
        
        CCLOG(@"SCORE IS: %i (basic: %i, bigs: %i, timebonus: %i, fb: %i)", total, score, bigs, timebonus, facebook_bonus);
        
        // Step through the animations for the scores
        [self anim_start];
    }
    else 
    {
        CCLOG(@"NO BIGS");
    }
}

- (void) anim_start
{
    CCLOG(@"ANIM START");
    [self anim_1];
}

- (void) anim_1
{
    CCLOG(@"ANIM 1");    
    [self anim_2];
}

- (void) anim_2
{
    CCLOG(@"ANIM 2");    
    [self anim_3];
}

- (void) anim_3
{
    CCLOG(@"ANIM 3");
    [self anim_end];
}

- (void) anim_end
{
    CCLOG(@"ANIM END");
    if (total > [user getHighscoreforWorld:world level:level])
    {
        // Show the highscore animation
        [self anim_highscore];
    }
    
    [self anim_menufade];
}

- (void) anim_highscore
{
    CCLOG(@"ANIM HIGHSCORE");
}

- (void) anim_menufade
{
    CCLOG(@"ANIM MENUFADE");
}

@end
