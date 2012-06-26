//
//  User.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize udata, highscores, collected, souls, levelprogress, worldprogress, gameKitHelper, powerup, fbloggedin, fbFriends, unlocked_world_1, unlocked_world_2, unlocked_world_3, unlocked_world_4, unlocked_world_5, unlocked_world_6;

#pragma mark User creation/persistance methods

-(id) init
{
	if( (self=[super init]) )
    {
        CCLOG(@"GRABBING USER DEFAULTS FILE");
        udata = [NSUserDefaults standardUserDefaults];
        
        if ( [udata boolForKey:@"created"] == FALSE )
        {
            CCLOG(@"FIRST TIME, CREATING USER");
            [self createUser];
        }
        
        CCLOG(@"SETTING PARAMS BASED ON UDEFAULTS");        
        self.highscores     = [udata objectForKey:@"highscores"];
        self.souls          = [udata objectForKey:@"souls"];
        self.levelprogress  = [udata integerForKey:@"levelprogress"];
        self.worldprogress  = [udata integerForKey:@"worldprogress"];
        self.powerup        = [udata integerForKey:@"powerup"];
        self.fbloggedin     = [udata boolForKey:@"fbloggedin"];
        self.fbFriends      = [udata arrayForKey:@"fbfriends"];
        self.unlocked_world_1  = [udata boolForKey:@"unlocked_world_1"];
        self.unlocked_world_2  = [udata boolForKey:@"unlocked_world_2"];
        self.unlocked_world_3  = [udata boolForKey:@"unlocked_world_3"];
        self.unlocked_world_4  = [udata boolForKey:@"unlocked_world_4"];
        self.unlocked_world_5  = [udata boolForKey:@"unlocked_world_5"];
        self.unlocked_world_6  = [udata boolForKey:@"unlocked_world_6"];
        
        if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]] && [self isConnectedToInternet] && self.fbloggedin)
        {
            //[[PFUser currentUser] refresh];
            CCLOG(@"PFUSER IS AVAILABLE AND LINKED TO FACEBOOK");
            self.collected = [[[PFUser currentUser] objectForKey:@"collected"] intValue];
            self.unlocked_world_1  = [[[PFUser currentUser] objectForKey:@"unlocked_world_1"] boolValue];
            self.unlocked_world_2  = [[[PFUser currentUser] objectForKey:@"unlocked_world_2"] boolValue];
            self.unlocked_world_3  = [[[PFUser currentUser] objectForKey:@"unlocked_world_3"] boolValue];
            self.unlocked_world_4  = [[[PFUser currentUser] objectForKey:@"unlocked_world_4"] boolValue];
            self.unlocked_world_5  = [[[PFUser currentUser] objectForKey:@"unlocked_world_5"] boolValue];
            self.unlocked_world_6  = [[[PFUser currentUser] objectForKey:@"unlocked_world_6"] boolValue];
            
            [udata  setBool:TRUE forKey:@"fbloggedin"];
            [udata synchronize];
            self.fbloggedin = TRUE;                
        }
        
        CCLOG(@"Highscores: %@",self.highscores);
        CCLOG(@"Souls: %@",self.souls);
        CCLOG(@"World Progress: %i",self.worldprogress);
        CCLOG(@"Level Progress: %i",self.levelprogress);
        CCLOG(@"Collected: %i", self.collected);
        CCLOG(@"Powerup: %@",self.powerup);
        CCLOG(@"FBLogged In: %d",self.fbloggedin);
        CCLOG(@"Friends:%@",self.fbFriends);
        
        //[self gameKitBlock];
    }
    return self;
}

