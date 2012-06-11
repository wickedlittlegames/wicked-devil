//
//  Platform.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 28/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import "GameObject.h"
#import "Player.h"

@interface Platform : GameObject {}
@property (nonatomic, assign) float health;
@property (nonatomic, assign) NSString *type;

- (BOOL) isIntersectingPlayer:(Player*)player;

@end


