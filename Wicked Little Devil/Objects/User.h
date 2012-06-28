//
//  User.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//
#import <SystemConfiguration/SystemConfiguration.h>
#import <Parse/Parse.h>
#import "Reachability.h"
#import "GameKitHelper.h"
#import "GameCenterConstants.h"

@interface User : NSObject <GameKitHelperProtocol, PF_FBRequestDelegate> {}

@property (nonatomic, retain) NSUserDefaults *udata;
@property (nonatomic, retain) GameKitHelper *gameKitHelper;
@property (nonatomic, assign) int collected, levelprogress, worldprogress, powerup, cache_current_world;
@property (nonatomic, assign) NSMutableArray *highscores, *souls;
@property (nonatomic, assign) bool worlds_unlocked;

- (void) create;
- (void) sync; // combine syncdata and synchcollected
- (void) sync_cache_current_world;
- (void) reset; // resetUser
- (BOOL) parse_create:(id)result;
- (BOOL) parse_login; // login with parse
- (void) parse_logout;  // logout of parse
- (void) parse_refresh; // refresh parse

- (BOOL) isOnline; // is connected to internet
- (BOOL) isConnectedToFacebook; // can collect
- (BOOL) isAvailableForOnlinePlay;

- (void) setHighscore:(int)score world:(int)w level:(int)l;
- (void) setSouls:(int)souls world:(int)w level:(int)l;

- (int) getHighscoreforWorld:(int)w;
- (int) getHighscoreforWorld:(int)w level:(int)l;
- (int) getSoulsforWorld:(int)w;
- (int) getSoulsforWorld:(int)w level:(int)l;

@end