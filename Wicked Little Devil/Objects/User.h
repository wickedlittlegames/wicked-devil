//
//  User.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//

#import "GameKitHelper.h"
#import <Foundation/Foundation.h>

@interface User : NSObject <GameKitHelperProtocol> {}

@property (nonatomic, retain) NSUserDefaults *udata;
@property (nonatomic, retain) GameKitHelper *gameKitHelper;
@property (nonatomic, assign) int highscore, collected, levelprogress, worldprogress;

@end