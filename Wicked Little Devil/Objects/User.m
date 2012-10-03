//
//  User.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//

#import "User.h"
#import "AppDelegate.h"
#import "MKInfoPanel.h"

@implementation User
@synthesize udata, highscores, collected, souls, items, levelprogress, worldprogress, powerup, powerups, cache_current_world, gameprogress, deaths, jumps;
@synthesize ach_first_play, ach_beat_world_1, ach_beat_world_2, ach_beat_world_3, ach_beat_world_4, ach_killed, ach_1000_souls, ach_5000_souls, ach_10000_souls, ach_50000_souls, ach_died_100, ach_jumped_1000, ach_first_3_big, ach_collected_666, sent_ach_first_play, sent_ach_beat_world_1, sent_ach_beat_world_2, sent_ach_beat_world_3, sent_ach_beat_world_4, sent_ach_killed, sent_ach_1000_souls, sent_ach_5000_souls, sent_ach_10000_souls, sent_ach_50000_souls, sent_ach_died_100, sent_ach_jumped_1000, sent_ach_first_3_big, sent_ach_collected_666;

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
        self.gameprogress           = [udata objectForKey:@"gameprogress"];
        self.powerup                = [udata integerForKey:@"powerup"];
        self.cache_current_world    = [udata integerForKey:@"cache_current_world"];
        self.collected              = [udata integerForKey:@"collected"];
        self.deaths                 = [udata integerForKey:@"deaths"];
        self.jumps                  = [udata integerForKey:@"jumps"];
        self.items                  = [udata objectForKey:@"items"];
        
        [self setupAchievements];
    }
    return self;
}

- (void) create
{
    NSMutableArray *tmp_worlds = [NSMutableArray arrayWithCapacity:100];
    NSMutableArray *tmp_worlds_souls = [NSMutableArray arrayWithCapacity:100];
    for (int w = 1; w <= WORLDS_PER_GAME; w++)
    {
        NSMutableArray *w = [NSMutableArray arrayWithCapacity:100];
        for (int lvl = 1; lvl <= LEVELS_PER_WORLD; lvl++)
        {
            [w addObject:[NSNumber numberWithInt:0]];
        }
        [tmp_worlds addObject:w];
        [tmp_worlds_souls addObject:w];
    }
    NSArray *worlds = tmp_worlds;
    NSArray *world_souls = tmp_worlds_souls;
    
    // new world progress
    NSMutableArray *tmpworldprogress = [NSMutableArray arrayWithCapacity:100];
    for (int w = 1; w <= WORLDS_PER_GAME; w++ )
    {
        NSMutableArray *tmp_wp = [NSMutableArray arrayWithCapacity:100];
        for (int lvl = 1; lvl <= LEVELS_PER_WORLD; lvl++)
        {
            if ( lvl == 1  && w == 1 ) { [tmp_wp addObject:[NSNumber numberWithInt:1]]; }
            else { [tmp_wp addObject:[NSNumber numberWithInt:0]]; }
        }
        [tmpworldprogress addObject:tmp_wp];
    }
    
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
    [udata setObject:tmpworldprogress forKey:@"gameprogress"];
    [udata setInteger:0 forKey:@"powerup"];
    [udata setInteger:1 forKey:@"cache_current_world"];
    [udata setInteger:0 forKey:@"collected"];
    [udata setInteger:0 forKey:@"deaths"];
    [udata setInteger:0 forKey:@"jumps"];
    [udata setBool:FALSE forKey:@"muted"];
    
    [udata setBool:TRUE forKey:@"created"];
    
    [udata synchronize];
}

- (void) reset
{
    [udata setBool:FALSE forKey:@"created"];
    [self resetAchievements];    
    [self create];
    [udata synchronize];
}

- (void) sync
{
    [udata setInteger:self.levelprogress forKey:@"levelprogress"];
    [udata setInteger:self.worldprogress forKey:@"worldprogress"];
    [udata setInteger:self.deaths forKey:@"deaths"];
    [udata setInteger:self.jumps forKey:@"jumps"];
    [udata setInteger:self.collected forKey:@"collected"];    
    [udata setInteger:self.powerup forKey:@"powerup"];
    [udata synchronize];
}

- (void) sync_cache_current_world
{
    [udata setInteger:self.cache_current_world forKey:@"cache_current_world"];
    [udata synchronize];
}

- (BOOL) isOnline
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];  
    NetworkStatus networkStatus = [reachability currentReachabilityStatus]; 
    return !(networkStatus == NotReachable);
}

