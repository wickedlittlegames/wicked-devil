//
//  User.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize data, highscore, collected, levelprogress;

-(id) init
{
	if( (self=[super init]) ) 
    {
        /* 
            NSUserDefaults:
                - created
                - highscore
                - collected
                - item1
                - item2
                - levelprogress
        */
        data = [NSUserDefaults standardUserDefaults];
        if ( [data boolForKey:@"created"] == FALSE )
        {
            [self createUser];
        }
        
        self.highscore = [data integerForKey:@"highscore"];
        self.collected = [data integerForKey:@"collected"];
        self.levelprogress = [data integerForKey:@"levelprogress"];
    }
    return self;
}

- (void) createUser
{
    [data setBool:TRUE forKey:@"created"];
    [data setInteger:0 forKey:@"highscore"];
    [data setInteger:0 forKey:@"collected"];
    [data setInteger:1 forKey:@"levelprogress"];
}

- (void) resetUser
{
    [data setBool:FALSE forKey:@"created"];
    [data setInteger:0 forKey:@"highscore"];
    [data setInteger:0 forKey:@"collected"];
    [data setInteger:1 forKey:@"levelprogress"];
}

@end
