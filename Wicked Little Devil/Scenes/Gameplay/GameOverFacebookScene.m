//
//  GameOverFacebookScene.m
//  Wicked Little Devil
//
//  Created by Andy on 05/10/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "GameOverFacebookScene.h"
#import "GameOverScene.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "Game.h"

@implementation GameOverFacebookScene
@synthesize request_tag;

+ (CCScene*) sceneWithGame:(Game *)game
{
    CCScene *scene = [CCScene node];
    GameOverFacebookScene *current = [[GameOverFacebookScene alloc] initWithGame:game];
    [scene addChild:current];
	return scene;
}

- (id) initWithGame:(Game*)game
{
    if( (self=[super init]) )
    {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        app = (AppController*) [[UIApplication sharedApplication] delegate];
        
        fbdata    = [NSMutableArray arrayWithObjects:nil];
        fbdata2    = [NSMutableArray arrayWithObjects:nil];
        fbdata3  = [NSMutableArray arrayWithObjects:nil];
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (screenBounds.size.height == 568) {
            CCSprite *bg = [CCSprite spriteWithFile:@"bg-facebook-compare-iphone5.png"];
            [bg setPosition:ccp(screenSize.width/2, screenSize.height/2)];
            [self addChild:bg];
            
        } else {
            CCSprite *bg = [CCSprite spriteWithFile:@"bg-facebook-compare.png"];
            [bg setPosition:ccp(screenSize.width/2, screenSize.height/2)];
            [self addChild:bg];
        }

        CCMenu *menu_back  = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-back.png"    selectedImage:@"btn-back.png" block:^(id sender) {[view removeFromSuperview];[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameOverScene  sceneWithGame:game]]];}  ],nil];
        [menu_back setPosition:ccp(25, 25)];
        [self addChild:menu_back];
        
        int gamescore = 0;
        self.request_tag = 0;
        imageData = [[NSMutableData alloc] init];
        imageData2 = [[NSMutableData alloc] init];
        imageData3 = [[NSMutableData alloc] init];

        [MBProgressHUD showHUDAddedTo:[app navController].view animated:YES];
        for (int i = 1; i <= CURRENT_WORLDS_PER_GAME; i++) {  gamescore += [game.user getHighscoreforWorld:i]; }
        
        if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
        {
            NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [NSString stringWithFormat:@"%i",gamescore], @"score",
                                          [[PFFacebookUtils session] accessToken],@"access_token",
                                          nil];
            PF_FBRequest *req = [[PF_FBRequest alloc] initWithSession:[PFFacebookUtils session] graphPath:@"me/scores" parameters:param HTTPMethod:@"POST"];
            [req startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
                if ( error != nil ) 
                {
                    [MBProgressHUD hideHUDForView:[app navController].view animated:YES];
                    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameOverScene  sceneWithGame:game]]];
                }
                else
                {
                    NSMutableDictionary *param2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[PFFacebookUtils session] accessToken],@"access_token",nil];
                    [[PFFacebookUtils facebook] requestWithGraphPath:[NSString stringWithFormat:@"%@/scores",[[PFFacebookUtils session] appID]] andParams:param2 andHttpMethod:@"GET" andDelegate:self];
                }
            }];
        }
    }
    return self;
}

