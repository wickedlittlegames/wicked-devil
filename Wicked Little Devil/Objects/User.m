//
//  User.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize udata, highscores, collected, souls, levelprogress, worldprogress, gameKitHelper, powerup;

-(id) init
{
	if( (self=[super init]) )
    {
        udata = [NSUserDefaults standardUserDefaults];
        
        if ( [udata boolForKey:@"created"] == FALSE )
        {
            [self createUser];
        }
        
        self.highscores     = [udata objectForKey:@"highscores"];
        self.souls          = [udata objectForKey:@"souls"];
        self.collected      = [udata integerForKey:@"collected"];
        self.levelprogress  = [udata integerForKey:@"levelprogress"];
        self.worldprogress  = [udata integerForKey:@"worldprogress"];
        self.powerup        = [udata integerForKey:@"powerup"];
        
        self.gameKitHelper  = [GameKitHelper sharedGameKitHelper];
        self.gameKitHelper.delegate = self;
        if ([self.gameKitHelper isGameCenterAvailable])
        {
            [self.gameKitHelper authenticateLocalPlayer];
        }
    }
    return self;
}

- (void) syncData
{
    [udata setInteger:self.collected forKey:@"collected"];
    [udata setInteger:self.levelprogress forKey:@"levelprogress"];
    [udata setInteger:self.worldprogress forKey:@"worldprogress"];
    [udata setInteger:self.powerup forKey:@"powerup"];
    
    [udata synchronize];
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

    [udata setBool:TRUE forKey:@"created"];
    [udata setObject:tmp2 forKey:@"highscores"];
    [udata setObject:tmp2_souls forKey:@"souls"];
    [udata setInteger:0 forKey:@"collected"];
    [udata setInteger:1 forKey:@"levelprogress"];
    [udata setInteger:1 forKey:@"worldprogress"];
    [udata setInteger:0 forKey:@"powerup"];
    
    [udata synchronize];
}

- (void) resetUser
{
    [udata setBool:FALSE forKey:@"created"];    
    
    [udata synchronize];    
}

#pragma mark GameKitHelper delegate methods
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