- (void) createUser
{
    NSMutableArray *worlds = [NSMutableArray arrayWithCapacity:WORLDS_PER_GAME];
    NSMutableArray *worlds_souls = [NSMutableArray arrayWithCapacity:WORLDS_PER_GAME];
    for (int w = 1; w <= WORLDS_PER_GAME; w++)
    {
        NSMutableArray *w = [NSMutableArray arrayWithCapacity:LEVELS_PER_WORLD];
        for (int lvl = 1; lvl <= LEVELS_PER_WORLD; lvl++)
        {
            [w addObject:[NSNumber numberWithInt:0]];
        }
        NSArray *tmp = [w copy];
        NSArray *tmp_souls = [w copy];
        [worlds addObject:tmp];
        [worlds_souls addObject:tmp_souls];
    }
    NSArray *tmp2 = [worlds copy];
    NSArray *tmp2_souls = [worlds_souls copy];
    
    [udata setObject:tmp2 forKey:@"highscores"];
    [udata setObject:tmp2_souls forKey:@"souls"];
    [udata setInteger:1 forKey:@"levelprogress"];
    [udata setInteger:1 forKey:@"worldprogress"];
    [udata setInteger:0 forKey:@"powerup"];
    [udata setBool:FALSE forKey:@"fbloggedin"];
    [udata setObject:NULL forKey:@"fbfriends"];
    [udata setBool:TRUE  forKey:@"unlocked_world_1"];
    [udata setBool:FALSE forKey:@"unlocked_world_2"];
    [udata setBool:FALSE forKey:@"unlocked_world_3"];
    [udata setBool:FALSE forKey:@"unlocked_world_4"];
    [udata setBool:FALSE forKey:@"unlocked_world_5"];
    [udata setBool:FALSE forKey:@"unlocked_world_6"];    
    
    [udata setBool:TRUE forKey:@"created"];
    
    [udata synchronize];
}

- (void) resetUser
{
    [udata setBool:FALSE forKey:@"created"];    
    [udata synchronize];
}

- (void) syncData
{
    CCLOG(@"SYNCING DATA");
    [udata setInteger:self.levelprogress forKey:@"levelprogress"];
    [udata setInteger:self.worldprogress forKey:@"worldprogress"];
    [udata setInteger:self.powerup forKey:@"powerup"];
    [udata synchronize];
    
    if ( self.canCollect )
    {
        CCLOG(@"CAN CONNECT");
        [[PFUser currentUser] setValue:[NSNumber numberWithInt:self.collected] forKey:@"collected"];
        [[PFUser currentUser] saveEventually];
    }
}

- (void) syncCollected
{
    if ( self.canCollect )
    {
        [[PFUser currentUser] setValue:[NSNumber numberWithInt:self.collected] forKey:@"collected"];
        [[PFUser currentUser] saveEventually];
    }
}

- (BOOL) canCollect
{
    return ([self isConnectedToInternet] && self.fbloggedin && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]);
}

#pragma mark User Utility Methods

- (NSString*) get_fbId
{
    PFQuery *query = [PFUser query];
    PFObject *result = [query getObjectWithId:[PFUser currentUser].objectId];
    return [result objectForKey:@"fbId"];
}

- (NSString*) get_fbName
{
    PFQuery *query = [PFUser query];
    PFObject *result = [query getObjectWithId:[PFUser currentUser].objectId];
    return [result objectForKey:@"fbName"];
}

- (void) get_fbFriends
{
    [[PFFacebookUtils facebook] requestWithGraphPath:@"me/friends" andDelegate:self];
}

- (void)request:(PF_FBRequest *)request didLoad:(id)result {
    // Assuming no errors, result will be an NSDictionary of your user's friends
    NSArray *friendObjects = [result objectForKey:@"data"];

    NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
    
    // Create a list of friends' Facebook IDs
    for (NSDictionary *friendObject in friendObjects) {
        [friendIds addObject:[friendObject objectForKey:@"id"]];
    }
       
    // Construct a PFUser query that will find friends whose facebook ids are contained
    // in the current user's friend list.
    PFQuery *friendQuery = [PFUser query];
    [friendQuery whereKey:@"fbId" containedIn:friendIds];

    // findObjects will return a list of PFUsers that are friends with the current user
    self.fbFriends = [friendQuery findObjects];
    [udata setObject:self.fbFriends forKey:@"fbfriends"];
    [udata synchronize];
}

