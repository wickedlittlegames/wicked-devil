#pragma mark === GAME CENTRIC NUMBERS ===
#define LEVELS_PER_WORLD 20
#define WORLDS_PER_GAME  12
#define CURRENT_WORLDS_PER_GAME 4
#define PLAYER_CONTROL_SPEED 2.9 // drag - was 4

#pragma mark === ACHIEVEMENT IDS ===

#define ACV_FIRST_PLAY 1 // first time the game is played "First Impressions" // track if played level 1 - world 1  - 10
#define ACV_BEAT_WORLD_1 2 // escaped from hell "All Hell Broke Loose"        // if player world > 1 - 50
#define ACV_BEAT_WORLD_2 3 // escaped from the underground "There Ain't No Grave..." // if player world > 2 - 50
#define ACV_BEAT_WORLD_3 4 // escaped from the sea "Boiling Oceans" // if player world > 3 - 50
#define ACV_BEAT_WORLD_4 5 // escaped from earth "" // if player world > 4 - 50
#define ACV_KILLED_BY_DEATH 8 // an enemy killed you "Killed By Death" // was killed by an enemy - 10
#define ACV_THOUSAND_SOULS 9 // collected 1000 souls "Soul Collector"  // when user.souls > 1000 - 10
#define ACV_5THOUSAND_SOULS 10 // collected 5000 souls "Soul Commander" // when user.souls > 5000 - 20
#define ACV_10THOUSAND_SOULS 11 // collected 10000 souls "Soul Dominator"  // when user.souls > 10000 - 50
#define ACV_50THOUSAND_SOULS 12 // collected 50000 souls "Soul Master" // when user.souls > 50000 - 100
#define ACV_DIED_100_TIMES 13 // died 100 times "It's Safer in Hell" // when user.died = 100 - 20
#define ACV_1000JUMPSONPLATFORM 14 // jumped on 1000 platforms "Van Halen Would Be Proud" when user.jumped = 1000 - 50
#define ACV_COLLECTED_666_SOULS 20 // collected 666 souls "The Number Of The Beast" - 666 souls - 20