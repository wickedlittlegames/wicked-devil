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

@interface User : NSObject <GameKitHelperProtocol, PF_FBRequestDelegate, UINavigationControllerDelegate > {
    bool login_success;
}

@property (nonatomic, retain) NSUserDefaults *udata;
@property (nonatomic, retain) GameKitHelper *gameKitHelper;
@property (nonatomic, assign) int collected, levelprogress, worldprogress, powerup;
@property (nonatomic, assign) NSMutableArray *highscores, *souls;
@property (nonatomic, retain) NSString *fbid;
@property (nonatomic, assign) bool fbloggedin;
- (void) syncData;
- (void) syncCollected;
- (void) resetUser;
- (void) updateHighscoreforWorld:(int)w andLevel:(int)lvl withScore:(int)score;
- (void) updateSoulForWorld:(int)w andLevel:(int)lvl withTotal:(int)total;
- (int) getScoreForWorld:(int)w andLevel:(int)lvl;
- (int) getSoulsForWorld:(int)w andLevel:(int)lvl;
- (int) getScoreForWorldOnly:(int)w;
- (BOOL) isConnectedToInternet;
- (BOOL) loginWithFacebook;
- (BOOL) canCollect;
@end