//
//  GameObject.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 11/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "GameObject.h"


@implementation GameObject

- (void) movementWithThreshold:(float)levelThreshold 
{
    if (levelThreshold < 0)
    {
        self.position = ccp(self.position.x, self.position.y + levelThreshold);
    }
}


@end