-(void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error 
{
    if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"] isEqualToString: @"OAuthException"]) 
    {
        NSLog(@"The facebook token was invalidated");
    } 
    else 
    {
        NSLog(@"Some other error");
    }
    [PFUser logOut];
    self.fbloggedin = FALSE;
    [udata setBool:self.fbloggedin forKey:@"fbloggedin"];
}

- (int) getScoreForWorld:(int)w andLevel:(int)lvl
{
    NSMutableArray *tmp = [udata objectForKey:@"highscores"];
    NSMutableArray *tmp2= [tmp objectAtIndex:w-1];
    
    return (int)[[tmp2 objectAtIndex:lvl-1] intValue];
}

- (int) getScoreForWorldOnly:(int)w
{
    NSMutableArray *tmp = [udata objectForKey:@"highscores"];
    NSMutableArray *tmp2= [tmp objectAtIndex:w-1];
    int tmp_score = 0;
    
    for (int i = 0; i < [tmp2 count]; i++)
    {
        tmp_score += [[tmp2 objectAtIndex:i]intValue];
    }
    
    return tmp_score;
}

- (int) getSoulsForWorld:(int)w andLevel:(int)lvl
{
    NSMutableArray *tmp = [udata objectForKey:@"souls"];
    NSMutableArray *tmp2= [tmp objectAtIndex:w-1];

    return (int)[[tmp2 objectAtIndex:lvl-1] intValue];
}

- (void) updateHighscoreforWorld:(int)w andLevel:(int)lvl withScore:(int)score
{
    CCLOG(@"UPDATING HIGH SCORE: %i | %i | %i ",w, lvl, score);
    NSMutableArray *tmp = [udata objectForKey:@"highscores"];
    NSMutableArray *tmp2= [tmp objectAtIndex:w-1];
    int current_highscore = (int)[[tmp2 objectAtIndex:lvl-1] intValue];
    CCLOG(@"CURRENT HIGHSCORE: %i ",current_highscore);
    if (score > current_highscore)
    {
        CCLOG(@"BETTER - UPDATING THE LOCAL UDATA");
        [tmp2 replaceObjectAtIndex:lvl-1 withObject:[NSNumber numberWithInt:score]];    
        [udata setObject:tmp forKey:@"highscores"];
        [udata synchronize];
        
        CCLOG(@"BETTER - UPDATING THE REMOTE PARSE");        
        PFObject *highscore = [PFObject objectWithClassName:@"Highscore"];
        [highscore setObject:[PFUser currentUser] forKey:@"user"];        
        [highscore setObject:[NSNumber numberWithInt:w] forKey:@"world"];
        [highscore setObject:[NSNumber numberWithInt:lvl] forKey:@"level"];
        [highscore setObject:[NSNumber numberWithInt:score] forKey:@"score"];
        [highscore saveInBackground];

        CCLOG(@"BETTER - UPDATING THE GAMECENTER LEADERBOARDS");
        GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
        if (localPlayer.authenticated)
        {
            [self.gameKitHelper submitScore:score category:[NSString stringWithFormat:@"world-%i-level-%i",w,lvl]];
        }
    }
}

- (void) updateSoulForWorld:(int)w andLevel:(int)lvl withTotal:(int)total
{
    CCLOG(@"UPDATING SOULS: %i | %i | %i ",w, lvl, total);
    NSMutableArray *tmp = [udata objectForKey:@"souls"];
    NSMutableArray *tmp2= [tmp objectAtIndex:w-1];
    int current_total = (int)[[tmp2 objectAtIndex:lvl-1] intValue];
    
    CCLOG(@"CURRENT SOULS: %i ",current_total);
    if (total > current_total)
    {
        CCLOG(@"BETTER - UPDATING THE LOCAL UDATA");        
        [tmp2 replaceObjectAtIndex:lvl-1 withObject:[NSNumber numberWithInt:total]];
        [udata setObject:tmp forKey:@"souls"];
        [udata synchronize];
    }
}

- (BOOL) isConnectedToInternet 
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];  
    NetworkStatus networkStatus = [reachability currentReachabilityStatus]; 
    return !(networkStatus == NotReachable);
}

