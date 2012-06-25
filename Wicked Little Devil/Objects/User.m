//
//  User.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize udata, highscores, collected, souls, levelprogress, worldprogress, gameKitHelper, powerup, fbid, fbloggedin;

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
        self.fbid           = [udata valueForKey:@"fbid"];
        self.fbloggedin     = FALSE;
        
        if ([PFUser currentUser] && // Check if a user is cached
            [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]] && [self isConnectedToInternet]) // Check if user is linked to Facebook
        {
            PFQuery *query = [PFUser query];
            PFObject *result = [query getObjectWithId:[PFUser currentUser].objectId];
            self.collected = [[result objectForKey:@"collected"] intValue];

            self.fbloggedin = TRUE;
        }
        else 
        {
            self.collected = 0;
            self.fbloggedin = FALSE;
        }
        
        
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
    [udata setValue:NULL forKey:@"fbid"];
    [udata setBool:FALSE forKey:@"fbloggedin"];
    
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

#pragma mark User Utility Methods

- (BOOL) canCollect
{
    return ([self isConnectedToInternet] && self.fbloggedin && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]);
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
    NSMutableArray *tmp = [udata objectForKey:@"highscores"];
    NSMutableArray *tmp2= [tmp objectAtIndex:w-1];
    int current_highscore = (int)[[tmp2 objectAtIndex:lvl-1] intValue];

    if (score > current_highscore)
    {
        [tmp2 replaceObjectAtIndex:lvl-1 withObject:[NSNumber numberWithInt:score]];    
        [udata setObject:tmp forKey:@"highscores"];
        [udata synchronize];
    }
}

- (void) updateSoulForWorld:(int)w andLevel:(int)lvl withTotal:(int)total
{
    NSMutableArray *tmp = [udata objectForKey:@"souls"];
    NSMutableArray *tmp2= [tmp objectAtIndex:w-1];
    int current_total = (int)[[tmp2 objectAtIndex:lvl-1] intValue];
    
    if (total > current_total)
    {
        [tmp2 replaceObjectAtIndex:lvl-1 withObject:[NSNumber numberWithInt:total]];    
        [udata setObject:tmp forKey:@"souls"];
        [udata synchronize];
    }
}



#pragma mark Facebook methods

- (BOOL) isConnectedToInternet 
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];  
    NetworkStatus networkStatus = [reachability currentReachabilityStatus]; 
    return !(networkStatus == NotReachable);
}

- (BOOL) loginWithFacebook
{
    login_success = FALSE;
    NSArray *permissionsArray = [NSArray arrayWithObjects:@"user_about_me",
                                 @"user_birthday",@"user_location",
                                 @"offline_access", nil];

    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            CCLOG(@"Uh oh. The user cancelled the Facebook login.");
            CCLOG(@"ERROR: %@",error);
        } else if (user.isNew) {
            CCLOG(@"USER IS NEW, CREATE ALL THE STUFF");
            [[PFFacebookUtils facebook] requestWithGraphPath:@"me?fields=id,name" andDelegate:self];
            CCLOG(@"USER IS NEW, STUFF CREATED");            
            [udata setBool:TRUE forKey:@"fbloggedin"];
            [udata synchronize];
            login_success = TRUE;
        } else {
            CCLOG(@"USER IS NOT NEW, JUST LOG IN");            
            [udata setBool:TRUE forKey:@"fbloggedin"];
            [udata synchronize];
            login_success = TRUE;
        }
    }];
    
    return login_success;
}

- (void)request:(PF_FBRequest *)request didLoad:(id)result {
    CCLOG(@"CREATING USER CUSTOM PARAMS | fbID, fbName");    
    [[PFUser currentUser] setObject:[result objectForKey:@"id"] forKey:@"fbId"];
    [[PFUser currentUser] setObject:[result objectForKey:@"name"] forKey:@"fbName"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"collected"];
    [[PFUser currentUser] save];

    CCLOG(@"CREATING USER UDATA | fbID, fbName");
    [self.udata setValue:[result objectForKey:@"id"] forKey:@"fbid"];
    [self.udata setValue:[result objectForKey:@"name"] forKey:@"fbname"];
    [self.udata synchronize];
}
     
-(void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error {
 // OAuthException means our session is invalid
 if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"] 
      isEqualToString: @"OAuthException"]) {
     NSLog(@"The facebook token was invalidated");
     [PFUser logOut];
     self.fbloggedin = FALSE;
 } else {
     NSLog(@"Some other error");
     [PFUser logOut];
     self.fbloggedin = FALSE;
 }
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
