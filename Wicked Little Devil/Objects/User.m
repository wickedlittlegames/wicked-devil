//
//  User.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize udata, highscores, collected, souls, levelprogress, worldprogress, gameKitHelper, powerup, unlocked_world_1, unlocked_world_2, unlocked_world_3, unlocked_world_4, unlocked_world_5, unlocked_world_6;

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
            [self create];
        }
        
        CCLOG(@"SETTING PARAMS BASED ON UDEFAULTS");        
        self.highscores     = [udata objectForKey:@"highscores"];
        self.souls          = [udata objectForKey:@"souls"];
        self.levelprogress  = [udata integerForKey:@"levelprogress"];
        self.worldprogress  = [udata integerForKey:@"worldprogress"];
        self.powerup        = [udata integerForKey:@"powerup"];
        self.unlocked_world_1  = [udata boolForKey:@"unlocked_world_1"];
        self.unlocked_world_2  = [udata boolForKey:@"unlocked_world_2"];
        self.unlocked_world_3  = [udata boolForKey:@"unlocked_world_3"];
        self.unlocked_world_4  = [udata boolForKey:@"unlocked_world_4"];
        self.unlocked_world_5  = [udata boolForKey:@"unlocked_world_5"];
        self.unlocked_world_6  = [udata boolForKey:@"unlocked_world_6"];
        
        if (self.isAvailableForOnlinePlay)
        {
            CCLOG(@"PFUSER IS AVAILABLE AND LINKED TO FACEBOOK");
            self.collected         = [[[PFUser currentUser] objectForKey:@"collected"] intValue];
            self.unlocked_world_1  = [[[PFUser currentUser] objectForKey:@"unlocked_world_1"] boolValue];
            self.unlocked_world_2  = [[[PFUser currentUser] objectForKey:@"unlocked_world_2"] boolValue];
            self.unlocked_world_3  = [[[PFUser currentUser] objectForKey:@"unlocked_world_3"] boolValue];
            self.unlocked_world_4  = [[[PFUser currentUser] objectForKey:@"unlocked_world_4"] boolValue];
            self.unlocked_world_5  = [[[PFUser currentUser] objectForKey:@"unlocked_world_5"] boolValue];
            self.unlocked_world_6  = [[[PFUser currentUser] objectForKey:@"unlocked_world_6"] boolValue];
        }
        
        //[self gameKitBlock];
    }
    return self;
}

- (void) create
{
    NSMutableArray *tmp_worlds = [NSMutableArray arrayWithCapacity:WORLDS_PER_GAME];
    NSMutableArray *tmp_worlds_souls = [NSMutableArray arrayWithCapacity:WORLDS_PER_GAME];
    for (int w = 1; w <= WORLDS_PER_GAME; w++)
    {
        NSMutableArray *w = [NSMutableArray arrayWithCapacity:LEVELS_PER_WORLD];
        for (int lvl = 1; lvl <= LEVELS_PER_WORLD; lvl++)
        {
            [w addObject:[NSNumber numberWithInt:0]];
        }
        [tmp_worlds addObject:w];
        [tmp_worlds_souls addObject:w];
    }
    NSArray *worlds = tmp_worlds;
    NSArray *world_souls = tmp_worlds_souls;
    
    [udata setObject:worlds forKey:@"highscores"];
    [udata setObject:world_souls forKey:@"souls"];
    [udata setInteger:1 forKey:@"levelprogress"];
    [udata setInteger:1 forKey:@"worldprogress"];
    [udata setInteger:0 forKey:@"powerup"];
    [udata setBool:TRUE  forKey:@"unlocked_world_1"];
    [udata setBool:FALSE forKey:@"unlocked_world_2"];
    [udata setBool:FALSE forKey:@"unlocked_world_3"];
    [udata setBool:FALSE forKey:@"unlocked_world_4"];
    [udata setBool:FALSE forKey:@"unlocked_world_5"];
    [udata setBool:FALSE forKey:@"unlocked_world_6"];    
    
    [udata setBool:TRUE forKey:@"created"];
    
    [udata synchronize];
}

- (void) sync
{
    [udata setInteger:self.levelprogress forKey:@"levelprogress"];
    [udata setInteger:self.worldprogress forKey:@"worldprogress"];
    [udata setInteger:self.powerup forKey:@"powerup"];
    [udata synchronize];
    
    if ( self.isAvailableForOnlinePlay )
    {
        [[PFUser currentUser] setValue:[NSNumber numberWithInt:self.collected] forKey:@"collected"];
        [[PFUser currentUser] saveInBackground];
    }
}

- (void) reset
{
    [udata setBool:FALSE forKey:@"created"];
    [udata synchronize];
}


- (BOOL) parse_create:(id)result
{
    [[PFUser currentUser] setObject:[result objectForKey:@"id"] forKey:@"fbId"];
    [[PFUser currentUser] setObject:[result objectForKey:@"name"] forKey:@"fbName"];
    [[PFUser currentUser] setObject:[result objectForKey:@"email"] forKey:@"email"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:100] forKey:@"collected"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:1] forKey:@"unlocked_world_1"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"unlocked_world_2"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"unlocked_world_3"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"unlocked_world_4"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"unlocked_world_5"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"unlocked_world_6"];
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if ( succeeded )
        {
            self.collected = [[[PFUser currentUser] objectForKey:@"collected"] intValue];
        }
        else 
        {
            NSLog(@"THERE WERE ERRORS: %@",error);
        }
    }];
    
    return (self.collected >= 100);
}

