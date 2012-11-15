//
//  GameOverFacebookScene.m
//  Wicked Little Devil
//
//  Created by Andy on 05/10/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "GameOverFacebookScene.h"
#import "GameOverScene.h"
#import "StartScene.h"
#import "WorldSelectScene.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "Game.h"

#import "FacebookTableCell.h"

@implementation GameOverFacebookScene
@synthesize fromSceneID;

+(CCScene *) sceneWithGame:(Game*)game fromScene:(int)sceneID
{
    CCScene *scene = [CCScene node];
    GameOverFacebookScene *current = [[GameOverFacebookScene alloc] initWithGame:game fromScene:sceneID];
    [scene addChild:current];
    
	return scene;
}

- (id) initWithGame:(Game*)game fromScene:(int)sceneID
{
    if( (self=[super init]) )
    {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        self.fromSceneID = sceneID;
        app = (AppController*) [[UIApplication sharedApplication] delegate];
        timeout_check = 0;
        fbdata    = [NSMutableArray arrayWithObjects:nil];
        fbdata2    = [NSMutableArray arrayWithObjects:nil];
        fbdata3  = [NSMutableArray arrayWithObjects:nil];
        
        CCSprite *bg = [CCSprite spriteWithFile:(IS_IPHONE5 ? @"bg-facebookfriends-iphone5.png" : @"bg-facebookfriends.png")];
        [bg setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        [self addChild:bg];

        CCMenu *menu_back  = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-back.png"    selectedImage:@"btn-back.png" block:^(id sender)
        {
            if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
            
            if ( fromSceneID == 1 )
            {
                [view removeFromSuperview];[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[StartScene  scene]]];
            }
            else if ( fromSceneID == 2 )
            {
                [view removeFromSuperview];[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[WorldSelectScene scene]]];
            }
            else
            {
                [view removeFromSuperview];[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameOverScene  sceneWithGame:game]]];
            }                           
        }  ],nil];
        [menu_back setPosition:ccp(25, 25)];
        [self addChild:menu_back];
        
        CCMenu *inviteFriends = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-invitefriends.png" selectedImage:@"btn-invitefriends.png"  target:self selector:@selector(tap_invite)],nil];
        [inviteFriends           setPosition:ccp(screenSize.width - 80, 25)];
        [self addChild:inviteFriends];
                
        gamescore = 0;

        [MBProgressHUD showHUDAddedTo:[app navController].view animated:YES];
        [self schedule:@selector(timeoutchecker) interval:1.0f];
        for (int i = 1; i <= CURRENT_WORLDS_PER_GAME; i++) {  gamescore += [game.user getHighscoreforWorld:i]; }
        
        CCLabelTTF *lbl_yourscore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"YOUR SCORE: %i",gamescore] fontName:@"CrashLanding BB" fontSize:26];
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
                    if ( fromSceneID == 1 )
                    {
                        [view removeFromSuperview];[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[StartScene  scene]]];
                    }
                    else if ( fromSceneID == 2 )
                    {
                        [view removeFromSuperview];[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[WorldSelectScene scene]]];
                    }
                    else
                    {
                        [view removeFromSuperview];[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameOverScene  sceneWithGame:game]]];
                    }
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
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleSwipeLeft:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [table addGestureRecognizer:recognizer];
    
    //Add a right swipe gesture recognizer
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(handleSwipeRight:)];
    recognizer.delegate = self;
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [table addGestureRecognizer:recognizer];
    
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
    cell.nameLabel.font           = [UIFont fontWithName:@"CrashLanding BB" size:22.0f];
    cell.scoreLabel.font           = [UIFont fontWithName:@"CrashLanding BB" size:22.0f];
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    
    int player_score = [[fbdata2 objectAtIndex:indexPath.row] intValue];
    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:player_score]];

    	
    cell.nameLabel.text        = [NSString stringWithFormat:@"%@",[fbdata objectAtIndex:indexPath.row]];
    cell.scoreLabel.text       = formatted;

    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[fbdata3 objectAtIndex:indexPath.row]]];
        cell.facebookImageView.image = [UIImage imageWithData:image];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.facebookImageView.image = [UIImage imageWithData:image];
        });
    });
    
    cell.facebookImageView.contentMode  = UIViewContentModeScaleAspectFit;
    cell.facebookImageView.clipsToBounds = YES;

    return cell;
}

- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer
{
    // do nothing
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer
{
//    //Get location of the swipe
//    CGPoint location = [gestureRecognizer locationInView:table];
//    
//    //Get the corresponding index path within the table view
//    NSIndexPath *indexPath = [table indexPathForRowAtPoint:location];
//    
//    //Check if index path is valid
//    if(indexPath)
//    {
//        //Get the cell out of the table view
//        UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
//    }
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{ return [fbdata count]; }
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { return 42.0; }

@end