- (void) buyItem:(int)item
{
    NSMutableArray *items_tmp = [[udata objectForKey:@"items"] mutableCopy];
    [items_tmp replaceObjectAtIndex:item withObject:[NSNumber numberWithInt:1]];
    
    [udata setObject:items_tmp forKey:@"items"];
    [udata synchronize];
    
    self.items = [udata objectForKey:@"items"];    
}

- (void) setGameProgressforWorld:(int)w level:(int)l
{
    NSMutableArray *gameprogress_tmp = [self.gameprogress mutableCopy];
    NSMutableArray *tmp = [[gameprogress_tmp objectAtIndex:w-1] mutableCopy];
    [tmp replaceObjectAtIndex:l-1 withObject:[NSNumber numberWithInt:1]];
    [gameprogress_tmp replaceObjectAtIndex:w-1 withObject:tmp];
    NSArray *new_gameprogress = gameprogress_tmp;
    [udata setObject:new_gameprogress forKey:@"gameprogress"];
    [udata synchronize];
}

- (void) setHighscore:(int)score world:(int)w level:(int)l
{
    NSMutableArray *highscores_tmp = [self.highscores mutableCopy];
    int current_highscore = [self getHighscoreforWorld:w level:l];
    if (score > current_highscore)
    {
        NSMutableArray *tmp = [[highscores_tmp objectAtIndex:w-1] mutableCopy];
        [tmp replaceObjectAtIndex:l-1 withObject:[NSNumber numberWithInt:score]];
        [highscores_tmp replaceObjectAtIndex:w-1 withObject:tmp];
        NSArray *highscore = highscores_tmp;
        [udata setObject:highscore forKey:@"highscores"];
        [udata synchronize];
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

- (int) getGameProgressforWorld:(int)w level:(int)l
{
    NSMutableArray *tmp = [udata objectForKey:@"gameprogress"];
    NSMutableArray *tmp2 = [tmp objectAtIndex:w-1];
    int tmp_progress = 0;
    
    if ( [[tmp2 objectAtIndex:l-1] intValue] == 1)
    {
        tmp_progress = 1;
    }
    
    return tmp_progress;
    
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
    for (int i = 1; i <= CURRENT_WORLDS_PER_GAME; i++)
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

- (void) check_achiements
{
    if ( !self.ach_first_play ) // if first play
    {
        self.ach_first_play = TRUE;
        [self showAchievementPanel:1];
    }
    if ( self.collected >= 666 && !self.ach_collected_666 ) // if first 666 souls
    {
        self.ach_collected_666 = TRUE;
        [self showAchievementPanel:2];
    }
    if ( self.collected >= 1000 && !self.ach_1000_souls ) // if first 1000 souls
    {
        self.ach_1000_souls = TRUE;
        [self showAchievementPanel:3];
    }
    if ( self.collected >= 5000 && !self.ach_5000_souls ) // first 5000 souls
    {
        self.ach_5000_souls = TRUE;
        [self showAchievementPanel:4];
    }
    if ( self.collected >= 10000 && !self.ach_10000_souls ) // first 10000 souls
    {
        self.ach_10000_souls = TRUE;
        [self showAchievementPanel:5];
    }
    if (self.collected >= 50000 && !self.ach_50000_souls ) // first 50000 souls
    {
        self.ach_50000_souls = TRUE;
        [self showAchievementPanel:6];
    }
    if ( self.worldprogress > 1 && !self.ach_beat_world_1 ) // beat world one
    {
        self.ach_beat_world_1 = TRUE;        
        [self showAchievementPanel:7];
    }
    if ( self.worldprogress > 2 && !self.ach_beat_world_2 ) // beat world two
    {
        self.ach_beat_world_2 = TRUE;
        [self showAchievementPanel:8];
    }
    if ( self.worldprogress > 3 && !self.ach_beat_world_3 ) // beat world 3
    {
        self.ach_beat_world_3 = TRUE;
        [self showAchievementPanel:9];
    }
    if ( self.worldprogress >= 4 && self.levelprogress >= LEVELS_PER_WORLD && !self.ach_beat_world_4 ) // beat world 4
    {
        self.ach_beat_world_4 = TRUE;
        [self showAchievementPanel:10];
    }
    if ( self.deaths >= 1 && !self.ach_killed )
    {
        self.ach_killed = TRUE;        
        [self showAchievementPanel:11];
    }
    if ( self.deaths >= 100 && !self.ach_died_100 )
    {
        self.ach_died_100 = TRUE;                
        [self showAchievementPanel:12];
    }
    if ( self.jumps >= 1000 && !self.ach_jumped_1000 )
    {
        self.ach_jumped_1000 = TRUE;
        [self showAchievementPanel:13];
    }
    [self sync_achievements];
}

- (void) showAchievementPanel:(int)ach_id
{
    NSString *title = @"Achievement Unlocked: ";
    NSString *achievement = @"";
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];

    switch(ach_id)
    {
        case 1: //first play
            achievement = @"First Impressions";
            break;
            
        case 2: //666 souls
            achievement = @"The Number of the Beast";
            break;
            
        case 3: //1000 souls
            achievement = @"Soul Collector";
            break;
            
        case 4: //5000 souls
            achievement = @"Soul Commander";            
            break;
            
        case 5: //10000 souls
            achievement = @"Soul Dominator";
            break;
            
        case 6: //50000 souls
            achievement = @"Soul Master";
            break;
            
        case 7: //beat world 1
            achievement = @"Hell Broke Loose";            
            break;
            
        case 8: //beat world 2
            achievement = @"Ain't No Grave...";                        
            break;
            
        case 9: //beat world 3
            achievement = @"Bubbling Up";
            break;
            
        case 10: //beat world 4
            achievement = @"Free At Last";            
            break;
            
        case 11: //died
            achievement = @"Killed By Death";
            break;
            
        case 12: //died 100 times
            achievement = @"It's Probably Safer In Hell...";
            break;
            
        case 13: //jumped 1000 times
            achievement = @"Van Halen Fan";
            break;
            
        default: break;
    }
    [MKInfoPanel showPanelInView:[app window] type:MKInfoPanelTypeInfo title:title subtitle:[achievement uppercaseString] hideAfter:3];
}


- (void) sync_achievements
{
    [udata setBool:self.ach_beat_world_1 forKey:@"ach_beat_world_1"];
    [udata setBool:self.ach_beat_world_1 forKey:@"ach_beat_world_2"];
    [udata setBool:self.ach_beat_world_1 forKey:@"ach_beat_world_3"];
    [udata setBool:self.ach_beat_world_1 forKey:@"ach_beat_world_4"];
    [udata setBool:self.ach_first_play forKey:@"ach_first_play"];
    [udata setBool:self.ach_first_3_big forKey:@"ach_first_3_big"];
    [udata setBool:self.ach_killed forKey:@"ach_killed"];
    [udata setBool:self.ach_1000_souls forKey:@"ach_1000_souls"];
    [udata setBool:self.ach_5000_souls forKey:@"ach_5000_souls"];
    [udata setBool:self.ach_10000_souls forKey:@"ach_10000_souls"];
    [udata setBool:self.ach_50000_souls forKey:@"ach_50000_souls"];
    [udata setBool:self.ach_died_100 forKey:@"ach_died_100"];
    [udata setBool:self.ach_jumped_1000 forKey:@"ach_jumped_1000"];
    [udata setBool:self.ach_collected_666 forKey:@"ach_collected_666"];
    
    [udata setBool:self.sent_ach_beat_world_1 forKey:@"sent_ach_beat_world_1"];
    [udata setBool:self.sent_ach_beat_world_1 forKey:@"sent_ach_beat_world_2"];
    [udata setBool:self.sent_ach_beat_world_1 forKey:@"sent_ach_beat_world_3"];
    [udata setBool:self.sent_ach_beat_world_1 forKey:@"sent_ach_beat_world_4"];
    [udata setBool:self.sent_ach_first_play forKey:@"sent_ach_first_play"];
    [udata setBool:self.sent_ach_first_3_big forKey:@"sent_ach_first_3_big"];
    [udata setBool:self.sent_ach_killed forKey:@"sent_ach_killed"];
    [udata setBool:self.sent_ach_1000_souls forKey:@"sent_ach_1000_souls"];
    [udata setBool:self.sent_ach_5000_souls forKey:@"sent_ach_5000_souls"];
    [udata setBool:self.sent_ach_10000_souls forKey:@"sent_ach_10000_souls"];
    [udata setBool:self.sent_ach_50000_souls forKey:@"sent_ach_50000_souls"];
    [udata setBool:self.sent_ach_died_100 forKey:@"sent_ach_died_100"];
    [udata setBool:self.sent_ach_jumped_1000 forKey:@"sent_ach_jumped_1000"];
    [udata setBool:self.sent_ach_collected_666 forKey:@"sent_ach_collected_666"];
    
    [udata synchronize];
}

- (void) setupAchievements
{
    self.ach_beat_world_1       = [udata boolForKey:@"ach_beat_world_1"];
    self.ach_beat_world_2       = [udata boolForKey:@"ach_beat_world_2"];
    self.ach_beat_world_3       = [udata boolForKey:@"ach_beat_world_3"];
    self.ach_beat_world_4       = [udata boolForKey:@"ach_beat_world_4"];
    self.ach_first_play         = [udata boolForKey:@"ach_first_play"];
    self.ach_first_3_big        = [udata boolForKey:@"ach_first_3_big"];
    self.ach_killed             = [udata boolForKey:@"ach_killed"];
    self.ach_1000_souls         = [udata boolForKey:@"ach_1000_souls"];
    self.ach_5000_souls         = [udata boolForKey:@"ach_5000_souls"];
    self.ach_10000_souls        = [udata boolForKey:@"ach_10000_souls"];
    self.ach_50000_souls        = [udata boolForKey:@"ach_50000_souls"];
    self.ach_died_100           = [udata boolForKey:@"ach_died_100_times"];
    self.ach_jumped_1000        = [udata boolForKey:@"ach_jumped_1000"];
    self.ach_collected_666      = [udata boolForKey:@"ach_collected_666"];
    
    self.sent_ach_beat_world_1  = [udata boolForKey:@"sent_ach_beat_world_1"];
    self.sent_ach_beat_world_2  = [udata boolForKey:@"sent_ach_beat_world_2"];
    self.sent_ach_beat_world_3  = [udata boolForKey:@"sent_ach_beat_world_3"];
    self.sent_ach_beat_world_4  = [udata boolForKey:@"sent_ach_beat_world_4"];
    self.sent_ach_first_play    = [udata boolForKey:@"sent_ach_first_play"];
    self.sent_ach_first_3_big   = [udata boolForKey:@"sent_ach_first_3_big"];
    self.sent_ach_killed        = [udata boolForKey:@"sent_ach_killed"];
    self.sent_ach_1000_souls    = [udata boolForKey:@"sent_ach_1000_souls"];
    self.sent_ach_5000_souls    = [udata boolForKey:@"sent_ach_5000_souls"];
    self.sent_ach_10000_souls   = [udata boolForKey:@"sent_ach_10000_souls"];
    self.sent_ach_50000_souls   = [udata boolForKey:@"sent_ach_50000_souls"];
    self.sent_ach_died_100      = [udata boolForKey:@"sent_ach_died_100_times"];
    self.sent_ach_jumped_1000   = [udata boolForKey:@"sent_ach_jumped_1000"];
    self.sent_ach_collected_666 = [udata boolForKey:@"sent_ach_collected_666"];
}

- (void) resetAchievements
{
    [udata setBool:FALSE forKey:@"ach_beat_world_1"];
    [udata setBool:FALSE forKey:@"ach_beat_world_2"];
    [udata setBool:FALSE forKey:@"ach_beat_world_3"];
    [udata setBool:FALSE forKey:@"ach_beat_world_4"];
    [udata setBool:FALSE forKey:@"ach_first_play"];
    [udata setBool:FALSE forKey:@"ach_first_3_big"];
    [udata setBool:FALSE forKey:@"ach_killed"];
    [udata setBool:FALSE forKey:@"ach_1000_souls"];
    [udata setBool:FALSE forKey:@"ach_5000_souls"];
    [udata setBool:FALSE forKey:@"ach_10000_souls"];
    [udata setBool:FALSE forKey:@"ach_50000_souls"];
    [udata setBool:FALSE forKey:@"ach_died_100"];
    [udata setBool:FALSE forKey:@"ach_jumped_1000"];
    [udata setBool:FALSE forKey:@"ach_collected_666"];
    
    [udata setBool:FALSE forKey:@"sent_ach_beat_world_1"];
    [udata setBool:FALSE forKey:@"sent_ach_beat_world_2"];
    [udata setBool:FALSE forKey:@"sent_ach_beat_world_3"];
    [udata setBool:FALSE forKey:@"sent_ach_beat_world_4"];
    [udata setBool:FALSE forKey:@"sent_ach_first_play"];
    [udata setBool:FALSE forKey:@"sent_ach_first_3_big"];
    [udata setBool:FALSE forKey:@"sent_ach_killed"];
    [udata setBool:FALSE forKey:@"sent_ach_1000_souls"];
    [udata setBool:FALSE forKey:@"sent_ach_5000_souls"];
    [udata setBool:FALSE forKey:@"sent_ach_10000_souls"];
    [udata setBool:FALSE forKey:@"sent_ach_50000_souls"];
    [udata setBool:FALSE forKey:@"sent_ach_died_100"];
    [udata setBool:FALSE forKey:@"sent_ach_jumped_1000"];
    [udata setBool:FALSE forKey:@"sent_ach_collected_666"];
}


@end
