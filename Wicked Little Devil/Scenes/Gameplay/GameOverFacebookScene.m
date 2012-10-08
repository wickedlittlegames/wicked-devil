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
        app = (AppController*) [[UIApplication sharedApplication] delegate];
        
        CCSprite *bg = [CCSprite spriteWithFile:@"bg-facebook-compare.png"];
        [bg setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        [self addChild:bg];
        
        CCMenu *menu_back  = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-back.png"    selectedImage:@"btn-back.png" block:^(id sender) {[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameOverScene  sceneWithGame:game]]];}  ],nil];
        [menu_back setPosition:ccp(25, 25)];
        [self addChild:menu_back];
        
        int gamescore = 0;
        self.request_tag = 0;
        imageData = [[NSMutableData alloc] init];
        imageData2 = [[NSMutableData alloc] init];
        imageData3 = [[NSMutableData alloc] init];

        [MBProgressHUD showHUDAddedTo:[app navController].view animated:YES];
        for (int i = 1; i <= CURRENT_WORLDS_PER_GAME; i++) {  gamescore += [game.user getHighscoreforWorld:i]; }
        
        if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
        {
            NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [NSString stringWithFormat:@"%i",gamescore], @"score",
                                          [[PFFacebookUtils session] accessToken],@"access_token",
                                          nil];
            PF_FBRequest *req = [[PF_FBRequest alloc] initWithSession:[PFFacebookUtils session] graphPath:@"me/scores" parameters:param HTTPMethod:@"POST"];
            [req startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
                if ( error != nil )
                {
                    [MBProgressHUD hideHUDForView:[app navController].view animated:YES];
                    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameOverScene  sceneWithGame:game]]];
                }
                else
                {
                    NSMutableDictionary *param2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[PFFacebookUtils session] accessToken],@"access_token",nil];
                    [[PFFacebookUtils facebook] requestWithGraphPath:[NSString stringWithFormat:@"%@/scores",[[PFFacebookUtils session] appID]] andParams:param2 andHttpMethod:@"GET" andDelegate:self];
                }
            }];
        }
    }
    return self;
}

