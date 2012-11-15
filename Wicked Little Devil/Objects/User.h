//
//  User.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"
#import "GameConstants.h"

@interface User : NSObject {}

@property (nonatomic, retain) NSUserDefaults *udata;
@property (nonatomic, assign) int collected, levelprogress, worldprogress, powerup, cache_current_world, deaths, jumps;
@property (nonatomic, retain) NSMutableArray *highscores, *souls, *powerups, *items, *gameprogress, *items_special;
@property (nonatomic, assign) BOOL ach_first_play, ach_beat_world_1, ach_beat_world_2, ach_beat_world_3, ach_beat_world_4, bought_powerups;
@property (nonatomic, assign) BOOL ach_killed, ach_1000_souls, ach_5000_souls, ach_10000_souls, ach_50000_souls;
@property (nonatomic, assign) BOOL ach_died_100, ach_jumped_1000, ach_first_3_big, ach_collected_666;
@property (nonatomic, assign) BOOL sent_ach_first_play, sent_ach_beat_world_1, sent_ach_beat_world_2, sent_ach_beat_world_3, sent_ach_beat_world_4;
@property (nonatomic, assign) BOOL sent_ach_killed, sent_ach_1000_souls, sent_ach_5000_souls, sent_ach_10000_souls, sent_ach_50000_souls;
@property (nonatomic, assign) BOOL sent_ach_died_100, sent_ach_jumped_1000, sent_ach_first_3_big, sent_ach_collected_666;
@property (nonatomic, retain) NSMutableData *facebook_image;
@property (nonatomic, retain) NSString *facebook_id;

- (void) create;
- (void) sync; // combine syncdata and synchcollected
- (void) sync_cache_current_world;
- (void) sync_facebook;
- (void) reset; // resetUser

- (void) check_achiements;
- (void) sync_achievements;

- (BOOL) isOnline; // is connected to internet

- (void) buyItem:(int)item;
- (void) setHighscore:(int)score world:(int)w level:(int)l;
- (void) setSouls:(int)souls world:(int)w level:(int)l;
- (void) setGameProgressforWorld:(int)w level:(int)l;

- (NSString*) getEquippedPowerup;
- (int) getHighscoreforWorld:(int)w;
- (int) getHighscoreforWorld:(int)w level:(int)l;
- (int) getSoulsforWorld:(int)w;
- (int) getSoulsforWorld:(int)w level:(int)l;
- (int) getSoulsforAll;
- (int) getGameProgressforWorld:(int)w level:(int)l;

@end