- (void) request:(PF_FBRequest *)request didLoad:(id)result
{
    NSArray *friendScores = (NSArray *)[result objectForKey:@"data"];
    int top3_counter = 1;
    for(int i = 0; i < friendScores.count; i++)
    {
        [fbdata addObject:[[[friendScores objectAtIndex:i] objectForKey:@"user"] objectForKey:@"name"]];
        [fbdata2 addObject:[[friendScores objectAtIndex:i] objectForKey:@"score"]];
        [fbdata3 addObject:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1",[[[friendScores objectAtIndex:i] objectForKey:@"user"] objectForKey:@"id"]]];
        
        if ( top3_counter <= 3)
        {
            NSString *fb_id    = [[[friendScores objectAtIndex:i] objectForKey:@"user"] objectForKey:@"id"];
            NSString *fb_name  = [[[friendScores objectAtIndex:i] objectForKey:@"user"] objectForKey:@"name"];
            NSString *fb_score = [[friendScores objectAtIndex:i] objectForKey:@"score"];
            NSString *fb_url   = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1",fb_id];
            self.request_tag   = top3_counter;
            
            NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:fb_url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
            if ( top3_counter == 1 )
            {
                fb_name1 = fb_name;
                fb_score1 = fb_score;
                urlConnection = [NSURLConnection connectionWithRequest:req delegate:self];
            }
            if ( top3_counter == 2 )
            {
                fb_name2 = fb_name;
                fb_score2 = fb_score;
                urlConnection2 = [NSURLConnection connectionWithRequest:req delegate:self];
            }
            if ( top3_counter == 3 )
            {
                fb_name3 = fb_name;
                fb_score3 = fb_score;
                urlConnection3 = [NSURLConnection connectionWithRequest:req delegate:self];
            }
        }
        top3_counter++;
    }

    [MBProgressHUD hideHUDForView:[app navController].view animated:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(connection == urlConnection){
        [imageData appendData:data];
    }
    else if(connection == urlConnection2){
        [imageData2 appendData:data];
    }
    else if(connection == urlConnection3){
        [imageData3 appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ( connection == urlConnection )
    {
        [self createFacebookSprites:fb_name1 andScore:fb_score1 atPosition:ccp(60,[[CCDirector sharedDirector] winSize].height - 260)];
        
        
        CCSprite *fbimage = [CCSprite spriteWithCGImage:[UIImage imageWithData:imageData].CGImage key:@"facebook_image1"];
        [fbimage setPosition:ccp(60,[[CCDirector sharedDirector] winSize].height - 119)];
        [self resizeSprite:fbimage toWidth:180/2 toHeight:159/2];
        [self addChild:fbimage];
        
    }
    if ( connection == urlConnection2 )
    {
        [self createFacebookSprites:fb_name2 andScore:fb_score2 atPosition:ccp(161,[[CCDirector sharedDirector] winSize].height - 260)];
        
        CCSprite *fbimage = [CCSprite spriteWithCGImage:[UIImage imageWithData:imageData2].CGImage key:@"facebook_image2"];
        [fbimage setPosition:ccp(161,[[CCDirector sharedDirector] winSize].height - 119)];
        [self resizeSprite:fbimage toWidth:180/2 toHeight:159/2];
        [self addChild:fbimage];        
    }
    if ( connection == urlConnection3 )
    {
        [self createFacebookSprites:fb_name3 andScore:fb_score3 atPosition:ccp(261,[[CCDirector sharedDirector] winSize].height - 260)];
        
        
        CCSprite *fbimage = [CCSprite spriteWithCGImage:[UIImage imageWithData:imageData3].CGImage key:@"facebook_image3"];
        [fbimage setPosition:ccp(261,[[CCDirector sharedDirector] winSize].height - 119)];
        [self resizeSprite:fbimage toWidth:180/2 toHeight:159/2];
        [self addChild:fbimage];
        
        
        view    = [[UIView alloc] initWithFrame:CGRectMake(0, 315, [[CCDirector sharedDirector] winSize].width, 100)];
        table   = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[CCDirector sharedDirector] winSize].width, 100)];
        table.dataSource = self;
        table.delegate   = self;
        [view addSubview:table];
        [app.window addSubview:view];
    }
}

- (void) createFacebookSprites:(NSString*)facebook_name andScore:(NSString*)facebook_score atPosition:(CGPoint)facebook_position
{
    CCLabelTTF *lbl_score = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@",facebook_score] dimensions:CGSizeMake(90,50) hAlignment:kCCTextAlignmentCenter fontName:@"CrashLanding BB" fontSize:36];
    lbl_score.color = ccc3(205, 51, 51);
    lbl_score.position = facebook_position;
    
    CCLabelTTF *lbl_name  = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@",facebook_name] dimensions:CGSizeMake(90,50) hAlignment:kCCTextAlignmentCenter fontName:@"CrashLanding BB" fontSize:24];
    lbl_name.color = ccBLACK;
    lbl_name.position = ccp(facebook_position.x, facebook_position.y - 27);
    
    [self addChild:lbl_score];
    [self addChild:lbl_name];
}

-(void)resizeSprite:(CCSprite*)sprite toWidth:(float)width toHeight:(float)height {
    sprite.scaleX = width / sprite.contentSize.width;
    sprite.scaleY = height / sprite.contentSize.height;
}



- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [fbdata count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.delegate=self;
    tableView.dataSource=self;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor blackColor];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.userInteractionEnabled = YES;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ HIGHSCORE:",[fbdata objectAtIndex:indexPath.row]];
    cell.textLabel.font = [UIFont fontWithName:@"CrashLanding BB" size:24.0f];
    cell.textLabel.textColor = [UIColor magentaColor];

    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[fbdata2 objectAtIndex:indexPath.row]];
    cell.detailTextLabel.font = [UIFont fontWithName:@"CrashLanding BB" size:30.0f];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    [cell.textLabel sizeToFit];
    
    return cell;
}




@end
