//
//  StatsScene.m
//  Wicked Little Devil
//
//  Created by Andy on 14/05/2013.
//  Copyright (c) 2013 Wicked Little Websites. All rights reserved.
//

#import "StatsScene.h"
#import "WorldSelectScene.h"
#import "AppDelegate.h"
#import "FacebookTableCell.h"

@implementation StatsScene

+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
    StatsScene *current = [StatsScene node];
    [scene addChild:current];
    return scene;
}

-(id) init
{
    if( (self=[super init]) )
    {
        user = [[User alloc] init];
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        app = (AppController*) [[UIApplication sharedApplication] delegate];
        view    = [[UIView alloc] initWithFrame:CGRectMake(0, 115, [[CCDirector sharedDirector] winSize].width-30, [[CCDirector sharedDirector] winSize].height - 225)];
        table   = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[CCDirector sharedDirector] winSize].width-30, [[CCDirector sharedDirector] winSize].height - 225)];
        table.dataSource = self;
        table.delegate   = self;
        [view addSubview:table];
        [app.window addSubview:view];
        
        int totalhighscore = 0;
        for (int i = 1; i <= CURRENT_WORLDS_PER_GAME; i++)
        {
            int tmp_highscore_for_world = [user getHighscoreforWorld:i];
            totalhighscore += tmp_highscore_for_world;
        }
                
        tableTitles = [NSArray arrayWithObjects:
                       @"Total Score: ",
                       @"Big Souls Collected: ",
                       @"Small Souls Collected: ",
                       @"World Progress: ",
                       @"Level Progress: ",                      
                       @"Jumps: ",
                       @"Deaths: ",
                       @"Detective Devil Unlocked: ",
                       @"Powerup Bought: ",
                       @"Facebook Active: ", nil];
        tableData   = [NSArray arrayWithObjects:
                       [NSString stringWithFormat:@"%i",totalhighscore],
                       [NSString stringWithFormat:@"%i",[user getSoulsforAll]],
                       [NSString stringWithFormat:@"%i",user.collected],
                       [NSString stringWithFormat:@"%i",user.worldprogress],
                       [NSString stringWithFormat:@"%i",user.levelprogress],
                       [NSString stringWithFormat:@"%i",user.jumps],
                       [NSString stringWithFormat:@"%i",user.deaths],
                       [NSString stringWithFormat:@"%@",(user.unlocked_detective ? @"YES" : @"NO")],
                       [NSString stringWithFormat:@"%@",(user.bought_powerups ? @"YES" : @"NO")],
                       [NSString stringWithFormat:@"%@",(user.facebook_id ? @"YES" : @"NO")],
                       nil];

     
        CCSprite *bg                    = [CCSprite spriteWithFile:@"bg-stats.png"];
        CCMenu *menu_back               = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-back.png"    selectedImage:@"btn-back.png"       target:self selector:@selector(tap_back)], nil];
        
        [bg                 setPosition:ccp(screenSize.width/2,screenSize.height/2)];
        [menu_back          setPosition:ccp(25, 25)];
        
        [self addChild:bg];
        [self addChild:menu_back z:1000];
    }
    
    return self;
}

- (void) tap_back
{
    [view removeFromSuperview];
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[WorldSelectScene scene]]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.scrollEnabled = NO;
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    
    FacebookTableCell *cell = (FacebookTableCell *)[tableView dequeueReusableCellWithIdentifier:@"FacebookTableCell"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FacebookTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.nameLabel.font           = [UIFont fontWithName:@"CrashLanding BB" size:22.0f];
    cell.scoreLabel.font           = [UIFont fontWithName:@"CrashLanding BB" size:22.0f];
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    
    cell.nameLabel.text        = [tableTitles objectAtIndex:indexPath.row];
    cell.scoreLabel.text       = [tableData objectAtIndex:indexPath.row];
    cell.scoreLabel.textColor  = [UIColor colorWithRed:255.0/255.0f green:255.0/255.0f blue:255.0/255.0f alpha:1.0f];
    cell.facebookImageView.hidden = TRUE;
    
    return cell;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{ return [tableTitles count]; }
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { return 20.0; }

@end