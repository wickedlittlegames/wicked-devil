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

#pragma mark User creation/persistance methods

-(id) init
{
	if( (self=[super init]) )
    {
        self.udata = [NSUserDefaults standardUserDefaults];
        if ( ![self.udata boolForKey:@"created"] )
        {
            [self create];
        }
        if ( ![self.udata objectForKey:@"items_special"] )
        {
            [self create_special_items];
        }
        if ( ![self.udata objectForKey:@"detective_highscores"] )
        {
            [self create_detective_settings];
        }
        if ( ![self.udata objectForKey:@"unlocked_detective"] )
        {
                [self create_detective_settings2];
        }
        
        self.highscores             = [self.udata objectForKey:@"highscores"];
        self.souls                  = [self.udata objectForKey:@"souls"];
        self.detective_highscores   = [self.udata objectForKey:@"detective_highscores"];
        self.detective_souls        = [self.udata objectForKey:@"detective_souls"];
        self.levelprogress          = [self.udata integerForKey:@"levelprogress"];
        self.worldprogress          = [self.udata integerForKey:@"worldprogress"];
        self.gameprogress           = [self.udata objectForKey:@"gameprogress"];
        self.powerup                = [self.udata integerForKey:@"powerup"];
        self.bought_powerups        = [self.udata boolForKey:@"bought_powerups"];
        self.cache_current_world    = [self.udata integerForKey:@"cache_current_world"];
        self.collected              = [self.udata integerForKey:@"collected"];
        self.deaths                 = [self.udata integerForKey:@"deaths"];
        self.jumps                  = [self.udata integerForKey:@"jumps"];
        self.items                  = [self.udata objectForKey:@"items"];
        self.items_special          = [self.udata objectForKey:@"items_special"];
        self.facebook_id            = [self.udata objectForKey:@"facebook_id"];
        self.facebook_image         = [self.udata objectForKey:@"facebook_image"];
        self.unlocked_detective     = [self.udata boolForKey:@"unlocked_detective"];
        
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
    
    NSMutableArray *itemsarr = [NSMutableArray arrayWithCapacity:1000];
    for (int i = 0; i <[contentArray count]; i++ )
    {
        [itemsarr addObject:[NSNumber numberWithInt:0]];
    }
    
    [self.udata setObject:itemsarr forKey:@"items"];
    [self.udata setObject:worlds forKey:@"highscores"];
    [self.udata setObject:world_souls forKey:@"souls"];
    [self.udata setInteger:1 forKey:@"levelprogress"];
    [self.udata setInteger:1 forKey:@"worldprogress"];
    [self.udata setObject:tmpworldprogress forKey:@"gameprogress"];
    [self.udata setInteger:0 forKey:@"powerup"];
    [self.udata setInteger:1 forKey:@"cache_current_world"];
    [self.udata setInteger:0 forKey:@"collected"];
    [self.udata setInteger:0 forKey:@"deaths"];
    [self.udata setInteger:0 forKey:@"jumps"];
    [self.udata setBool:FALSE forKey:@"muted"];
    
    [self.udata setBool:TRUE forKey:@"created"];
    
    [self.udata synchronize];
}

- (void ) create_special_items
{
    NSMutableArray *special_itemsarr = [NSMutableArray arrayWithCapacity:1000];
    for (int i = 0; i < 100; i++ )
    {
        [special_itemsarr addObject:[NSNumber numberWithInt:0]];
    }
    
    [self.udata setObject:special_itemsarr forKey:@"items_special"];
    [self.udata synchronize];
}

- (void) create_detective_settings
{
    NSMutableArray *tmp_worlds = [NSMutableArray arrayWithCapacity:100];
    NSMutableArray *tmp_worlds_souls = [NSMutableArray arrayWithCapacity:100];
    for (int w = 1; w <= 1; w++)
    {
        NSMutableArray *w = [NSMutableArray arrayWithCapacity:100];
        for (int lvl = 1; lvl <= 12; lvl++)
        {
            [w addObject:[NSNumber numberWithInt:0]];
        }
        [tmp_worlds addObject:w];
        [tmp_worlds_souls addObject:w];
    }
    NSArray *worlds = tmp_worlds;
    NSArray *world_souls = tmp_worlds_souls;
    
    [self.udata setObject:worlds forKey:@"detective_highscores"];
    [self.udata setObject:world_souls forKey:@"detective_souls"];
    
    [self.udata synchronize];
}

- (void) create_detective_settings2
{
    [self.udata setBool:FALSE forKey:@"unlocked_detective"];
    [self.udata synchronize];
}

- (void) reset
{
    [self.udata setBool:FALSE forKey:@"created"];
    [self resetAchievements];    
    [self create];
    [self.udata synchronize];
}

- (void) sync
{
    [self.udata setInteger:self.levelprogress forKey:@"levelprogress"];
    [self.udata setInteger:self.worldprogress forKey:@"worldprogress"];
    [self.udata setInteger:self.deaths forKey:@"deaths"];
    [self.udata setInteger:self.jumps forKey:@"jumps"];
    [self.udata setInteger:self.collected forKey:@"collected"];    
    [self.udata setInteger:self.powerup forKey:@"powerup"];
    [self.udata setInteger:self.bought_powerups forKey:@"bought_powerups"];
    [self.udata synchronize];
}

- (void) sync_facebook
{
    [self.udata setObject:self.facebook_id forKey:@"facebook_id"];
    [self.udata setObject:self.facebook_image forKey:@"facebook_image"];
    [self.udata synchronize];
}
- (void) sync_cache_current_world
{
    [self.udata setInteger:self.cache_current_world forKey:@"cache_current_world"];
    [self.udata synchronize];
}

- (BOOL) isOnline
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];  
    NetworkStatus networkStatus = [reachability currentReachabilityStatus]; 
    return !(networkStatus == NotReachable);
}

