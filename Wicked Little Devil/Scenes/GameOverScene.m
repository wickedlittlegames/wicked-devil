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
    
    // Show the scene
	return scene;
}

-(id) init
{
    if( (self=[super init]) ) {
        //CGSize screenSize = [CCDirector sharedDirector].winSize;
        //NSString *font = @"Marker Felt";
        //int fontsize = 18;
        
        user = [[User alloc] init];
        
        // Place static elements such as background
        //CCSprite *background = [CCSprite spriteWithFile:@"bg_gameover.png"];
        //[background setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        //[self addChild:background];
        
        if ( bigs >= 1 )
        {
            int facebook_bonus = ( user.isConnectedToFacebook ? 200 : 0 );
            int score_calc = (score * bigs) + timebonus + facebook_bonus;
            
            CCLOG(@"SCORE IS: %i", score_calc);
            
            // Step through the animations for the scores
            // - Show BASIC score
            // - Add on multiplier for bigs
            // - Add on time bonus
            // - Add on potential Facebook bonus!
            // - Final score on fire if highscore
        }
        else 
        {
            // don't do much, just show a fail screen
        }
    }
    return self;
}

@end
