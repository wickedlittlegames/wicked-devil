//
//  CCNode+CoordHelpers.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 13/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "CCNode+CoordHelpers.h"


@implementation CCNode (CoordHelpers)
-(CGRect)worldBoundingBox {
    CGRect rect = CGRectMake(0, 0, contentSize_.width, contentSize_.height);
    return CGRectApplyAffineTransform(rect, [self nodeToWorldTransform]);
}
@end