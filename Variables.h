static UIColor *darkBlueColor = [UIColor colorWithRed:0.11 green:0.16 blue:0.21 alpha:1.0];
static UIColor *lightBlueColor = [UIColor colorWithRed:0.22 green:0.32 blue:0.42 alpha:1.0];
static UIColor *darkPurpleColor = [UIColor colorWithRed:0.18 green:0.17 blue:0.21 alpha:1.0];
static UIColor *lightPurpleColor = [UIColor colorWithRed:0.36 green:0.34 blue:0.42 alpha:1.0];
static UIColor *darkRedColor = [UIColor colorWithRed:0.30 green:0.22 blue:0.22 alpha:1.0];
static UIColor *loadedStoryNameColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
static UIColor *unloadedStoryNameColor = [UIColor colorWithRed:0.72549 green:0.752941 blue:0.780392 alpha:1.0];
static UIColor *snapPurpleColor = nil;
static UIColor *snapBlueColor = nil;
static UIColor *snapRedColor = nil;
static UIColor *snapGreenColor = [UIColor colorWithRed:0.0117647 green:0.647059 blue:0.533333 alpha:1.0];
static UIColor *darkGreenColor = [UIColor colorWithRed:0.12 green:0.15 blue:0.12 alpha:1.0];
static UIColor *lightGreenColor = [UIColor colorWithRed:0.19*2.0 green:0.24*2.0 blue:0.20*2.0 alpha:1.0];
static UIColor *defaultBrushColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.00 alpha:1.0]; // Blue for now
extern "C" NSBundle *bundle = [[NSBundle alloc] initWithPath:kBundlePath];
extern "C" double brushWidth = 0;
extern "C" int brushButtonState = 2;
extern "C" int minBrushState = 0;
extern "C" int maxBrushState = 7; // [0-6] are brush sizes [7] is 3d touch mode
extern "C" NSString *brushState = [NSString stringWithFormat:@"%d", brushButtonState];
extern "C" UILabel *brushStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 240, 300, 30)];
extern "C" UILabel *pressureLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 300, 300, 30)];
extern "C" double force = 0; // Pressure from 3D touch
extern "C" double finalForce = 0; // Pressure from 3D touch to save for the brush size
extern "C" UIImageView *brushStateView = nil;
extern "C" NSArray* brushImageArray = nil;
extern "C" UIButton *brushButton = nil;
extern "C" UIButton *threeDBrushButton = nil;
extern "C" UIButton *sendButton = nil;
static CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
static CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
extern "C" CAShapeLayer *circleLayer = [CAShapeLayer layer];
extern "C" CFTimeInterval buttonPressedStartTime = nil;
extern "C" bool isHoldingThreeDButton = nil;
extern "C" UIImageView *checkmarkView = nil;
static Snap *testSnap = nil;
BOOL isPortrait = true;
BOOL useDefaultBrushColor = true;

// For inside individual chat view
static UIImage *chat_sent_opened_redAt2x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"chat_sent_opened_red@2x" ofType:@"png"]];
static NSData *chat_sent_opened_redAt2xData = UIImagePNGRepresentation(chat_sent_opened_redAt2x);

static UIImage *chat_sent_opened_purpleAt2x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"chat_sent_opened_purple@2x" ofType:@"png"]];
static NSData *chat_sent_opened_purpleAt2xData = UIImagePNGRepresentation(chat_sent_opened_purpleAt2x);

static UIImage *NMchat_sent_opened_redAt2x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"NMchat_sent_opened_red@2x" ofType:@"png"]];
static UIImage *NMchat_sent_opened_purpleAt2x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"NMchat_sent_opened_purple@2x" ofType:@"png"]];

// For the feed
static UIImage *sent_opened_redAt2x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"sent_opened_red@2x" ofType:@"png"]];
static NSData *sent_opened_redAt2xData = UIImagePNGRepresentation(sent_opened_redAt2x);
static UIImage *sent_opened_redAt3x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"sent_opened_red@3x" ofType:@"png"]];
static NSData *sent_opened_redAt3xData = UIImagePNGRepresentation(sent_opened_redAt3x);

static UIImage *sent_opened_purpleAt2x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"sent_opened_purple@2x" ofType:@"png"]];
static NSData *sent_opened_purpleAt2xData = UIImagePNGRepresentation(sent_opened_purpleAt2x);
static UIImage *sent_opened_purpleAt3x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"sent_opened_purple@3x" ofType:@"png"]];
static NSData *sent_opened_purpleAt3xData = UIImagePNGRepresentation(sent_opened_purpleAt3x);

static UIImage *sent_opened_blueAt2x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"sent_opened_blue@2x" ofType:@"png"]];
static NSData *sent_opened_blueAt2xData = UIImagePNGRepresentation(sent_opened_blueAt2x);
static UIImage *sent_opened_blueAt3x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"sent_opened_blue@3x" ofType:@"png"]];
static NSData *sent_opened_blueAt3xData = UIImagePNGRepresentation(sent_opened_blueAt3x);

static UIImage *NMsent_opened_redAt2x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"NMsent_opened_red@2x" ofType:@"png"]];
static UIImage *NMsent_opened_redAt3x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"NMsent_opened_red@3x" ofType:@"png"]];
static UIImage *NMsent_opened_purpleAt2x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"NMsent_opened_purple@2x" ofType:@"png"]];
static UIImage *NMsent_opened_purpleAt3x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"NMsent_opened_purple@3x" ofType:@"png"]];
static UIImage *NMsent_opened_blueAt2x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"NMsent_opened_blue@2x" ofType:@"png"]];
static UIImage *NMsent_opened_blueAt3x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"NMsent_opened_blue@3x" ofType:@"png"]];



static UIImage *screenshot_redAt2x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"screenshot_red@2x" ofType:@"png"]];
static NSData *screenshot_redAt2xData = UIImagePNGRepresentation(screenshot_redAt2x);
static UIImage *screenshot_redAt3x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"screenshot_red@3x" ofType:@"png"]];
static NSData *screenshot_redAt3xData = UIImagePNGRepresentation(screenshot_redAt3x);

static UIImage *screenshot_purpleAt2x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"screenshot_purple@2x" ofType:@"png"]];
static NSData *screenshot_purpleAt2xData = UIImagePNGRepresentation(screenshot_purpleAt2x);
static UIImage *screenshot_purpleAt3x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"screenshot_purple@3x" ofType:@"png"]];
static NSData *screenshot_purpleAt3xData = UIImagePNGRepresentation(screenshot_purpleAt3x);

static UIImage *screenshot_blueAt2x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"screenshot_blue@2x" ofType:@"png"]];
static NSData *screenshot_blueAt2xData = UIImagePNGRepresentation(screenshot_blueAt2x);
static UIImage *screenshot_blueAt3x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"screenshot_blue@3x" ofType:@"png"]];
static NSData *screenshot_blueAt3xData = UIImagePNGRepresentation(screenshot_blueAt3x);

static UIImage *NMscreenshot_redAt2x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"NMscreenshot_red@2x" ofType:@"png"]];
static UIImage *NMscreenshot_redAt3x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"NMscreenshot_red@3x" ofType:@"png"]];
static UIImage *NMscreenshot_purpleAt2x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"NMscreenshot_purple@2x" ofType:@"png"]];
static UIImage *NMscreenshot_purpleAt3x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"NMscreenshot_purple@3x" ofType:@"png"]];
static UIImage *NMscreenshot_blueAt2x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"NMscreenshot_blue@2x" ofType:@"png"]];
static UIImage *NMscreenshot_blueAt3x = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"NMscreenshot_blue@3x" ofType:@"png"]];


