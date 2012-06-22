//
//  User.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//

#import "GameKitHelper.h"
#import "GameCenterConstants.h"

@interface User : NSObject <GameKitHelperProtocol> {}

@property (nonatomic, retain) NSUserDefaults *udata;
@property (nonatomic, retain) GameKitHelper *gameKitHelper;
@property (nonatomic, assign) int collected, levelprogress, worldprogress, powerup;
@property (nonatomic, assign) NSMutableArray *highscores, *souls;
- (void) syncData;
- (void) updateHighscoreforWorld:(int)w andLevel:(int)lvl withScore:(int)score;
- (void) updateSoulForWorld:(int)w andLevel:(int)lvl withTotal:(int)total;
- (int) getScoreForWorld:(int)w andLevel:(int)lvl;
- (int) getSoulsForWorld:(int)w andLevel:(int)lvl;
- (int) getScoreForWorldOnly:(int)w;
- (void) resetUser;
@end