- (void) buyItem:(int)item
{
    NSMutableArray *items_tmp = [[self.udata objectForKey:@"items"] mutableCopy];
    [items_tmp replaceObjectAtIndex:item withObject:[NSNumber numberWithInt:1]];
    
    [self.udata setObject:items_tmp forKey:@"items"];
    [self.udata synchronize];
    
    self.items = [self.udata objectForKey:@"items"];    
}

- (void) buySpecialItem:(int)item
{
    NSMutableArray *items_tmp = [[self.udata objectForKey:@"items_special"] mutableCopy];
    [items_tmp replaceObjectAtIndex:item withObject:[NSNumber numberWithInt:1]];
    
    [self.udata setObject:items_tmp forKey:@"items_special"];
    [self.udata synchronize];
    
    self.items_special = [self.udata objectForKey:@"items_special"];
}

- (void) setGameProgressforWorld:(int)w level:(int)l
{
    NSMutableArray *gameprogress_tmp = [self.gameprogress mutableCopy];
    NSMutableArray *tmp = [[gameprogress_tmp objectAtIndex:w-1] mutableCopy];
    [tmp replaceObjectAtIndex:l-1 withObject:[NSNumber numberWithInt:1]];
    [gameprogress_tmp replaceObjectAtIndex:w-1 withObject:tmp];
    NSArray *new_gameprogress = gameprogress_tmp;
    [self.udata setObject:new_gameprogress forKey:@"gameprogress"];
    [self.udata synchronize];
}

- (void) setHighscore:(int)score world:(int)w level:(int)l
{
    if ( w == 20 )
    {
        NSMutableArray *highscores_tmp = [self.highscores mutableCopy];
        int current_highscore = [self getHighscoreforWorld:w level:l];
        if (score > current_highscore)
        {
            NSMutableArray *tmp = [[highscores_tmp objectAtIndex:0] mutableCopy];
            [tmp replaceObjectAtIndex:l-1 withObject:[NSNumber numberWithInt:score]];
            [highscores_tmp replaceObjectAtIndex:0 withObject:tmp];
            NSArray *highscore = highscores_tmp;
            [self.udata setObject:highscore forKey:@"detective_highscores"];
            [self.udata synchronize];
        }        
    }
    else
    {
        NSMutableArray *highscores_tmp = [self.highscores mutableCopy];
        int current_highscore = [self getHighscoreforWorld:w level:l];
        if (score > current_highscore)
        {
            NSMutableArray *tmp = [[highscores_tmp objectAtIndex:w-1] mutableCopy];
            [tmp replaceObjectAtIndex:l-1 withObject:[NSNumber numberWithInt:score]];
            [highscores_tmp replaceObjectAtIndex:w-1 withObject:tmp];
            NSArray *highscore = highscores_tmp;
            [self.udata setObject:highscore forKey:@"highscores"];
            [self.udata synchronize];
        }        
    }
}

