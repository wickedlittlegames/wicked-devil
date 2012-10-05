//
//  GameOverFacebookScene.m
//  Wicked Little Devil
//
//  Created by Andy on 05/10/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "GameOverFacebookScene.h"
#import "MKInfoPanel.h"
#import "Game.h"

@implementation GameOverFacebookScene

+ (CCScene*) sceneWithGame:(Game *)game
{
    CCScene *scene = [CCScene node];
    GameOverFacebookScene *current = [[GameOverFacebookScene alloc] initWithGame:game];
    [scene addChild:current];
	return scene;
}

- (id) initWithGame:(Game*)game
{
    if( (self=[super init]) )
    {
        int gamescore = 0;
        for (int i = 1; i <= CURRENT_WORLDS_PER_GAME; i++)
        {
            gamescore += [game.user getHighscoreforWorld:i];
        }
        
        if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
        {
            NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [NSString stringWithFormat:@"%i",gamescore], @"score",
                                          [[PFFacebookUtils session] accessToken],@"access_token",
                                          nil];
            NSString *requestPath = [NSString stringWithFormat:@"%@/scores",game.user.facebook_id];
            [[PFFacebookUtils facebook] requestWithGraphPath:requestPath andParams:param andHttpMethod:@"POST" andDelegate:self];
        }
    }
    return self;
}

- (void) request:(PF_FBRequest *)request didLoad:(id)result
{
    CCLOG(@"REQUEST: %@",request);
    CCLOG(@"SCORE LOGGED");
    CCLOG(@"RESULT: %@", result);
}

@end