- (void) request:(PF_FBRequest *)request didLoad:(id)result
{
    NSArray *friendScores = (NSArray *)[result objectForKey:@"data"];
    int top3_counter = 1;
    for(int i = 0; i < friendScores.count; i++)
    {
        if ( top3_counter <= 3)
        {
            NSString *fb_id    = [[[friendScores objectAtIndex:i] objectForKey:@"user"] objectForKey:@"id"];
            NSString *fb_name  = [[[friendScores objectAtIndex:i] objectForKey:@"user"] objectForKey:@"name"];
            NSString *fb_score = [[friendScores objectAtIndex:i] objectForKey:@"score"];
            NSString *fb_url   = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1",fb_id];
            self.request_tag   = top3_counter;
            
            CCLOG(@"%i: %@ SCORED %@ FB ID: %@ URL: %@",self.request_tag, fb_name, fb_score, fb_id, fb_url);
            
            NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:fb_url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0];
            if ( top3_counter == 1)
            {
                fb_name1 = fb_name;
                fb_score1 = fb_score;
                urlConnection = [NSURLConnection connectionWithRequest:req delegate:self];
            }
            if ( top3_counter == 2)
            {
                fb_name2 = fb_name;
                fb_score2 = fb_score;
                urlConnection2 = [NSURLConnection connectionWithRequest:req delegate:self];
            }
            if ( top3_counter == 3 )
            {
                fb_name3 = fb_name;
                fb_score3 = fb_score;
                urlConnection3 = [NSURLConnection connectionWithRequest:req delegate:self];
            }
        }
        top3_counter++;
    }

    [MBProgressHUD hideHUDForView:[app navController].view animated:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(connection == urlConnection){
        [imageData appendData:data];
    }
    else if(connection == urlConnection2){
        [imageData2 appendData:data];
    }
    else if(connection == urlConnection3){
        [imageData3 appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(connection == urlConnection){
        CCLabelTTF *fbscore1 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@",fb_score1] dimensions:CGSizeMake(180/2, 50) alignment:kCCTextAlignmentCenter fontName:@"CrashLanding BB" fontSize:24];
        fbscore1.position = ccp( 60,[[CCDirector sharedDirector] winSize].height - 260);
        fbscore1.color = ccc3(205, 51, 51);
        [self addChild:fbscore1];
        
        CCLabelTTF *fbname1 = [CCLabelTTF labelWithString:fb_name1 dimensions:CGSizeMake(180/2, 100) alignment:kCCTextAlignmentCenter fontName:@"CrashLanding BB" fontSize:28];
        fbname1.position = ccp( 60,fbscore1.position.y - 20);
        fbname1.color = ccBLACK;
        [self addChild:fbname1];
                
        CCSprite *fbimage = [CCSprite spriteWithCGImage:[UIImage imageWithData:imageData].CGImage key:@"facebook_image1"];
        [fbimage setPosition:ccp(60,[[CCDirector sharedDirector] winSize].height - 119)];
        [self resizeSprite:fbimage toWidth:180/2 toHeight:159/2];
        [self addChild:fbimage];
    }
    else if(connection == urlConnection2){
        CCLabelTTF *fbscore2 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@",fb_score2] dimensions:CGSizeMake(180/2, 100) alignment:kCCTextAlignmentCenter fontName:@"CrashLanding BB" fontSize:24];
        fbscore2.position = ccp( 161,[[CCDirector sharedDirector] winSize].height - 260);
        fbscore2.color = ccc3(205, 51, 51);
        [self addChild:fbscore2];
        
        CCLabelTTF *fbname2 = [CCLabelTTF labelWithString:fb_name2 dimensions:CGSizeMake(180/2, 100) alignment:kCCTextAlignmentCenter fontName:@"CrashLanding BB" fontSize:28];
        fbname2.position = ccp( 161,fbscore2.position.y - 20);
        fbname2.color = ccBLACK;
        [self addChild:fbname2];
        
        CCSprite *fbimage = [CCSprite spriteWithCGImage:[UIImage imageWithData:imageData2].CGImage key:@"facebook_image2"];
        [fbimage setPosition:ccp(161,[[CCDirector sharedDirector] winSize].height - 119)];
        [self resizeSprite:fbimage toWidth:180/2 toHeight:159/2];
        [self addChild:fbimage];
    }
    else if(connection == urlConnection3){
        CCLabelTTF *fbscore3 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@",fb_score3] dimensions:CGSizeMake(180/2, 100) alignment:kCCTextAlignmentCenter fontName:@"CrashLanding BB" fontSize:24];
        fbscore3.position = ccp( 261,[[CCDirector sharedDirector] winSize].height - 260);
        fbscore3.color = ccc3(205, 51, 51);
        [self addChild:fbscore3];
        
        CCLabelTTF *fbname3 = [CCLabelTTF labelWithString:fb_name3 dimensions:CGSizeMake(180/2, 100) alignment:kCCTextAlignmentCenter fontName:@"CrashLanding BB" fontSize:28];
        fbname3.position = ccp( 261,fbscore3.position.y - 20);
        fbname3.color = ccBLACK;
        [self addChild:fbname3];

        CCSprite *fbimage = [CCSprite spriteWithCGImage:[UIImage imageWithData:imageData3].CGImage key:@"facebook_image3"];
        [fbimage setPosition:ccp(261,[[CCDirector sharedDirector] winSize].height - 119)];
        [self resizeSprite:fbimage toWidth:180/2 toHeight:159/2];
        [self addChild:fbimage];
    }
}

-(void)resizeSprite:(CCSprite*)sprite toWidth:(float)width toHeight:(float)height {
    sprite.scaleX = width / sprite.contentSize.width;
    sprite.scaleY = height / sprite.contentSize.height;
}

@end