- (void) setSouls:(int)tmp_souls world:(int)w level:(int)l
{
    if ( w == 20 )
    {
        NSMutableArray *souls_tmp = [[self.udata objectForKey:@"detective_souls"] mutableCopy];
        
        int current_total = [self getSoulsforWorld:w level:l];
        
        if (tmp_souls > current_total)
        {
            NSMutableArray *tmp = [[souls_tmp objectAtIndex:0] mutableCopy];
            [tmp replaceObjectAtIndex:l-1 withObject:[NSNumber numberWithInt:tmp_souls]];
            [souls_tmp replaceObjectAtIndex:0 withObject:tmp];
            NSArray *souls_arr = souls_tmp;
            [self.udata setObject:souls_arr forKey:@"detective_souls"];
            [self.udata synchronize];
        }
    }
    else
    {
        NSMutableArray *souls_tmp = [[self.udata objectForKey:@"souls"] mutableCopy];
        
        int current_total = [self getSoulsforWorld:w level:l];
        
        if (tmp_souls > current_total)
        {
            NSMutableArray *tmp = [[souls_tmp objectAtIndex:w-1] mutableCopy];
            [tmp replaceObjectAtIndex:l-1 withObject:[NSNumber numberWithInt:tmp_souls]];
            [souls_tmp replaceObjectAtIndex:w-1 withObject:tmp];
            NSArray *souls_arr = souls_tmp;
            [self.udata setObject:souls_arr forKey:@"souls"];
            [self.udata synchronize];
        }
    }
}