#pragma mark GameKitHelper delegate methods

- (void) gameKitBlock
{
    self.gameKitHelper  = [GameKitHelper sharedGameKitHelper];
    self.gameKitHelper.delegate = self;
    if ([self.gameKitHelper isGameCenterAvailable])
    {
        [self.gameKitHelper authenticateLocalPlayer];
    }
}

-(void) onLocalPlayerAuthenticationChanged
{
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    CCLOG(@"LocalPlayer isAuthenticated changed to: %@", localPlayer.authenticated ? @"YES" : @"NO");
    
    if (localPlayer.authenticated)
    {
        GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
        [gkHelper getLocalPlayerFriends];
        //[gkHelper resetAchievements];
    }   
}
-(void) onFriendListReceived:(NSArray*)friends
{
    CCLOG(@"onFriendListReceived: %@", [friends description]);
    GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    [gkHelper getPlayerInfo:friends];
}
-(void) onPlayerInfoReceived:(NSArray*)players
{
    CCLOG(@"onPlayerInfoReceived: %@", [players description]);
}
-(void) onScoresSubmitted:(bool)success
{
    CCLOG(@"onScoresSubmitted: %@", success ? @"YES" : @"NO");
}
-(void) onScoresReceived:(NSArray*)scores
{
    CCLOG(@"onScoresReceived: %@", [scores description]);
    GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    [gkHelper showAchievements];
}
-(void) onAchievementReported:(GKAchievement*)achievement
{
    CCLOG(@"onAchievementReported: %@", achievement);
}
-(void) onAchievementsLoaded:(NSDictionary*)achievements
{
    CCLOG(@"onLocalPlayerAchievementsLoaded: %@", [achievements description]);
}
-(void) onResetAchievements:(bool)success
{
    CCLOG(@"onResetAchievements: %@", success ? @"YES" : @"NO");
}
-(void) onLeaderboardViewDismissed
{
    CCLOG(@"onLeaderboardViewDismissed");
    
    GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
    [gkHelper retrieveTopTenAllTimeGlobalScores];
}
-(void) onAchievementsViewDismissed
{
    CCLOG(@"onAchievementsViewDismissed");
}
-(void) onReceivedMatchmakingActivity:(NSInteger)activity
{
    CCLOG(@"receivedMatchmakingActivity: %i", activity);
}
-(void) onMatchFound:(GKMatch*)match
{
    CCLOG(@"onMatchFound: %@", match);
}
-(void) onPlayersAddedToMatch:(bool)success
{
    CCLOG(@"onPlayersAddedToMatch: %@", success ? @"YES" : @"NO");
}
-(void) onMatchmakingViewDismissed
{
    CCLOG(@"onMatchmakingViewDismissed");
}
-(void) onMatchmakingViewError
{
    CCLOG(@"onMatchmakingViewError");
}
-(void) onPlayerConnected:(NSString*)playerID
{
    CCLOG(@"onPlayerConnected: %@", playerID);
}
-(void) onPlayerDisconnected:(NSString*)playerID
{
    CCLOG(@"onPlayerDisconnected: %@", playerID);
}
-(void) onStartMatch
{
    CCLOG(@"onStartMatch");
}
-(void) onReceivedData:(NSData*)data fromPlayer:(NSString*)playerID
{
    CCLOG(@"onReceivedData: %@ fromPlayer: %@", data, playerID);
}
@end