- (BOOL) parse_login;
{ 
    self.collected = [[[PFUser currentUser] objectForKey:@"collected"] intValue];
    self.unlocked_world_1  = [[[PFUser currentUser] objectForKey:@"unlocked_world_1"] boolValue];
    self.unlocked_world_2  = [[[PFUser currentUser] objectForKey:@"unlocked_world_2"] boolValue];
    self.unlocked_world_3  = [[[PFUser currentUser] objectForKey:@"unlocked_world_3"] boolValue];
    self.unlocked_world_4  = [[[PFUser currentUser] objectForKey:@"unlocked_world_4"] boolValue];
    self.unlocked_world_5  = [[[PFUser currentUser] objectForKey:@"unlocked_world_5"] boolValue];
    self.unlocked_world_6  = [[[PFUser currentUser] objectForKey:@"unlocked_world_6"] boolValue];
    
    [self sync];
    
    return TRUE;
}

- (void) parse_logout
{
    [PFUser logOut];
}

- (BOOL) isOnline
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];  
    NetworkStatus networkStatus = [reachability currentReachabilityStatus]; 
    return !(networkStatus == NotReachable);
}

- (BOOL) isConnectedToFacebook
{
    return ([PFUser currentUser] && [self isOnline] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]);
}

- (BOOL) isAvailableForOnlinePlay
{
    return (self.isConnectedToFacebook && self.isOnline);
}

- (void) setHighscore:(int)score world:(int)w level:(int)l
{
    CCLOG(@"SETTING HIGHSCORE");
    CCLOG(@"WORLD: %i | LEVEL %i",w, l);
    NSMutableArray *highscores_tmp = [[udata objectForKey:@"highscores"] mutableCopy];
    CCLOG(@"MUTABLE ARRAY: %@", highscores_tmp);
    int current_highscore = [self getHighscoreforWorld:w level:l];
    CCLOG(@"CURRENT HIGHSCORE: %i", current_highscore);
    if (score > current_highscore)
    {
        CCLOG(@"UPDATING BECAUSE ITS HIGHER");
        // Updating Local
        NSMutableArray *tmp = [[highscores_tmp objectAtIndex:w-1] mutableCopy];
        CCLOG(@"SUB MUTABLE ARRAY: %@",tmp);
        [tmp replaceObjectAtIndex:l-1 withObject:[NSNumber numberWithInt:score]];
        [highscores_tmp replaceObjectAtIndex:w-1 withObject:tmp];
        CCLOG(@"REPLACED OBJECT AT INDEX");
        NSArray *highscore = highscores_tmp;
        CCLOG(@"HIGHSCORE ARRAY: %@",highscore);
        [udata setObject:highscore forKey:@"highscores"];
        CCLOG(@"HIGHSCORE SET IN UDATA");        
        [udata synchronize];
        CCLOG(@"HIGHSCORE SYNCD");
        // Updating Parse
        if ( self.isAvailableForOnlinePlay )
        {
            PFObject *highscore = [PFObject objectWithClassName:@"Highscore"];
            [highscore setObject:[[PFUser currentUser] objectForKey:@"fbId"] forKey:@"user"];        
            [highscore setObject:[NSNumber numberWithInt:w] forKey:@"world"];
            [highscore setObject:[NSNumber numberWithInt:l] forKey:@"level"];
            [highscore setObject:[NSNumber numberWithInt:score] forKey:@"score"];
            [[PFUser currentUser] save];
        }
        
        // Updating Leaderboards
        GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
        if (localPlayer.authenticated)
        {
            [self.gameKitHelper submitScore:score category:[NSString stringWithFormat:@"world-%i-level-%i",w,l]];
        }
    }

}
- (void) setSouls:(int)tmp_souls world:(int)w level:(int)l
{
    NSMutableArray *souls_tmp = [[udata objectForKey:@"souls"] mutableCopy];
    
    int current_total = [self getSoulsforWorld:w level:l];
    
    if (tmp_souls > current_total)
    {
        NSMutableArray *tmp = [[souls_tmp objectAtIndex:w-1] mutableCopy];
        [tmp replaceObjectAtIndex:l-1 withObject:[NSNumber numberWithInt:tmp_souls]];
        [souls_tmp replaceObjectAtIndex:w-1 withObject:tmp];        
        NSArray *souls_arr = souls_tmp;
        [udata setObject:souls_arr forKey:@"souls"];
        [udata synchronize];
    }
}

- (int) getHighscoreforWorld:(int)w
{
    NSMutableArray *tmp = [udata objectForKey:@"highscores"];
    NSMutableArray *tmp2= [tmp objectAtIndex:w-1];
    int tmp_score = 0;
    if ( [tmp2 count] > 0 )
    {
        for (int i = 0; i < [tmp2 count]; i++)
        {
            tmp_score += [[tmp2 objectAtIndex:i]intValue];
        }
    }
    
    return tmp_score;
}

- (int) getHighscoreforWorld:(int)w level:(int)l
{
    NSMutableArray *tmp = [udata objectForKey:@"highscores"];
    NSMutableArray *tmp2= [tmp objectAtIndex:w-1];
    
    return (int)[[tmp2 objectAtIndex:l-1] intValue];
}

- (int) getSoulsforWorld:(int)w
{
    NSMutableArray *tmp = [udata objectForKey:@"souls"];
    NSMutableArray *tmp2= [tmp objectAtIndex:w-1];
    int tmp_score = 0;
    
    if ( [tmp2 count] > 0 )
    {
        for (int i = 0; i < [tmp2 count]; i++)
        {
            tmp_score += [[tmp2 objectAtIndex:i]intValue];
        }
    }
    
    return tmp_score;
}

- (int) getSoulsforWorld:(int)w level:(int)l
{
    NSMutableArray *tmp = [udata objectForKey:@"souls"];
    NSMutableArray *tmp2= [tmp objectAtIndex:w-1];

    return (int)[[tmp2 objectAtIndex:l-1] intValue];
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
