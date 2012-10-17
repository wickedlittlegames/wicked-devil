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

#import "FacebookTableCell.h"

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
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        app = (AppController*) [[UIApplication sharedApplication] delegate];
        timeout_check = 0;
        fbdata    = [NSMutableArray arrayWithObjects:nil];
        fbdata2    = [NSMutableArray arrayWithObjects:nil];
        fbdata3  = [NSMutableArray arrayWithObjects:nil];
        
        CCSprite *bg = [CCSprite spriteWithFile:(IS_IPHONE5 ? @"bg-facebookfriends-iphone5.png" : @"bg-facebookfriends.png")];
        [bg setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        [self addChild:bg];

        CCMenu *menu_back  = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-back.png"    selectedImage:@"btn-back.png" block:^(id sender) {[view removeFromSuperview];[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameOverScene  sceneWithGame:game]]];}  ],nil];
        [menu_back setPosition:ccp(25, 25)];
        [self addChild:menu_back];
        
        CCMenu *inviteFriends = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-invitefriends.png" selectedImage:@"btn-invitefriends.png"  target:self selector:@selector(tap_invite)],nil];
        [inviteFriends           setPosition:ccp(screenSize.width - 80, 25)];
        [self addChild:inviteFriends];
                
        int gamescore = 0;

        [MBProgressHUD showHUDAddedTo:[app navController].view animated:YES];
        [self schedule:@selector(timeoutchecker) interval:1.0f];
        for (int i = 1; i <= CURRENT_WORLDS_PER_GAME; i++) {  gamescore += [game.user getHighscoreforWorld:i]; }
        
        CCLabelTTF *lbl_yourscore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"YOUR GAME SCORE: %i",gamescore] fontName:@"CrashLanding BB" fontSize:30];
        [lbl_yourscore setPosition:ccp(screenSize.width/2, screenSize.height - 85)];
        lbl_yourscore.color = ccBLACK;
        [self addChild:lbl_yourscore];
                                                  
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

- (void) tap_invite
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"Wicked Devil", @"title",
                                   @"Can you beat my escape from Hell?.",  @"message",
                                   nil];

    [[PFFacebookUtils facebook] dialog:@"apprequests" andParams:params andDelegate:self];
}

- (void) timeoutchecker
{
    timeout_check++;
    if ( timeout_check == 20 )
    {
        [self unschedule:@selector(timeoutchecker)];
        [MBProgressHUD hideHUDForView:[app navController].view animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Facebook Error!"
                                  message:@"Could not connect to Facebook."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void) request:(PF_FBRequest *)request didLoad:(id)result
{
    NSArray *friendScores = (NSArray *)[result objectForKey:@"data"];
    for(int i = 0; i < friendScores.count; i++)
    {
        [fbdata addObject:[[[friendScores objectAtIndex:i] objectForKey:@"user"] objectForKey:@"name"]];
        [fbdata2 addObject:[[friendScores objectAtIndex:i] objectForKey:@"score"]];
        [fbdata3 addObject:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1",[[[friendScores objectAtIndex:i] objectForKey:@"user"] objectForKey:@"id"]]];
    }
    
    view    = [[UIView alloc] initWithFrame:CGRectMake(0, 115, [[CCDirector sharedDirector] winSize].width, [[CCDirector sharedDirector] winSize].height - 175)];
    table   = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[CCDirector sharedDirector] winSize].width, [[CCDirector sharedDirector] winSize].height - 175)];
    table.dataSource = self;
    table.delegate   = self;
    [view addSubview:table];
    [app.window addSubview:view];

    timeout_check = 0;
    [self unschedule:@selector(timeoutchecker)];
    [MBProgressHUD hideHUDForView:[app navController].view animated:YES];
    
}

#pragma mark TABLE DELEGATE METHODS

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    
    FacebookTableCell *cell = (FacebookTableCell *)[tableView dequeueReusableCellWithIdentifier:@"FacebookTableCell"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FacebookTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.nameLabel.font           = [UIFont fontWithName:@"CrashLanding BB" size:32.0f];
    cell.scoreLabel.font           = [UIFont fontWithName:@"CrashLanding BB" size:50.0f];
    
    cell.nameLabel.text        = [NSString stringWithFormat:@"%@",[fbdata objectAtIndex:indexPath.row]];
    cell.scoreLabel.text       = [NSString stringWithFormat:@"%@",[fbdata2 objectAtIndex:indexPath.row]];

    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[fbdata3 objectAtIndex:indexPath.row]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.facebookImageView.image = [UIImage imageWithData:image];
        });
    });

    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{ return [fbdata count]; }
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { return 87.0; }

@end
