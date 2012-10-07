//
//  GameOverFacebookScene.m
//  Wicked Little Devil
//
//  Created by Andy on 05/10/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "GameOverFacebookScene.h"
#import "GameOverScene.h"
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
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        CCSprite *bg = [CCSprite spriteWithFile:@"bg-facebook-compare.png"];
        [bg setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        [self addChild:bg];
        
        CCMenu *menu_back  = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-back.png"    selectedImage:@"btn-back.png" block:^(id sender)
        {
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameOverScene  sceneWithGame:game]]];
        }  ],nil];
        [menu_back setPosition:ccp(25, 25)];
        [self addChild:menu_back];
        
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
            PF_FBRequest *req = [[PF_FBRequest alloc] initWithSession:[PFFacebookUtils session] graphPath:@"me/scores" parameters:param HTTPMethod:@"POST"];
            [req startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
                self.request_tag = 2;

                [[PFFacebookUtils facebook] requestWithGraphPath:@"me/friends" andDelegate:self];                
            }];


        }
    }
    return self;
}

- (void) request:(PF_FBRequest *)request didLoad:(id)result
{
    NSArray *friendObjects = [result objectForKey:@"data"];
    NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
    for (NSDictionary *friendObject in friendObjects) {
        [friendIds addObject:[friendObject objectForKey:@"id"]];
    }

    NSMutableDictionary *param2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [[PFFacebookUtils session] accessToken],@"access_token",nil];

    PF_FBRequest *req2 = [[PF_FBRequest alloc] initWithSession:[PFFacebookUtils session] graphPath:[NSString stringWithFormat:@"%@/scores",[[PFFacebookUtils session] appID]] parameters:param2 HTTPMethod:@"GET"];
    [req2 startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
        
        NSDictionary *scoreData = (NSDictionary *)result; // The result is a dictionary
        CCLOG(@"SCORE DATA: %@",scoreData);
        int top3_counter = 1;
        for(int i = 0; i < friendObjects.count; i++)
        {
            if ( top3_counter <= 3)
            {
//                NSString *fb_name  = [[scoreData objectForKey:@"user"] objectForKey:@"name"];
                
                //CCLOG(@"NAME: %@, GOT: %@", fb_name, fb_score);
                CCSprite *fb_pic = [CCSprite spriteWithFile:@"btn-fb-score.png"];
                
                [fb_pic setPosition:ccp(100 * top3_counter, 100)];
                [self addChild:fb_pic];
            }
            top3_counter++;
        }
        
    }];
    
    int top3_counter = 1;
    for(int i = 0; i < friendObjects.count; i++)
    {
        if ( top3_counter <= 3)
        {
            NSString *frid = [NSString stringWithFormat:@"%@/scores",[friendIds objectAtIndex:i]];
        }
        top3_counter++;
    }

    
    [MBProgressHUD hideHUDForView:[app navController].view animated:YES];
}

@end
