//
//  GameOverFacebookScene.m
//  Wicked Little Devil
//
//  Created by Andy on 05/10/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "GameOverFacebookScene.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "Game.h"

@implementation GameOverFacebookScene
@synthesize request_tag;

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
        self.request_tag = 1;
        app = (AppController*) [[UIApplication sharedApplication] delegate];
        
        [MBProgressHUD showHUDAddedTo:[app navController].view animated:YES];
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
            //NSString *requestPath = [NSString stringWithFormat:@"%@/scores",game.user.facebook_id];
            
            PF_FBRequest *req = [[PF_FBRequest alloc] initWithSession:[PFFacebookUtils session] graphPath:@"me/scores" parameters:param HTTPMethod:@"POST"];
            [req startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
                CCLOG(@"REQUEST: %@",connection);
                CCLOG(@"SCORE LOGGED");
                CCLOG(@"RESULT: %@", result);
                self.request_tag = 2;

                [[PFFacebookUtils facebook] requestWithGraphPath:@"me/friends" andDelegate:self];                
            }];


        }
    }
    return self;
}

- (void) request:(PF_FBRequest *)request didLoad:(id)result
{
    CCLOG(@"DO FRIENDS THING: %@", request);
    CCLOG(@"DO FRIENDS THING: %@", result);
    NSArray *friendObjects = [result objectForKey:@"data"];
    NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
    for (NSDictionary *friendObject in friendObjects) {
        [friendIds addObject:[friendObject objectForKey:@"id"]];
    }
    CCLOG(@"FRIEND IDS, %@",friendIds);
    NSMutableDictionary *param2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [[PFFacebookUtils session] accessToken],@"access_token",nil];

    PF_FBRequest *req2 = [[PF_FBRequest alloc] initWithSession:[PFFacebookUtils session] graphPath:[NSString stringWithFormat:@"%@/scores",[[PFFacebookUtils session] appID]] parameters:param2 HTTPMethod:@"GET"];
    [req2 startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
        CCLOG(@"FRIEND SCORE REQUEST: %@",connection);
        CCLOG(@"FRIEND SCORE GOT");
        CCLOG(@"FRIEND SCORE RESULT: %@", result);
    }];
    
    
//    for(int i = 0; i < friendObjects.count; i++)
//    {
//        NSString *frid = [NSString stringWithFormat:@"%@/scores",[friendIds objectAtIndex:i]];
//    }

    
    [MBProgressHUD hideHUDForView:[app navController].view animated:YES];
}

@end
