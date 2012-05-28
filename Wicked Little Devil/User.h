//
//  User.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject {}

@property (nonatomic, retain) NSUserDefaults *data;
@property (nonatomic, assign) int highscore, collected, levelprogress;

@end