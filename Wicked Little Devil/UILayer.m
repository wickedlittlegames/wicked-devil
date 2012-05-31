//
//  MyCocos2DClass.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 24/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "UILayer.h"


@implementation UILayer
@synthesize label;

- (id) init {
    self = [super init];
    if (self != nil) {
        //label = [CCLabelTTF labelWithString:@"Menu" fontName:@"Arial" fontSize:32];
		//label.color = ccc3(255,255,255);
		//label.position = ccp(200, 300);
		//[self addChild:label];
    }
    return self;
}

- (id) initWithAds {
    self = [super init];
    if (self != nil) {
        
    }
    return self;
}

@end