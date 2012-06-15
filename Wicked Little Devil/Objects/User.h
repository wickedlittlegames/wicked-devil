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
@property (nonatomic, assign) int collected, levelprogress, worldprogress;
@property (nonatomic, assign) NSMutableArray *level_bigcollecteds, *highscores;

- (void) syncData;
- (void) updateHighscoreforWorld:(int)w andLevel:(int)lvl withScore:(int)score;

@end