- (int) getHighscoreforWorld:(int)w
{
    if ( w == 20 )
    {
        NSMutableArray *tmp = [self.udata objectForKey:@"detective_highscores"];
        NSMutableArray *tmp2= [tmp objectAtIndex:0];
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
    else
    {
        NSMutableArray *tmp = [self.udata objectForKey:@"highscores"];
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
}

- (int) getHighscoreforWorld:(int)w level:(int)l
{
    if ( w == 20 )
    {
        NSMutableArray *tmp = [self.udata objectForKey:@"detective_highscores"];
        NSMutableArray *tmp2= [tmp objectAtIndex:0];
        int tmp_score = 0;
        
        if ( [tmp2 count] > 0 )
        {
            tmp_score = (int)[[tmp2 objectAtIndex:l-1] intValue];
        }
        
        return tmp_score;        
    }
    else
    {
        NSMutableArray *tmp = [self.udata objectForKey:@"highscores"];
        NSMutableArray *tmp2= [tmp objectAtIndex:w-1];
        int tmp_score = 0;
        
        if ( [tmp2 count] > 0 )
        {
            tmp_score = (int)[[tmp2 objectAtIndex:l-1] intValue];
        }
        
        return tmp_score;        
    }
}

- (int) getGameProgressforWorld:(int)w level:(int)l
{
    NSMutableArray *tmp = [self.udata objectForKey:@"gameprogress"];
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
    if ( w == 20 )
    {
        NSMutableArray *tmp = [self.udata objectForKey:@"detective_souls"];
        NSMutableArray *tmp2= [tmp objectAtIndex:0];
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
    else
    {
        NSMutableArray *tmp = [self.udata objectForKey:@"souls"];
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
    if ( w == 20 )
    {
        NSMutableArray *tmp = [self.udata objectForKey:@"detective_souls"];
        NSMutableArray *tmp2= [tmp objectAtIndex:0];
        int tmp_score = 0;
        
        if ( [tmp2 count] > 0 )
        {
            tmp_score = (int)[[tmp2 objectAtIndex:l-1] intValue];
        }
        
        return tmp_score;
        
    }
    else
    {
        NSMutableArray *tmp = [self.udata objectForKey:@"souls"];
        NSMutableArray *tmp2= [tmp objectAtIndex:w-1];
        int tmp_score = 0;
        
        if ( [tmp2 count] > 0 )
        {
            tmp_score = (int)[[tmp2 objectAtIndex:l-1] intValue];
        }
        
        return tmp_score;        
    }
}

- (NSString*) getEquippedPowerup
{
    if ( self.powerup >= 100 )
    {
        NSArray *contentArray = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Powerups_special" ofType:@"plist"] ] objectForKey:@"Powerups"];
        NSDictionary *powerup_dict = [contentArray objectAtIndex:(self.powerup)-100];
        return [powerup_dict objectForKey:@"Name"];
    }
    else
    {
        NSArray *contentArray = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Powerups" ofType:@"plist"] ] objectForKey:@"Powerups"];
        NSDictionary *powerup_dict = [contentArray objectAtIndex:self.powerup];
        return [powerup_dict objectForKey:@"Name"];
    }
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
    if ( self.worldprogress >= 2 && self.levelprogress >= LEVELS_PER_WORLD && !self.ach_beat_world_2 ) // beat world two
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
    [self.udata setBool:self.ach_beat_world_1 forKey:@"ach_beat_world_1"];
    [self.udata setBool:self.ach_beat_world_2 forKey:@"ach_beat_world_2"];
    [self.udata setBool:self.ach_beat_world_3 forKey:@"ach_beat_world_3"];
    [self.udata setBool:self.ach_beat_world_4 forKey:@"ach_beat_world_4"];
    [self.udata setBool:self.ach_first_play forKey:@"ach_first_play"];
    [self.udata setBool:self.ach_first_3_big forKey:@"ach_first_3_big"];
    [self.udata setBool:self.ach_killed forKey:@"ach_killed"];
    [self.udata setBool:self.ach_1000_souls forKey:@"ach_1000_souls"];
    [self.udata setBool:self.ach_5000_souls forKey:@"ach_5000_souls"];
    [self.udata setBool:self.ach_10000_souls forKey:@"ach_10000_souls"];
    [self.udata setBool:self.ach_50000_souls forKey:@"ach_50000_souls"];
    [self.udata setBool:self.ach_died_100 forKey:@"ach_died_100"];
    [self.udata setBool:self.ach_jumped_1000 forKey:@"ach_jumped_1000"];
    [self.udata setBool:self.ach_collected_666 forKey:@"ach_collected_666"];
    
    [self.udata setBool:self.sent_ach_beat_world_1 forKey:@"sent_ach_beat_world_1"];
    [self.udata setBool:self.sent_ach_beat_world_2 forKey:@"sent_ach_beat_world_2"];
    [self.udata setBool:self.sent_ach_beat_world_3 forKey:@"sent_ach_beat_world_3"];
    [self.udata setBool:self.sent_ach_beat_world_4 forKey:@"sent_ach_beat_world_4"];
    [self.udata setBool:self.sent_ach_first_play forKey:@"sent_ach_first_play"];
    [self.udata setBool:self.sent_ach_first_3_big forKey:@"sent_ach_first_3_big"];
    [self.udata setBool:self.sent_ach_killed forKey:@"sent_ach_killed"];
    [self.udata setBool:self.sent_ach_1000_souls forKey:@"sent_ach_1000_souls"];
    [self.udata setBool:self.sent_ach_5000_souls forKey:@"sent_ach_5000_souls"];
    [self.udata setBool:self.sent_ach_10000_souls forKey:@"sent_ach_10000_souls"];
    [self.udata setBool:self.sent_ach_50000_souls forKey:@"sent_ach_50000_souls"];
    [self.udata setBool:self.sent_ach_died_100 forKey:@"sent_ach_died_100"];
    [self.udata setBool:self.sent_ach_jumped_1000 forKey:@"sent_ach_jumped_1000"];
    [self.udata setBool:self.sent_ach_collected_666 forKey:@"sent_ach_collected_666"];
    
    [self.udata synchronize];
}

- (void) setupAchievements
{
    self.ach_beat_world_1       = [self.udata boolForKey:@"ach_beat_world_1"];
    self.ach_beat_world_2       = [self.udata boolForKey:@"ach_beat_world_2"];
    self.ach_beat_world_3       = [self.udata boolForKey:@"ach_beat_world_3"];
    self.ach_beat_world_4       = [self.udata boolForKey:@"ach_beat_world_4"];
    self.ach_first_play         = [self.udata boolForKey:@"ach_first_play"];
    self.ach_first_3_big        = [self.udata boolForKey:@"ach_first_3_big"];
    self.ach_killed             = [self.udata boolForKey:@"ach_killed"];
    self.ach_1000_souls         = [self.udata boolForKey:@"ach_1000_souls"];
    self.ach_5000_souls         = [self.udata boolForKey:@"ach_5000_souls"];
    self.ach_10000_souls        = [self.udata boolForKey:@"ach_10000_souls"];
    self.ach_50000_souls        = [self.udata boolForKey:@"ach_50000_souls"];
    self.ach_died_100           = [self.udata boolForKey:@"ach_died_100"];
    self.ach_jumped_1000        = [self.udata boolForKey:@"ach_jumped_1000"];
    self.ach_collected_666      = [self.udata boolForKey:@"ach_collected_666"];
    
    self.sent_ach_beat_world_1  = [self.udata boolForKey:@"sent_ach_beat_world_1"];
    self.sent_ach_beat_world_2  = [self.udata boolForKey:@"sent_ach_beat_world_2"];
    self.sent_ach_beat_world_3  = [self.udata boolForKey:@"sent_ach_beat_world_3"];
    self.sent_ach_beat_world_4  = [self.udata boolForKey:@"sent_ach_beat_world_4"];
    self.sent_ach_first_play    = [self.udata boolForKey:@"sent_ach_first_play"];
    self.sent_ach_first_3_big   = [self.udata boolForKey:@"sent_ach_first_3_big"];
    self.sent_ach_killed        = [self.udata boolForKey:@"sent_ach_killed"];
    self.sent_ach_1000_souls    = [self.udata boolForKey:@"sent_ach_1000_souls"];
    self.sent_ach_5000_souls    = [self.udata boolForKey:@"sent_ach_5000_souls"];
    self.sent_ach_10000_souls   = [self.udata boolForKey:@"sent_ach_10000_souls"];
    self.sent_ach_50000_souls   = [self.udata boolForKey:@"sent_ach_50000_souls"];
    self.sent_ach_died_100      = [self.udata boolForKey:@"sent_ach_died_100"];
    self.sent_ach_jumped_1000   = [self.udata boolForKey:@"sent_ach_jumped_1000"];
    self.sent_ach_collected_666 = [self.udata boolForKey:@"sent_ach_collected_666"];
}

- (void) resetAchievements
{
    [self.udata setBool:FALSE forKey:@"ach_beat_world_1"];
    [self.udata setBool:FALSE forKey:@"ach_beat_world_2"];
    [self.udata setBool:FALSE forKey:@"ach_beat_world_3"];
    [self.udata setBool:FALSE forKey:@"ach_beat_world_4"];
    [self.udata setBool:FALSE forKey:@"ach_first_play"];
    [self.udata setBool:FALSE forKey:@"ach_first_3_big"];
    [self.udata setBool:FALSE forKey:@"ach_killed"];
    [self.udata setBool:FALSE forKey:@"ach_1000_souls"];
    [self.udata setBool:FALSE forKey:@"ach_5000_souls"];
    [self.udata setBool:FALSE forKey:@"ach_10000_souls"];
    [self.udata setBool:FALSE forKey:@"ach_50000_souls"];
    [self.udata setBool:FALSE forKey:@"ach_died_100"];
    [self.udata setBool:FALSE forKey:@"ach_jumped_1000"];
    [self.udata setBool:FALSE forKey:@"ach_collected_666"];
    
    [self.udata setBool:FALSE forKey:@"sent_ach_beat_world_1"];
    [self.udata setBool:FALSE forKey:@"sent_ach_beat_world_2"];
    [self.udata setBool:FALSE forKey:@"sent_ach_beat_world_3"];
    [self.udata setBool:FALSE forKey:@"sent_ach_beat_world_4"];
    [self.udata setBool:FALSE forKey:@"sent_ach_first_play"];
    [self.udata setBool:FALSE forKey:@"sent_ach_first_3_big"];
    [self.udata setBool:FALSE forKey:@"sent_ach_killed"];
    [self.udata setBool:FALSE forKey:@"sent_ach_1000_souls"];
    [self.udata setBool:FALSE forKey:@"sent_ach_5000_souls"];
    [self.udata setBool:FALSE forKey:@"sent_ach_10000_souls"];
    [self.udata setBool:FALSE forKey:@"sent_ach_50000_souls"];
    [self.udata setBool:FALSE forKey:@"sent_ach_died_100"];
    [self.udata setBool:FALSE forKey:@"sent_ach_jumped_1000"];
    [self.udata setBool:FALSE forKey:@"sent_ach_collected_666"];
}


@end
