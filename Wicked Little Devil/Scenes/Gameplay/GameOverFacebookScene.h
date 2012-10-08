//
//  GameOverFacebookScene.h
//  Wicked Little Devil
//
//  Created by Andy on 05/10/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "cocos2d.h"
#import <Parse/Parse.h>

@class Game, GameOverScene, AppController;
@interface GameOverFacebookScene : CCLayer <PF_FBRequestDelegate, NSURLConnectionDelegate,UITableViewDelegate, UITableViewDataSource>
{
    AppController *app;
    UIView *view;
    UITableView *table;
    NSArray *fbdata, *fbdata2, *fbdata3;
    NSString *fb_score1, *fb_score2, *fb_score3;
    NSString *fb_name1, *fb_name2, *fb_name3;
    
    NSMutableData *imageData, *imageData2, *imageData3;
    NSURLConnection *urlConnection,*urlConnection2,*urlConnection3;
}
@property (nonatomic, assign) int request_tag;

+(CCScene *) sceneWithGame:(Game*)game;
- (id) initWithGame:(Game*)game;

@end
