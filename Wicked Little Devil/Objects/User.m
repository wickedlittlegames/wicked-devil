//
//  User.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize udata, highscores, collected, souls, items, levelprogress, worldprogress, gameKitHelper, powerup, powerups, cache_current_world;

#pragma mark User creation/persistance methods

-(id) init
{
	if( (self=[super init]) )
    {
        udata = [NSUserDefaults standardUserDefaults];
        
        if ( [udata boolForKey:@"created"] == FALSE )
        {
            [self create];
        }
        
        self.highscores             = [udata objectForKey:@"highscores"];
        self.souls                  = [udata objectForKey:@"souls"];
        self.levelprogress          = [udata integerForKey:@"levelprogress"];
        self.worldprogress          = [udata integerForKey:@"worldprogress"];
        self.powerup                = [udata integerForKey:@"powerup"];
        self.cache_current_world    = [udata integerForKey:@"cache_current_world"];
        self.collected              = [udata integerForKey:@"collected"];
        self.items                  = [udata objectForKey:@"items"];
    }
    return self;
}

- (void) create
{
    CCLOG(@"CREATING USER");
    
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
    
    // items
    NSArray *contentArray = [[NSDictionary 
                              dictionaryWithContentsOfFile:[[NSBundle mainBundle] 
                                                            pathForResource:@"Powerups" 
                                                            ofType:@"plist"]
                              ] objectForKey:@"Powerups"];
    
    NSMutableArray *itemsarr = [NSMutableArray arrayWithCapacity:[contentArray count]];
    for (int i = 0; i <[contentArray count]; i++ )
    {
        if ( i == 0 )
        {
            [itemsarr addObject:[NSNumber numberWithInt:1]];
        }
        else 
        {
            [itemsarr addObject:[NSNumber numberWithInt:0]];
        }
    }
    
    [udata setObject:itemsarr forKey:@"items"];
    [udata setObject:worlds forKey:@"highscores"];
    [udata setObject:world_souls forKey:@"souls"];
    [udata setInteger:1 forKey:@"levelprogress"];
    [udata setInteger:1 forKey:@"worldprogress"];
    [udata setInteger:0 forKey:@"powerup"];
    [udata setInteger:1 forKey:@"cache_current_world"];
    [udata setInteger:0 forKey:@"collected"];
    [udata setBool:FALSE forKey:@"muted"];
    
    [udata setBool:TRUE forKey:@"created"];
    
    [udata synchronize];
}

- (void) reset
{
    [udata setBool:FALSE forKey:@"created"];
    [self create];
    [udata synchronize];
}

- (void) sync
{
    [udata setInteger:self.levelprogress forKey:@"levelprogress"];
    [udata setInteger:self.worldprogress forKey:@"worldprogress"];
    [udata setInteger:self.collected forKey:@"collected"];
    [udata setInteger:self.powerup forKey:@"powerup"];
    [udata synchronize];
}

- (void) sync_cache_current_world
{
    [udata setInteger:self.cache_current_world forKey:@"cache_current_world"];
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

- (void) buyItem:(int)item
{
    NSMutableArray *items_tmp = [[udata objectForKey:@"items"] mutableCopy];
    [items_tmp replaceObjectAtIndex:item withObject:[NSNumber numberWithInt:1]];
    
    [udata setObject:items_tmp forKey:@"items"];
    [udata synchronize];
    
    self.items = [udata objectForKey:@"items"];    
}

- (void) setHighscore:(int)score world:(int)w level:(int)l
{
    NSMutableArray *highscores_tmp = [self.highscores mutableCopy];
    int current_highscore = [self getHighscoreforWorld:w level:l];
    if (score > current_highscore)
    {
        // Updating Local
        NSMutableArray *tmp = [[highscores_tmp objectAtIndex:w-1] mutableCopy];
        [tmp replaceObjectAtIndex:l-1 withObject:[NSNumber numberWithInt:score]];
        [highscores_tmp replaceObjectAtIndex:w-1 withObject:tmp];
        NSArray *highscore = highscores_tmp;
        [udata setObject:highscore forKey:@"highscores"];
        [udata synchronize];
        // Updating Parse
//        if ( self.isConnectedToFacebook )
//        {   
//            PFObject *highscore = [PFObject objectWithClassName:@"Highscore"];
//            [highscore setObject:[PFUser currentUser] forKey:@"user"];
//            [highscore setObject:[[PFUser currentUser] valueForKey:@"fbId"] forKey:@"fbId"];
//            [highscore setObject:[NSNumber numberWithInt:w] forKey:@"world"];
//            [highscore setObject:[NSNumber numberWithInt:l] forKey:@"level"];
//            [highscore setObject:[NSNumber numberWithInt:score] forKey:@"score"];
//            [highscore saveInBackground];
//        }
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
    int tmp_score = 0;
    
    if ( [tmp2 count] > 0 )
    {
        tmp_score = (int)[[tmp2 objectAtIndex:l-1] intValue];
    }
    
    return tmp_score;
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

- (int) getSoulsforAll
{
    int tmp_souls = 0;
    for (int i = 1; i <= WORLDS_PER_GAME; i++)
    {
        for (int l = 1; l<= LEVELS_PER_WORLD; l++)
        {
            tmp_souls += [self getSoulsforWorld:i level:l];
        }
    }
    
    return tmp_souls;
}

- (int) getSoulsforWorld:(int)w level:(int)l
{
    NSMutableArray *tmp = [udata objectForKey:@"souls"];
    NSMutableArray *tmp2= [tmp objectAtIndex:w-1];
    int tmp_score = 0;
    
    if ( [tmp2 count] > 0 )
    {
        tmp_score = (int)[[tmp2 objectAtIndex:l-1] intValue];
    }
    
    return tmp_score;
}

- (void) _log
{
    CCLOG(@"Highscores: %@",self.highscores);
    CCLOG(@"Souls: %@",self.souls);    
    CCLOG(@"World Progress: %i",self.worldprogress);    
    CCLOG(@"Level Progress: %i",self.levelprogress);    
    CCLOG(@"Powerup: %i",self.powerup);    
    CCLOG(@"Cache Current World: %i",self.cache_current_world);    
    CCLOG(@"Collected: %i",self.collected);    
    CCLOG(@"ParseDeets: %@",[PFUser currentUser]);
    CCLOG(@"Items: %@", self.items);
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
