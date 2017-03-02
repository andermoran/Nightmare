//#import "libcolorpicker/libcolorpicker.mm"
#import "Interfaces.h"
#import "Variables.h"
#import "Headers.h"
#import "InspectiveC/InspCWrapper.m"
#import <rocketbootstrap/rocketbootstrap.h>
#import <LocalAuthentication/LocalAuthentication.h>
#include <mach-o/dyld.h>

#if INSPECTIVEC_DEBUG
#include "InspCWrapper.m"
#endif

static NSDictionary *prefs = nil;
static NSMutableDictionary *captions = nil;
static NSString *captionsPath = nil;
static NSMutableArray *hiddenStories = nil;
static NSString *snapchatVersion = nil;
static NSString *individualChatUsername = nil;
static NSString *caption = nil;
BOOL didHideNames = false;
AVCameraViewController* controller = nil;

//UIColor *colorFromDefaultsWithKey(NSString *defaults, NSString *key, NSString *fallback);

static NSMutableDictionary *getFriendNames() {
	NSMutableDictionary *displayNames = [[NSMutableDictionary alloc] init]; 	// Stores the display names so that they can be sorted
	Manager *manager = [objc_getClass("Manager") shared];
	User *user = [manager user];
	Friends *friends = [user friends];

	for(Friend *f in [friends getAllFriends]) {
		NSString *displayName = [f display]; // What the user's name appears as to you
		NSString *username = [f atomicName]; // atomicName = username
		NSString *kvoName = [f kvoName];
		
		// Prepares string
		if (![displayName isEqualToString:@""]) {
			// If a display name is set for the user ex) "John Doe"
			[displayNames setObject:[NSString stringWithFormat:@"%@", displayName] forKey:kvoName];
		} else {
			// If you do not set a name for a friend, then it defaults to their username ex) "johndoe123"
			[displayNames setObject:[NSString stringWithFormat:@"%@", username] forKey:kvoName];
		}
	}
	return displayNames;
}

//static NSMutableArray* getFriendUsernames(){
//	NSMutableArray *usernames = [[NSMutableArray alloc] init]; 	// Stores the usernames so that they can be sorted
//	Manager *manager = [objc_getClass("Manager") shared];
//	User *user = [manager user];
//	Friends *friends = [user friends];
//	
//	for(Friend *f in [friends getAllFriends]){
//		NSString *username = [f atomicName]; // atomicName = username
//		if (![username isEqualToString:@""]) {
//			// Prevents empty usernames from being added
//			[usernames addObject:[NSString stringWithFormat:@"%@\n", username]];
//		}
//	}
//	return usernames;
//}

// HUGE THANKS TO YUNG RAJ FOR DAEMON STUFF
static void SendRequestToDaemon(){
	NSLog(@"Nightmare::Sending request to Daemon");
	
	CPDistributedMessagingCenter *c = [CPDistributedMessagingCenter centerNamed:@"com.andermoran.nightmared"];
	rocketbootstrap_unlock("com.andermoran.nightmared");
	rocketbootstrap_distributedmessagingcenter_apply(c);
	[c sendMessageName:@"friendlist"
			  userInfo:getFriendNames()];
	NSLog(@"Nightmare::Sent request to Daemon");
}

void loadCustomColors() {
	if ([prefs[@"kReplaceSnapBlueColorEnabled"] boolValue]) {
		//snapBlueColor = colorFromDefaultsWithKey(@"com.andermoran.nightmare", @"kSnapBlueColorReplacement", @"#000000");
	} else {
		snapBlueColor = [UIColor colorWithRed:0.054902 green:0.678431 blue:1.00 alpha:1.0];
	}
	
//	if ([prefs[@"kReplaceSnapPurpleColorEnabled"] boolValue]) {
//		snapPurpleColor = colorFromDefaultsWithKey(@"com.andermoran.nightmare", @"kSnapPurpleColorReplacement", @"#ffffff");
//	} else {
		snapPurpleColor = [UIColor colorWithRed:0.607843 green:0.333333 blue:0.627451 alpha:1.0];
//	}
//	
//	
//	if ([prefs[@"kReplaceSnapRedColorEnabled"] boolValue]) {
//		snapRedColor = colorFromDefaultsWithKey(@"com.andermoran.nightmare", @"kSnapRedColorReplacement", @"#ffffff");
//	} else {
		snapRedColor = [UIColor colorWithRed:0.913725 green:0.152941 blue:0.329412 alpha:1.0];
//	}
	
}

BOOL shoudLoadCustomColors() {
	BOOL customColorsEnabled = false;
	if (//[prefs[@"kReplaceSnapPurpleColorEnabled"] boolValue] ||
		//[prefs[@"kReplaceSnapRedColorEnabled"] boolValue] ||
		[prefs[@"kReplaceSnapBlueColorEnabled"] boolValue]) {
		customColorsEnabled = true;
	}
	return customColorsEnabled;
}

static void loadPreferences() {
	// Load preferences
	if(!snapchatVersion){
		NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
		snapchatVersion = [infoDict objectForKey:@"CFBundleVersion"];
	}
	if(!prefs){
		prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.andermoran.nightmare.plist"];
	}
	
	// Custom colors 
	if(shoudLoadCustomColors()) {
		//NSLog(@"Nightmare::Beginning to load custom colors...");
		loadCustomColors();
		//NSLog(@"Nightmare::Finished loading custom colors!");

	}
	// Default colors
	else {
		snapPurpleColor = [UIColor colorWithRed:0.607843 green:0.333333 blue:0.627451 alpha:1.0];
		snapBlueColor = [UIColor colorWithRed:0.054902 green:0.678431 blue:1.00 alpha:1.0];
		snapRedColor = [UIColor colorWithRed:0.913725 green:0.152941 blue:0.329412 alpha:1.0];
	}
	if([prefs[@"kHiddenStoriesEnabled"] boolValue]) {
		if(!hiddenStories){
			NSDictionary *friendList = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.andermoran.friendlist.plist"];
			hiddenStories = [[NSMutableArray alloc] init];
			for(NSString *kvoName in [friendList allKeys]){
				if([friendList[kvoName] boolValue]){
					[hiddenStories addObject:kvoName];
				}
			}
		}
	}
	
	if([prefs[@"kRememberCaptionEnabled"] boolValue]) {
		captionsPath = [[(NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)) objectAtIndex:0]stringByAppendingPathComponent:@"NMcaptions.plist"];
		if (!captions) {
			// Loads the logged captions from before
			NSDictionary *savedCaptions = [NSDictionary dictionaryWithContentsOfFile:captionsPath];
			//NSLog(@"Nightmare::savedCaptions = %@", savedCaptions);
			//NSLog(@"Nightmare::captionsPath = %@", captionsPath);
			captions = [[NSMutableDictionary alloc] init];
			// If not null, then copy it is captions
			if (savedCaptions) {
				captions = [savedCaptions mutableCopy];
			}
			[captions setObject:@"[caption]" forKey:@"[username]"];
			//NSLog(@"Nightmare::captions = %@", captions);
			[captions writeToFile:captionsPath atomically:YES];
		}
		if (!caption) {
			caption = @"";
		}
	}
}

/*void SendAutoReplySnapToUser(NSString *username){
	NSString *imagePath = [bundle pathForResource:@"Test" ofType:@"jpeg"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	if(image){
		//Snap *snap = [[objc_getClass("Snap") alloc] init];
		testSnap.recipient = username;
		testSnap.media.mediaDataToUpload = UIImageJPEGRepresentation(image,0.7);
		testSnap.broadcastSnap = false;
		testSnap.clearedByRecipient = false;
		testSnap.clearedBySender = false;
		testSnap.closedAt = 0;
		testSnap.correspondentId = username;
		testSnap.displayedActionTextInFeed = false;
		testSnap.doubleTap = false;
		testSnap.expiredWhileStackNotEmpty = false;
		testSnap.failedAtLeastOnce = false;
		testSnap.groupId = 0;
		testSnap.hideBroadcastTimer = false;
		testSnap.invitedRecipients = nil;
		testSnap.isInitialView = false;
		testSnap.isLastViewedSnapInStack = false;
		testSnap.isPaidToReplay = false;
		testSnap.needsRetry = false;
		testSnap.numAutomaticRetries = 0;
		testSnap.numTimesCanBeReplayed = 0;
		testSnap.numTimesReloaded = 0;
		testSnap.pending = false;
		testSnap.recentlyViewedAndHasNotLeftView = false;
		testSnap.replayAnimationStateChat = 0;
		testSnap.replayAnimationStateFeed = 0;
		testSnap.replayed = false;
		testSnap.screenshots = 0;
		testSnap.secondsViewed = 0;
		testSnap.state = -2;
		testSnap.status = 0;
		testSnap.timeStartedOnScreen = 0;
		testSnap.viewSource = 0;
		testSnap.clientId = @"NOTANDER~7A8D3344-6E68-4CC8-8E96-5A36E3157F5B";
		

		
		[testSnap send];
	}
	
}
*/

%group settingsHooks

%hook SCSettingsTableViewCell
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	// Triggered if the user is touching down on the cell
	if (highlighted) {
		self.backgroundColor = lightGreenColor;
	} else {
		self.backgroundColor = darkGreenColor;
	}
}
%end

// Need to hook to change the background color
%hook SCLeftSwipableViewController
-(void)viewWillAppear:(BOOL)arg1 {
	%orig();
	if ([NSStringFromClass([self class]) isEqualToString:@" P"]) {
		// Sets the background color of the settings view controller to dark
		self.view.backgroundColor = darkGreenColor;
	}
}
%end
// CAUSES NETWORK ERROR
/*%hook B // @interface  P : SCLeftSwipableViewController
- (id)textColorForHeader:(id)arg1 {
	// 'Settings' text color is white
	return [UIColor whiteColor];
}
- (id)backgroundColorForHeader {
	// Background color for the settings header set to green
	return snapGreenColor;
}
// Makes the back button on the Snapchat header white
- (id)imageForLeftButtonInState:(unsigned long long)arg1 {
	NSString *imagePath = [bundle pathForResource:@"Back_Button@2x" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	return image;
}

- (void)viewWillAppear:(_Bool)arg1 {
	%orig();
	// Sets the color of the bar under the 'Settings' header to light
	SCHeader *header = MSHookIvar<SCHeader *>(self, "_header");
	header.bottomBorderedView.borderColor = lightGreenColor;
	//self.view.backgroundColor = darkGreenColor;
}
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
	SCSettingsTableViewCell* cell = %orig();
	cell.backgroundColor = darkGreenColor;
	cell.textLabel.textColor = [UIColor whiteColor];
	return cell;
}
- (id)tableView:(id)arg1 viewForHeaderInSection:(long long)arg2 {
	UIView* header = %orig();
	// Sets color behind 'MY ACCOUNT' and 'ADDITIONAL SERVICES', etc.
	header.backgroundColor = darkGreenColor;
	return header;
}
%end*/

%end

%group memoriesHooks

%hook SCGalleryHeaderBar
// SCExpandedButton *_searchButton; change to white NEED TO DO
- (id)initWithFrame:(struct CGRect)arg1 {
	self = %orig();
	UILabel *titleLabel = MSHookIvar<UILabel *>(self, "_titleLabel");
	UIView *defaultContainerView = MSHookIvar<UIView *>(self, "_defaultContainerView");
	SCExpandedButton *searchButton = MSHookIvar<SCExpandedButton *>(self, "_searchButton");
	if (self) {
		// Makes the 'Memories' text white
		titleLabel.textColor = [UIColor whiteColor];
		
		// Sets the background color of the text to clear so that the red background can be seen
		titleLabel.backgroundColor = [UIColor clearColor];
		
		// Sets the bar at the top of the memories view to red
		self.backgroundColor = snapRedColor;
		
		// Set the header background color to red
		defaultContainerView.backgroundColor = snapRedColor;
		
		//
		UIImage *magnifyingGlass = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"search_preview_normal@2x" ofType:@"png"]];
		[searchButton setImage:[magnifyingGlass imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
	}
	return self;
}
%end

%hook SCGalleryEntryBasedTabController
// Sets the background color behind the memories media to dark red
- (id)collectionView {
	SCGalleryTabCollectionView* collectionView = %orig();
	collectionView.backgroundColor = darkRedColor;
	return collectionView;
}
%end

// Hides the rounded corners on the top media rectangle because they are white and I can't change them :/
%hook SCGalleryTabCollectionTopRoundedCornersOverlayView
- (id)initWithFrame:(struct CGRect)arg1 {
	self = %orig();
	if (self) {
		self.hidden=true;
	}
	return self;
}
%end

// Hides the rounded corners on the bottom media rectangle because they are white and I can't change them :/
%hook SCGalleryTabCollectionBottomRoundedCornersOverlayView
- (id)initWithFrame:(struct CGRect)arg1 {
	self = %orig();
	if (self) {
		self.hidden=true;
	}
	return self;
}
%end


%hook SCGalleryTabBar
- (id)initWithFrame:(struct CGRect)arg1 normalStateColor:(id)arg2 highlightedStateColor:(id)arg3 {
	UIColor* highlightedStateColor = [UIColor whiteColor];
	// When item is selected ('ALL, SNAPS, STORIES, CAMERA ROLL') its color and bar under is white
	self = %orig(arg1, arg2, highlightedStateColor);
	UICollectionView *collectionView = MSHookIvar<UICollectionView *>(self, "_collectionView");
	if (self) {
		// Sets the color behind the text 'ALL, SNAPS, STORIES, CAMERA ROLL' to dark red
		collectionView.backgroundColor = darkRedColor;
	}
	return self;
}
%end

%hook SCGalleryTabBarItemCell
- (id)initWithFrame:(struct CGRect)arg1 {
	self = %orig();
	if (self) {
		self.normalStateColor = [UIColor blueColor];
		self.highlightedStateColor = [UIColor orangeColor];
	}
	return self;
}
%end

%end

%group discoverHooks

%hook SCDiscoverViewController
// Makes the back button on the Discover header white
- (id)imageForLeftButtonInState:(unsigned long long)arg1 {
	NSString *imagePath = [bundle pathForResource:@"Back_Button@2x" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	return image;
}

// Sets the color of the header behind 'Discover'
- (id)backgroundColorForHeader {
	return snapPurpleColor;
}
// Sets the 'Discover' text to white
- (id)textColorForHeader:(id)arg1 {
	return [UIColor whiteColor];
}
%end

%end

%group individualChatView

%hook SCTPresenceBarVC
- (id)initWithUIDescriptionProvider:(id)arg1 groupCreation:(_Bool)arg2 {
	self = %orig();
	if (self) {
		// Changes the background color of the bar that contains the names of the people in the group
		self.view.backgroundColor = darkBlueColor;
	}
	return self;
}
%end

// View controller for the individual chat view
%hook SCChatViewControllerV2
%new
- (void)showRecentCaption:(id)sender {
	// Grabs the username to look up in dictionary
	SCChatInputController *inputController = [self chatInputController];
	individualChatUsername = [self chatInputControllerRecipient:inputController];
	// Grabs the caption associated with the username
	//NSLog(@"Nightmare::Dictionary = %@", captions);
	NSString *savedCaption = captions[individualChatUsername];
	// If no caption has been saved them let the user know
	if (!savedCaption) {
		savedCaption = @"No caption saved!";
	}
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You last said..."
												message:savedCaption
												delegate:self 
												cancelButtonTitle:@"Dismiss" 
												otherButtonTitles:nil];
	
	[alert show];
	[alert release];
}

- (void)viewDidLoad {
	%orig();
	// Creates invisible button of the username of the person who you are chatting with
	// Essentially changes the name into a button
	if([prefs[@"kRememberCaptionEnabled"] boolValue]) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button addTarget:self 
				   action:@selector(showRecentCaption:)
		 forControlEvents:UIControlEventTouchUpInside];
		[button setTitle:@"" forState:UIControlStateNormal];
		button.frame = CGRectMake(47,20,281,44);
		[self.view addSubview:button];
	}
}
%end

%hook SCTextChatTableViewCellV2
// Sets the color behind the names (which are in capital) to dark
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 parentVC:(id)arg3 {
	self = %orig();
		
	if(self){
		self.backgroundColor = darkBlueColor;
	}
	return self;
}

- (void)renderChatLabel {
	%orig();
	// Sets the text color in the chat to white
	self.chatLabel.textColor = [UIColor whiteColor];
	// This line is necessary because it essentially updates the label with new text causing the color to change too
	self.chatLabel.text = self.chatLabel.text;
}
%end

%hook SCChatTextLabel
- (id)init {
	self = %orig();
	if(self){
		// Sets the color behind the text to light
		self.backgroundColor = lightBlueColor;
	}
	return self;
}
- (void)setTextColor:(id)arg1 {
	%orig([UIColor whiteColor]);
}
- (id)textColor {
	return [UIColor whiteColor];
}
- (void)setText:(id)arg1 afterInheritingLabelAttributesAndConfiguringWithBlock:(CDUnknownBlockType)arg2 {
	//%orig(@"HELLO",arg2);
	%orig();
}
%end

%hook SCChatInputController
// Turn the 'Send a chat' bar an the icons below it to dark
- (id)inputViewBackgroundColor {
	return darkBlueColor;
}

// Sets the color of the text that goes into the 'Send a chat' box to white
- (id)inputTextColor {
	return [UIColor whiteColor];
}

// Sets the color of the bar that seperates the 'Send a chat' box and the messages to light
- (id)inputViewSeparatorBackgroundColor {
	return lightBlueColor;
}
%end

%hook SCSnapMediaCardView
// Changes the background color of the "card" which is the behind "Opened" and "Delivered"
- (id)initWithParentVC:(id)arg1 delegate:(id)arg2 {
	self = %orig();
	if(self){
		self.backgroundColor = lightBlueColor;
	}
	return self;
}
%end

//Changes the text color of "Opened" and "Delivered" to white
%hook SCSnapStatusView

// Sets the image in the card for the icon (Delivered Red, Opened Red, etc.)
// Figures out what icon to replace
- (void)_setStatusIconImage:(id)arg1 {
	//arg1 = UIImage
	UIImage *originalIcon = arg1;
	NSData *originalIconData = UIImagePNGRepresentation(originalIcon);

	if ([originalIconData isEqual:chat_sent_opened_redAt2xData]) {
		%orig(NMchat_sent_opened_redAt2x);
	} else if ([originalIconData isEqual:chat_sent_opened_purpleAt2xData]) {
		%orig(NMchat_sent_opened_purpleAt2x);
	} else {
		%orig(arg1);
	}
}

- (id)init {
	self = %orig();
	if(self){
		self.statusLabel.textColor = [UIColor whiteColor];
	}
	return self;
}
// Activates the changes to the label (read notes below, TTTAttributedLabel acts weird)
- (void)setStatusText:(id)arg1 {
	%orig();
	// For some reason this is necessary for the TTTAttributedLabel to change color after it is set
	//NSLog(@"Nightmare::self.statusLabel.text = %@", self.statusLabel.text);
	// Not sure why there is a space after 'Delivered' and 'Opened' but that's how they did the label
	if([self.statusLabel.text isEqualToString:@"Delivered "]) {
		%orig(@"Delivered ");
	} else if ([self.statusLabel.text isEqualToString:@"Tap to view"]) {
		%orig(@"Tap to view");
	} else if ([self.statusLabel.text isEqualToString:@"Opened "]) {
		%orig(@"Opened");
	} else if ([self.statusLabel.text isEqualToString:@"Press and hold to replay"]) {
		%orig(@"Press and hold to replay");
	} else if ([self.statusLabel.text isEqualToString:@"Tap to load"]) {
		%orig(@"Tap to load");
	} else if ([self.statusLabel.text isEqualToString:@"Loading..."]) {
		%orig(@"Loading...");
	} else if ([self.statusLabel.text isEqualToString:@"Sending..."]) {
		%orig(@"Sending...");
	} else if ([self.statusLabel.text isEqualToString:@"Replay!"]) {
		%orig(@"Replay!");
	}
}
%end

%hook SCSavedChatNotificationView
// 'SAVED' and 'UNSAVED' text color are set to white
+ (id)labelTextColor {
	return [UIColor whiteColor];
}
%end

%hook SCChatViewHeader
// [Chat header] putting this here so when I search for this I can find it

// When chatting with someone, the color behind their name at the top is set to the snapchat blue color
- (id)backgroundColorForHeader {
	//NSLog(@"Nightmare::snapBlueColor = %@",snapBlueColor);
	return snapBlueColor;
}
// Sets the name at the top of the individual chat to white
- (id)textColorForHeader:(id)arg1 {
	return [UIColor whiteColor];
}
- (id)titleForHeader:(id)arg1 {
	if([prefs[@"kHideInfo"] boolValue]) {
		return @"Name";
	} else {
		return %orig();
	}
	return @"SOMETHING WENT WRONG";
}

// Sets the bottom bar color under the header to light blue
+ (id)headerBorderColor {
	return lightBlueColor;
}

// Makes the three horizontal lines button on the individual chat view header white
- (id)imageForLeftButtonInState:(unsigned long long)arg1 {
	NSString *imagePath = [bundle pathForResource:@"Chat_Hamburger@2x" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	return image;
}

// Makes the forward arrow button on the individual chat view header white
- (id)imageForRightButtonInState:(unsigned long long)arg1 {
	NSString *imagePath = [bundle pathForResource:@"Forward_Button@2x" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	return image;
}
%end

%hook SCSnapChatTableViewCellV2
// Sets the color in between messages messages to dark
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 parentVC:(id)arg3 delegate:(id)arg4 {
	self = %orig();
		
	if(self){
		// Sets the color behind 'TODAY' to dark, or maybe it does it for the date at the top idk
		self.backgroundColor = darkBlueColor;
	}
	return self;
}

%end

%hook SCStackedNoteChatTableViewCell
// Sets the color behind the name when there are multiple media items in chat cell
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 parentVC:(id)arg3 delegate:(id)arg4 {
	self = %orig();
	if (self) {
		self.backgroundColor = darkBlueColor;
	}
	return self;
}
%end

%hook SCStackedVideoNoteCollectionViewCell
// Sets a square color background behind the snapchat circle videos in chat cells
- (void)setBackgroundColor:(id)arg1 {
	%orig(lightBlueColor);
}
%end

%hook SCChatTableViewDataSourceV2
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
	// Changes the color of the payloadview which is the view behind the cells in the individual chat view
	// returns SCTextChatTableViewCellV2 or SCMediaChatTableViewCell
	id temp = %orig();
	if ([temp isKindOfClass:objc_getClass("SCTextChatTableViewCellV2")]) {
		SCTextChatTableViewCellV2 *chatCell = temp;
		chatCell.payloadView.backgroundColor = lightBlueColor;
		return chatCell;
	} else if ([temp isKindOfClass:objc_getClass("SCMediaChatTableViewCell")]) {
		SCMediaChatTableViewCell* chatCell = temp;
		chatCell.payloadView.backgroundColor = lightBlueColor;
		return chatCell;
	} else if ([temp isKindOfClass:objc_getClass("SCStackedNoteChatTableViewCell")]) {
		SCStackedNoteChatTableViewCell* chatCell = temp;
		chatCell.payloadView.backgroundColor = lightBlueColor;
		return chatCell;
	} else if ([temp isKindOfClass:objc_getClass("SCStackedStickerChatTableViewCell")]) {
		SCStackedStickerChatTableViewCell* chatCell = temp;
		chatCell.payloadView.backgroundColor = lightBlueColor;
		return chatCell;
	} else if ([temp isKindOfClass:objc_getClass("SCMissCallChatTableViewCell")]) {
		SCMissCallChatTableViewCell* chatCell = temp;
		// Sets the date background color i.e. 'TODAY' when a video call is missed to dark
		chatCell.backgroundColor = darkBlueColor;
		return chatCell;
	} else if ([temp isKindOfClass:objc_getClass("SCStoryMediaChatTableViewCell")]) {
		SCMissCallChatTableViewCell* chatCell = temp;
		// Sets the date background color i.e. 'TODAY' when a video call is missed to dark
		chatCell.backgroundColor = darkBlueColor;
		return chatCell;
	}
	//SCStoryMediaChatTableViewCell
	//NSLog(@"Nightmare::SCChatTableViewDataSourceV2 tableView returns = %@",a);
	return temp;
}
%end

%hook SCStackedStickerCollectionViewCell
// Sets the background color of the stickers sent in chat
- (id)initWithFrame:(struct CGRect)arg1 {
	self = %orig();
	if (self) {
		self.contentView.backgroundColor = lightBlueColor;
	}
	return self;
}
%end

%hook SCChatBaseTableView
// Sets background color of the chat view to dark
- (id)initWithFrame:(struct CGRect)arg1 {
	self = %orig();
	if(self){
		self.backgroundColor = darkBlueColor;
	}
	return self;
}
%end

%hook SCMediaChatTableViewCell
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 parentVC:(id)arg3 delegate:(id)arg4 thumbnailType:(long long)arg5 {
	self = %orig();
	if(self){
		// Sets the color behind 'TODAY' to dark, or maybe it does it for the date at the top idk
		self.backgroundColor = darkBlueColor;
	}
	return self;
}
%end


%hook SCChatTableViewCell
// Sets background of chat elements (Delivered, text, media) to darkGray
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 parentVC:(id)arg3 {
	self = %orig();
	if(self){
		self.bodyView.backgroundColor = darkBlueColor;
	}
	return self;
}
%end

%end

%group chatHooks

%hook SCFeedTableHeaderView
- (id)init {
	self = %orig();
	SCSearchBar *searchBar = MSHookIvar<SCSearchBar *>(self, "_searchBar");
	if (self) {
		// Sets the colors of the search bar in the chat feed
		searchBar.backgroundColor = darkBlueColor;
		searchBar.inputTextField.textColor = [UIColor whiteColor];
		searchBar.bottomBorderView.backgroundColor = lightBlueColor;
		searchBar.topBorderView.backgroundColor = lightBlueColor;
	}
	return self;
}
%end

%hook SCFeedTableLoadingView
- (id)init {
	self = %orig();
	if(self){
		// When searching for a user in the chat view controller, the 'Loading...' text is white
		self.label.textColor = [UIColor whiteColor];
	}
	return self;
}
%end

%hook SCCardPullToRefreshView
- (id)initWithFrame:(struct CGRect)arg1 {
	self = %orig();
	if(self){
		self.backgroundColor = darkBlueColor;
	}
	return self;
}
%end

%hook SCGradientView
// Removes the white gradient thing at the bottom of the feed
// Actually it doesn't...
- (id)gradientLayer {
	//CAGradientLayer *bottomGradient = %orig;
	//bottomGradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[darkBlueColor CGColor], nil];
	//return nil;
	// Returns CAGradientLayer
	return %orig();
}
%end

%hook SCSearchBar
// Makes the background of the search bar in general to dark
// Sets the text color of the search bar to white
- (id)initWithFrame:(struct CGRect)arg1 {
	self = %orig();
	if(self){
		self.backgroundColor = darkPurpleColor;
		self.inputTextField.textColor = [UIColor whiteColor];
		self.bottomBorderView.backgroundColor = lightPurpleColor;
		self.topBorderView.backgroundColor = lightPurpleColor;
		
		// Sets the keyboard to dark when using the search bar
		self.inputTextField.keyboardAppearance = UIKeyboardAppearanceDark;
	}
	return self;
}
%end

// When sending a snapchat to contacts view cell
// [Sendviewcontroller]
// Also used in 'Chat with...'
%hook SelectContactCell
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 page:(id)arg3 {
	self = %orig();
	self.backgroundView.backgroundColor = darkBlueColor;
	// Sets color of the username to white
	self.nameLabel.textColor = [UIColor whiteColor];
	return self;
}
// Sets the background color to dark when unselected
- (void)setUnselectedBackground {
	%orig();
	self.backgroundView.backgroundColor = darkBlueColor;
	self.nameLabel.textColor = [UIColor whiteColor];
}
// Sets the background color to light when selected
- (void)setSelectedBackground {
	%orig();
	self.backgroundView.backgroundColor = lightBlueColor;
	self.nameLabel.textColor = [UIColor whiteColor];
}
%end

%hook SCSelectRecipientsView
- (id)initWithFrame:(struct CGRect)arg1 configuration:(id)arg2 {
	self = %orig();
	if(self){
		// Sets the furthest background to dark
		self.backgroundColor = darkBlueColor;
	}
	return self;
}

- (id)tableView:(id)arg1 viewForHeaderInSection:(long long)arg2 {
	UIView* header = %orig();
	// Sets color behind 'STORIES', 'BEST FRIENDS, 'RECENTS', 'NEEDS LOVE', 'A', 'B', etc.
	header.backgroundColor = darkBlueColor;
	return header;
}
// Changes the "view more recents..." cell
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
	UITableViewCell* recentsCell = %orig();
	recentsCell.backgroundColor = darkBlueColor;
	recentsCell.textLabel.textColor = [UIColor whiteColor];
	return recentsCell;
}

// TRYING TO CHANGE SEPARATOR LINES
%end

// Little box containing a snapchatter's info when the user holds down on their name
%hook SCMiniProfileView
// Sets the background of the card to dark
- (id)initWithFrame:(struct CGRect)arg1 friend:(id)arg2 parentViewController:(id)arg3 delegate:(id)arg4 {
	self = %orig();
	if(self){
		self.card.backgroundColor = darkBlueColor;
	}
	return self;
}
%end

%hook SCMiniProfileButtonView
// Changes the color of the seperator to light blue
- (id)initWithFrame:(struct CGRect)arg1 friend:(id)arg2 delegate:(id)arg3{
	self = %orig();
	UIView *separator = MSHookIvar<UIView *>(self, "_separator");
	
	if(self){
		separator.backgroundColor = lightBlueColor;
	}
	return self;
}
%end

%hook SCMiniProfileTextView
// Changes the user's name color to white
- (id)initWithFrame:(struct CGRect)arg1 {
	self = %orig();
	UILabel *displayNameLabel = MSHookIvar<UILabel *>(self, "_displayNameLabel");
	displayNameLabel.textColor = [UIColor whiteColor];
	return self;
}

- (void)_resetWithDisplay:(id)arg1 username:(id)arg2 score:(id)arg3 astrologicalSign:(id)arg4 {
	// Hiding user info
	if([prefs[@"kHideInfo"] boolValue]) {
		%orig(arg1, @"username", @"12,345", arg4);
		UILabel *displayNameLabel = MSHookIvar<UILabel *>(self, "_displayNameLabel");
		displayNameLabel.text = @"First Last";
	} else {
		%orig();
	}
}
%end

%hook SCFeedComponentView
// Sets the seperators between each cell in chat feed to light
- (id)initWithFrame:(struct CGRect)arg1 feedMode:(long long)arg2 {
	self = %orig();
	UIView *bottomBorder = MSHookIvar<UIView *>(self, "_bottomBorder");
	if (self) {
		bottomBorder.backgroundColor = lightBlueColor;
	}
	return self;
}

// Sets the background of the cells in the chat feed dark
- (void)setBackgroundColor:(id)arg1 {
	%orig(darkBlueColor);
}

- (void)setBackgroundAlpha:(double)arg1 {
	%orig(1.0);
}
// Sets the color of the chat cells white (the usernames)
- (void)setLabel:(id)arg1 width:(double)arg2 {
	UILabel* temp = arg1;
	if ([temp.text isEqualToString:@"Ander Moran"]) {
		temp.textColor = [UIColor greenColor];
		//temp.textColor = [UIColor whiteColor];
	} else {
		temp.textColor = [UIColor whiteColor];
	}
	// Hides names of users, doing this only to hide the users when I need to take screenshots of the tweak
	// [hide username] doing this so I can search for this
	// Want to keep the sublabel though
	%orig(temp,arg2);
}

-(id)feedIconView
{
	//NSString *imagePath = [bundle pathForResource:@"sent_blue@2x" ofType:@"png"];
	//UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	if(!MSHookIvar<UIImageView*>(self,"_feedIconView")) {
		MSHookIvar<UIImageView*>(self,"_feedIconView") = [[[UIImageView alloc] initWithFrame:CGRectMake(6,13,40,40)] retain];
		MSHookIvar<UIImageView*>(self,"_feedIconView").image = nil;
		[self addSubview:MSHookIvar<UIImageView*>(self,"_feedIconView")];
	}
	return MSHookIvar<UIImageView*>(self,"_feedIconView");
}
%end

%hook SCFeedChatTableViewCell
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 {
	self = %orig();
	if (self) {
		//self.feedComponentView = nil;
	}
	return self;
}

- (void)setViewModel:(id)arg1 {
	//arg1  = SCFeedChatCellViewModel

	%orig();
}
%end

%hook SCFeedItem
- (id)displayName {
	if([prefs[@"kHideInfo"] boolValue]) {
		return @"username";
	} else {
		return %orig();
	}
	return %orig();
}

%end

%hook SCLoadingIndicatorView
// When sending or receiving a snap, the two little circle things where the icon normally goes is blue
- (id)initWithColor:(id)arg1 size:(unsigned long long)arg2 {
	return %orig(snapBlueColor, arg2);
}
%end

%hook SCFeedHeader
// Sets the header of the chat feed to dark (nope, we want the original blue)
- (id)backgroundColorForHeader {
	return snapBlueColor;
	//return darkBlueColor;
}
%end

%hook SCFeedViewController

- (void)reloadTableView {
	%orig();
}
// [Change icon]
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
 	// Grabs the original object
	SCFeedChatTableViewCell *cell = %orig();
	// Grabs original feed icon data
	NSData *originalIconData = UIImagePNGRepresentation(MSHookIvar<UIImageView *>(cell.feedComponentView,"_feedIconView").image);
	// Decides if the icon needs to be swapped
	if ([originalIconData isEqual:sent_opened_redAt2xData]) {
		MSHookIvar<UIImageView *>(cell.feedComponentView,"_feedIconView").image = NMsent_opened_redAt2x;
	} else if ([originalIconData isEqual:sent_opened_purpleAt2xData]) {
		MSHookIvar<UIImageView *>(cell.feedComponentView,"_feedIconView").image = NMsent_opened_purpleAt2x;
	} else if ([originalIconData isEqual:sent_opened_blueAt2xData]) {
		MSHookIvar<UIImageView *>(cell.feedComponentView,"_feedIconView").image = NMsent_opened_blueAt2x;
	} else if ([originalIconData isEqual:sent_opened_redAt3xData]) {
		MSHookIvar<UIImageView *>(cell.feedComponentView,"_feedIconView").image = NMsent_opened_redAt3x;
	} else if ([originalIconData isEqual:sent_opened_purpleAt3xData]) {
		MSHookIvar<UIImageView *>(cell.feedComponentView,"_feedIconView").image = NMsent_opened_purpleAt3x;
	} else if ([originalIconData isEqual:sent_opened_blueAt3xData]) {
		MSHookIvar<UIImageView *>(cell.feedComponentView,"_feedIconView").image = NMsent_opened_blueAt3x;
	} else if ([originalIconData isEqual:screenshot_redAt2xData]) {
		MSHookIvar<UIImageView *>(cell.feedComponentView,"_feedIconView").image = NMscreenshot_redAt2x;
	} else if ([originalIconData isEqual:screenshot_redAt3xData]) {
		MSHookIvar<UIImageView *>(cell.feedComponentView,"_feedIconView").image = NMscreenshot_redAt3x;
	} else if ([originalIconData isEqual:screenshot_purpleAt2xData]) {
		MSHookIvar<UIImageView *>(cell.feedComponentView,"_feedIconView").image = NMscreenshot_purpleAt2x;
	} else if ([originalIconData isEqual:screenshot_purpleAt3xData]) {
		MSHookIvar<UIImageView *>(cell.feedComponentView,"_feedIconView").image = NMscreenshot_purpleAt3x;
	} else if ([originalIconData isEqual:screenshot_blueAt2xData]) {
		MSHookIvar<UIImageView *>(cell.feedComponentView,"_feedIconView").image = NMscreenshot_blueAt2x;
	} else if ([originalIconData isEqual:screenshot_blueAt3xData]) {
		MSHookIvar<UIImageView *>(cell.feedComponentView,"_feedIconView").image = NMscreenshot_blueAt3x;
	}
	
	return cell;
}
// Sets background of the feed to dark
- (void)viewWillAppear:(_Bool)arg1 {
	%orig;
	self.view.backgroundColor = darkBlueColor;
}
// Sets the color for the text 'No results (poop emoji)' to white and the background color to clear
- (void)updateEmptyFeedPlaceHolderWithSearchStatus:(_Bool)arg1 {
	%orig;
	self.emptyFeedListPlaceholder.textColor = [UIColor whiteColor];
	self.emptyFeedListPlaceholder.backgroundColor = [UIColor clearColor];
}
%end

%hook SCFeedScoreboardView
// Sets the background color of the chat label to blue
- (id)initWithFrame:(struct CGRect)arg1 {
    self = %orig();
    if(self){
        //self.backgroundColor = darkBlueColor;
		self.snapchatLabel.backgroundColor = snapBlueColor;
    }
	return self;
}
%end

%hook SCFriendmojiView
// Sets the streak count text color to white
- (id)initWithFriend:(id)arg1 andLineHeight:(unsigned long long)arg2 andViewType:(long long)arg3 {
	self = %orig();
	if(self){
		self.label.textColor = [UIColor whiteColor];
	}
	return self;
}
%end

%end

%group storyHooks

// This cell appears whenever you post a story
%hook MyProfileStoryCell
// Sets the background color of the cell to dark
- (id)defaultBackgroundColor {
	return darkPurpleColor;
}
// Sets the caption label color to white in the story feed
- (id)initWithReuseIdentifier:(id)arg1 {
	self = %orig();
	if (self) {
		self.captionLabel.textColor = [UIColor whiteColor];
	}
	return self;
}
%end

// Also affects the Discover view controller in a good way! Sets the background to dark purple
%hook SCTilesCollectionViewController
// Sets background of the tiles in the featured stories thingies to dark purple
- (id)initWithLayout:(id)arg1 context:(unsigned long long)arg2 tiles:(id)arg3 delegate:(id)arg4 viewingMediaDelegate:(id)arg5 currentTileSentToEnd:(_Bool)arg6 {
	self = %orig();
	if(self){
		self.collectionView.backgroundColor = darkPurpleColor;
	}
	return self;
}
%end

%hook SCAddFriendCellView
// For the people under the "Add from address book tab" in stories when searching, changes background to dark
- (id)initWithFrame:(struct CGRect)arg1 {
	self = %orig();
	if(self){
		self.backgroundColor = darkPurpleColor;
	}
	return self;
}

// Chnges the text color of the name to white
- (void)updateConstraints {
	%orig;
	self.nameLabel.textColor = [UIColor whiteColor];
}
%end

// Forgot what exactly this does (I know this changes the text color for the cells in 'Added Me')
%hook SCFriendProfileCellTextViewV2
- (id)_getMainLabelFontColorWithStyle:(long long)arg1 {
	return [UIColor whiteColor];
}
%end

%hook SCSWFriendProfileCell
- (id)initWithDelegate:(id)arg1 {
	self = %orig();
	UIView *bottomBorder = MSHookIvar<UIView *>(self, "_bottomBorder");
	if(self){
		// Changes the bottom cell color to light purple in the 'Added Me' cells
		bottomBorder.backgroundColor = lightPurpleColor;
	}
	return self;
}
%end


%hook SCFriendProfileCellView
// When searching for a story, the background of the cell is dark
- (id)initWithDelegate:(id)arg1 {
	self = %orig();
		
	if(self){
		self.backgroundColor = darkPurpleColor;
	}
	return self;
}
// Ensures the cells are dark in the 'Added Me' friends list
// Also does this inside the 'My Friends' and 'Add Friends'
- (void)updateCellViewWithFriend:(id)arg1 isBlocked:(_Bool)arg2 publicFriendStories:(id)arg3 contexts:(id)arg4 thumbnailStyle:(long long)arg5 textViewV2:(_Bool)arg6 mainLabel:(id)arg7 subLabel:(id)arg8 thirdLabel:(id)arg9 textViewStyle:(long long)arg10 addButtonState:(long long)arg11 addButtonStyle:(long long)arg12 backgroundColor:(id)arg13 hasXButton:(_Bool)arg14 {
	%orig(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,darkPurpleColor,arg14);
}
%end

// Deals with the images in the cells in 'Added Me' and probably other things
%hook SCProfilePictureThumbnail
// When a user has a custom profile picture, there is a white border around the ghost, this changes that color to dark purple
// Does this for 'Added Me' cells, 'Add Friends', cells, and 'My Friends' cells
- (void)_setGhostBorderImage:(long long)arg1 {
	NSString *imagePath = [bundle pathForResource:@"profile_addedme_border@2x" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	self.ghostBorderView.image = image;
}

%end

%hook SCStoriesViewController
- (id)friendStoriesCollection { // Maybe this just creates the object but does not touch it afterwards???
	if([prefs[@"kHiddenStoriesEnabled"] boolValue] && !didHideNames) {
		FriendStoriesCollection *collection = %orig(); // THIS IS EMPTY NOW :( FIX ME
		NSLog(@"Nightmare::collection = %@", collection);
		// Hides friends stories in hiddenStories
		NSLog(@"Nightmare::hiddenStories = %@", hiddenStories);
		for (NSString* kvoname in hiddenStories) {
			NSLog(@"Nightmare::going to hide %@", kvoname);
			//[collection.friendsStories removeObjectForKey:kvoname];
		}
		
		//NSLog(@"Nightmare::hid all names!");
		// didHideNames is necessary because if not it goes crazy and does it like a million times
		didHideNames = true;
		return collection;
	} else {
		return %orig();
	}
	return %orig();
}

- (void)viewDidAppear:(_Bool)arg1 {
	%orig;
	// Sets background of stories view controller to dark (this is for when the user scrolls all the way to the bottom)
	self.view.backgroundColor = darkPurpleColor;
	
	// Sets the colors for the search bar
	self.searchBar.backgroundColor = darkPurpleColor;
	self.searchBar.inputTextField.textColor = [UIColor whiteColor];
	self.searchBar.bottomBorderView.backgroundColor = lightPurpleColor;
	self.searchBar.topBorderView.backgroundColor = lightPurpleColor;
}
-(void)viewDidLoad {
	%orig();
	// Reloads tableview to clear the hidden stories cells, if this isn't done then blank stories will appear
	[self.tableView reloadData];
}

// Changes the white bar at the bottom of the header to clear
- (void)_initHeader {
	%orig();
	self.header.bottomBorderedView.borderColor = [UIColor clearColor];
}

// Sets the background of 'Stories' text to dark
- (id)backgroundColorForHeader {
	return snapPurpleColor;
}

// Sets 'Stories' text color to white
- (id)textColorForHeader:(id)arg1 {
	return [UIColor whiteColor];
}

// Sets the names in the stories cells as white and sets the background behind the text to clear
- (void)setupStoriesCell:(id)arg1 withIndexPath:(id)arg2 {
	//NSLog(@"Nightmare::arg1 = %@", arg1);
	%orig;
	StoriesCell *cell = arg1;
	
	cell.subLabel.backgroundColor = [UIColor clearColor];
	cell.nameLabel.backgroundColor = [UIColor clearColor];
	if([cell.nameLabel.textColor isEqual: loadedStoryNameColor]){
		cell.nameLabel.textColor = [UIColor whiteColor];
    } else {
		// Do nothing
	}
	
	// Hides names of users, doing this only to hide the users when I need to take screenshots of the tweak
	// [hide username] doing this so I can search for this
	if([prefs[@"kHideInfo"] boolValue]) {
		cell.nameLabel.text = @"username";
	}
	
	// Changes the three vertical dots on the 'My Story' cell to white
	NSString *imagePath = [bundle pathForResource:@"SC_Story_Expand_Button@2x" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	[cell.expandMyStoryButton setImage:[image imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
}

// Makes the camera button on the Stories header white
- (id)imageForLeftButtonInState:(unsigned long long)arg1 {
	NSString *imagePath = [bundle pathForResource:@"Stories_Header_Camera_Button@2x" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	return image;
}
// Makes the discovery button on the Stories header white
- (id)imageForRightButtonInState:(unsigned long long)arg1 {
	NSString *imagePath = [bundle pathForResource:@"Discover_icon@2x" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	return image;
}
%end

%hook StoriesCell
// Makes the story cells dark
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 {
	self = %orig();
	if(self){
		// Sets cell color to dark
		self.backgroundColor = darkPurpleColor;
		// Sets cell seperators to light
		self.bottomBorder.backgroundColor = lightPurpleColor;
	}
	return self;
}

- (void)setFriendmojiViewForFriend:(id)arg1 {
	%orig();
	/*Friend* f = arg1;
	NSLog(@"Nightmare::setFriendmojiViewForFriend name = %@", f.name);
	self.friendMojiView.label.text = @"D";
	self.friendMojiView.label.hidden = false;*/
}

// Lets people know who the developer is
- (void)addFriendmojiViewForFriend:(id)arg1 {
	%orig();
	//Friend* f = arg1;
	//name is the username
	//NSLog(@"Nightmare::addFriendmojiViewForFriend name = %@", f.name);
	/*if ([f.name isEqualToString:@"username"]) {
		NSLog(@"Nightmare::DEV = %@", f.name);
		f.isVerified = true;
		%orig(f);
	}*/
	//arg1 type = Friend
}
%end

%hook SCStoryIconView
- (id)initWithFrame:(struct CGRect)arg1 {
	self = %orig();
	UIImageView *replayView = MSHookIvar<UIImageView *>(self, "_replayView");
	NSString *imagePath = [bundle pathForResource:@"tap-to-replay-icon@2x" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	if (self) {
		// Makes the replay icon for the stories cells have a clear background instead of white
		replayView.image = image;
	}
	return self;
}
%end

%hook SCStoriesViewHeader
// Turns the background of "RECENT UPDATES" to dark
// Side effect: Also turns changes all the other labels that are similar to it such as the 'LIVE' label which is good :)
- (id)initWithFrame:(struct CGRect)arg1 text:(id)arg2 font:(id)arg3 textColor:(id)arg4 backgroundColor:(id)arg5 {
	return %orig(arg1,arg2,arg3,arg4,darkPurpleColor);
}
// Makes the text color of "RECENT UPDATES" white
- (void)setupLabelWithText:(id)arg1 font:(id)arg2 textColor:(id)arg3 {
	return %orig(arg1,arg2,[UIColor whiteColor]);
}
%end

%end

%group otherHooks

%hook SCStatusBarController
// These two methods set the status bar to always be white
- (void)setIndex:(long long)arg1 statusBarStyle:(long long)arg2 {
	%orig(arg1, 1);
}
- (void)setIndex:(long long)arg1 visibleStatusBar:(_Bool)arg2 statusBarStyle:(long long)arg3 {
	%orig(arg1, arg2, 1);
}
%end

// Seeing maybe how to send snaps programtically
%hook Snap
// Sends a snapchat NEEDS WORK
+ (id)snapFromEphemeralMedia:(id)arg {
	Snap* sendMe = %orig();
	//NSLog(@"Nightmare::snapFromEphemeralMedia debugDescription= %@", sendMe.debugDescription);
	return sendMe;
	
}
+ (id)targetSnapFromEphemeralMedia:(id)arg1 {
	Snap* sendMe = %orig();
	//NSLog(@"Nightmare::targetSnapFromEphemeralMedia debugDescription= %@", sendMe.debugDescription);
	return sendMe;
	
}
- (void)send {
	
	NSLog(@"Nightmare::Ephemeral Media properties before send method");
	NSLog(@"Nightmare::NSString *_id = %@", self._id);
	NSLog(@"Nightmare::NSArray *allGeoFilterIds = %@", self.allGeoFilterIds);
	NSLog(@"Nightmare::_Bool cameraFrontFacing = %@", self.cameraFrontFacing ? @"true" : @"false");
	NSLog(@"Nightmare::NSString *captionText = %@", self.captionText);
	NSLog(@"Nightmare::NSString *clientId = %@", self.clientId);
	NSLog(@"Nightmare::SCSnapCommonLoggingParameters *commonLoggingParameters = %@", self.commonLoggingParameters);
	NSLog(@"Nightmare::EphemeralMedia *doublePostParent = %@", self.doublePostParent);
	NSLog(@"Nightmare::NSString *encryptedGeoData = %@", self.encryptedGeoData);
	NSLog(@"Nightmare::long long ephemeralMediaState = %lld", self.ephemeralMediaState);
	NSLog(@"Nightmare::NSMutableDictionary *eventLoggingParams = %@", self.eventLoggingParams);
	NSLog(@"Nightmare::NSDate *firstPostDate = %@", self.firstPostDate);
	NSLog(@"Nightmare::NSString *geoFilterId = %@", self.geoFilterId);
	NSLog(@"Nightmare::long long geoFilterImpressions = %lld", self.geoFilterImpressions);
	NSLog(@"Nightmare::NSString *iv = %@", self.iv);
	NSLog(@"Nightmare::NSString *key = %@", self.key);
	NSLog(@"Nightmare::CLLocation *location = %@", self.location);
	NSLog(@"Nightmare::Media *media = %@", self.media);
	NSLog(@"Nightmare::unsigned long long numberOfTimesReloaded = %llu", self.numberOfTimesReloaded);
	NSLog(@"Nightmare::long long orientation = %lld", self.orientation);
	NSLog(@"Nightmare::NSData *rawThumbnailData = %@", self.rawThumbnailData);
	NSLog(@"Nightmare::NSMutableDictionary *secretShareLoggingParams = %@", self.secretShareLoggingParams);
	NSLog(@"Nightmare::NSMutableDictionary *shareLoggingParams = %@", self.shareLoggingParams);
	NSLog(@"Nightmare::_Bool shouldIncludeLocationData = %@", self.shouldIncludeLocationData ? @"true" : @"false");
	NSLog(@"Nightmare::NSString *storyFilterId = %@", self.storyFilterId);
	NSLog(@"Nightmare::NSString *storyLensId = %@", self.storyLensId);
	NSLog(@"Nightmare::NSMutableArray *targets = %@", self.targets);
	NSLog(@"Nightmare::Media *thumbnailMedia = %@", self.thumbnailMedia);
	NSLog(@"Nightmare::double time = %f", self.time);
	NSLog(@"Nightmare::double timeLeft = %f", self.timeLeft);
	NSLog(@"Nightmare::double timeStartedViewing = %f", self.timeStartedViewing);
	NSLog(@"Nightmare::long long type = %lld", self.type);
	NSLog(@"Nightmare::NSArray *unlockablesVendorTags = %@", self.unlockablesVendorTags);
	NSLog(@"Nightmare::SnapVideoFilter *videoFilter = %@", self.videoFilter);
	NSLog(@"Nightmare::double videoTimeSoFar = %f", self.videoTimeSoFar);
	NSLog(@"Nightmare::NSDate *viewedTimestamp = %@", self.viewedTimestamp);
	NSLog(@"Nightmare::NSMutableArray *viewingTimestamps = %@", self.viewingTimestamps);
	
	
	NSLog(@"Nightmare::Snap properties before send method");
	NSLog(@"Nightmare::NSString* broadcastActionText = %@", self.broadcastActionText);
	NSLog(@"Nightmare::NSURL* broadcastMediaUrl = %@", self.broadcastMediaUrl);
	NSLog(@"Nightmare::NSString* broadcastSecondaryText = %@", self.broadcastSecondaryText);
	NSLog(@"Nightmare::_Bool broadcastSnap = %@", self.broadcastSnap ? @"true" : @"false");
	NSLog(@"Nightmare::NSURL *broadcastUrlToOpen = %@", self.broadcastUrlToOpen);
	NSLog(@"Nightmare::_Bool clearedByRecipient = %@", self.clearedByRecipient ? @"true" : @"false");
	NSLog(@"Nightmare::_Bool clearedBySender = %@", self.clearedBySender ? @"true" : @"false");
	NSLog(@"Nightmare::double closedAt = %f", self.closedAt);
	NSLog(@"Nightmare::NSString *correspondentId = %@", self.correspondentId);
	NSLog(@"Nightmare::NSString *description = %@", self.description);
	NSLog(@"Nightmare::NSString *display = %@", self.display);
	NSLog(@"Nightmare::_Bool displayedActionTextInFeed = %@", self.displayedActionTextInFeed ? @"true" : @"false");
	NSLog(@"Nightmare::_Bool doubleTap = %@", self.doubleTap ? @"true" : @"false");
	NSLog(@"Nightmare::NSString *encryptedSnapId = %@", self.encryptedSnapId);
	NSLog(@"Nightmare::_Bool expiredWhileStackNotEmpty = %@", self.expiredWhileStackNotEmpty ? @"true" : @"false");
	NSLog(@"Nightmare::_Bool failedAtLeastOnce = %@", self.failedAtLeastOnce ? @"true" : @"false");
	NSLog(@"Nightmare::NSDate *fideliusSendTimestamp = %@", self.fideliusSendTimestamp);
	NSLog(@"Nightmare::NSString *fideliusSnapIv = %@", self.fideliusSnapIv);
	NSLog(@"Nightmare::NSString *fideliusSnapKey = %@", self.fideliusSnapKey);
	NSLog(@"Nightmare::NSString *fideliusVersion = %@", self.fideliusVersion);
	NSLog(@"Nightmare::NSDate *finishViewingTimestamp = %@", self.finishViewingTimestamp);
	NSLog(@"Nightmare::long long groupId = %lld", self.groupId);
	NSLog(@"Nightmare::_Bool hideBroadcastTimer = %@", self.hideBroadcastTimer ? @"true" : @"false");
	NSLog(@"Nightmare::NSDictionary *inviteSnapMetadata = %@", self.inviteSnapMetadata);
	//NSLog(@"Nightmare::__weak id <SCInviteSnapSenderDelegate> inviteSnapSenderDelegate = %@", self.inviteSnapSenderDelegate);
	NSLog(@"Nightmare::NSArray *invitedRecipients = %@", self.invitedRecipients);
	NSLog(@"Nightmare::_Bool isInitialView = %@", self.isInitialView ? @"true" : @"false");
	NSLog(@"Nightmare::_Bool isLastViewedSnapInStack = %@", self.isLastViewedSnapInStack ? @"true" : @"false");
	NSLog(@"Nightmare::_Bool isPaidToReplay = %@", self.isPaidToReplay ? @"true" : @"false");
	NSLog(@"Nightmare::_Bool needsRetry = %@", self.needsRetry ? @"true" : @"false");
	NSLog(@"Nightmare::unsigned long long numAutomaticRetries = %llu", self.numAutomaticRetries);
	NSLog(@"Nightmare::unsigned long long numTimesCanBeReplayed = %llu", self.numTimesCanBeReplayed);
	NSLog(@"Nightmare::unsigned long long numTimesReloaded = %llu", self.numTimesReloaded);
	NSLog(@"Nightmare::_Bool pending = %@", self.pending ? @"true" : @"false");
	NSLog(@"Nightmare::AVPlayerItem *playerItem = %@", self.playerItem);
	NSLog(@"Nightmare::_Bool recentlyViewedAndHasNotLeftView = %@", self.recentlyViewedAndHasNotLeftView ? @"true" : @"false");
	NSLog(@"Nightmare::NSString* recipient = %@", self.recipient);
	NSLog(@"Nightmare::NSString *recipientOutAlpha = %@", self.recipientOutAlpha);
	NSLog(@"Nightmare::NSArray *recipients = %@", self.recipients);
	NSLog(@"Nightmare::long long replayAnimationStateChat = %lld", self.replayAnimationStateChat);
	NSLog(@"Nightmare::long long replayAnimationStateFeed = %lld", self.replayAnimationStateFeed);
	NSLog(@"Nightmare::_Bool replayed = %@", self.replayed ? @"true" : @"false");
	NSLog(@"Nightmare::long long screenshots = %lld", self.screenshots);
	NSLog(@"Nightmare::double secondsViewed = %f", self.secondsViewed);
	NSLog(@"Nightmare::NSString *sender = %@", self.sender);
	NSLog(@"Nightmare::NSString *senderOutAlpha = %@", self.senderOutAlpha);
	NSLog(@"Nightmare::NSDate *sentTimestamp = %@", self.sentTimestamp);
	NSLog(@"Nightmare::NSNumber *snapStreakCount = %@", self.snapStreakCount);
	NSLog(@"Nightmare::NSDate *snapStreakExpiryTime = %@", self.snapStreakExpiryTime);
	NSLog(@"Nightmare::SnapTrophyMetrics *snapTrophyMetrics = %@", self.snapTrophyMetrics);
	NSLog(@"Nightmare::NSString *stackId = %@", self.stackId);
	NSLog(@"Nightmare::long long state = %lld", self.state);
	NSLog(@"Nightmare::long long status = %lld", self.status);
	NSLog(@"Nightmare::double timeStartedOnScreen = %f", self.timeStartedOnScreen);
	NSLog(@"Nightmare::NSNumber *time_left = %@", self.time_left);
	NSLog(@"Nightmare::NSDate *timestamp = %@", self.timestamp);
	NSLog(@"Nightmare::long long viewSource = %lld", self.viewSource);
	
	%orig;
	
	NSLog(@"Nightmare::Snap properties after send method");
	NSLog(@"Nightmare::NSString* broadcastActionText = %@", self.broadcastActionText);
	NSLog(@"Nightmare::NSURL* broadcastMediaUrl = %@", self.broadcastMediaUrl);
	NSLog(@"Nightmare::NSString* broadcastSecondaryText = %@", self.broadcastSecondaryText);
	NSLog(@"Nightmare::_Bool broadcastSnap = %@", self.broadcastSnap ? @"true" : @"false");
	NSLog(@"Nightmare::NSURL *broadcastUrlToOpen = %@", self.broadcastUrlToOpen);
	NSLog(@"Nightmare::_Bool clearedByRecipient = %@", self.clearedByRecipient ? @"true" : @"false");
	NSLog(@"Nightmare::_Bool clearedBySender = %@", self.clearedBySender ? @"true" : @"false");
	NSLog(@"Nightmare::double closedAt = %f", self.closedAt);
	NSLog(@"Nightmare::NSString *correspondentId = %@", self.correspondentId);
	NSLog(@"Nightmare::NSString *description = %@", self.description);
	NSLog(@"Nightmare::NSString *display = %@", self.display);
	NSLog(@"Nightmare::_Bool displayedActionTextInFeed = %@", self.displayedActionTextInFeed ? @"true" : @"false");
	NSLog(@"Nightmare::_Bool doubleTap = %@", self.doubleTap ? @"true" : @"false");
	NSLog(@"Nightmare::NSString *encryptedSnapId = %@", self.encryptedSnapId);
	NSLog(@"Nightmare::_Bool expiredWhileStackNotEmpty = %@", self.expiredWhileStackNotEmpty ? @"true" : @"false");
	NSLog(@"Nightmare::_Bool failedAtLeastOnce = %@", self.failedAtLeastOnce ? @"true" : @"false");
	NSLog(@"Nightmare::NSDate *fideliusSendTimestamp = %@", self.fideliusSendTimestamp);
	NSLog(@"Nightmare::NSString *fideliusSnapIv = %@", self.fideliusSnapIv);
	NSLog(@"Nightmare::NSString *fideliusSnapKey = %@", self.fideliusSnapKey);
	NSLog(@"Nightmare::NSString *fideliusVersion = %@", self.fideliusVersion);
	NSLog(@"Nightmare::NSDate *finishViewingTimestamp = %@", self.finishViewingTimestamp);
	NSLog(@"Nightmare::long long groupId = %lld", self.groupId);
	NSLog(@"Nightmare::_Bool hideBroadcastTimer = %@", self.hideBroadcastTimer ? @"true" : @"false");
	NSLog(@"Nightmare::NSDictionary *inviteSnapMetadata = %@", self.inviteSnapMetadata);
	//NSLog(@"Nightmare::__weak id <SCInviteSnapSenderDelegate> inviteSnapSenderDelegate = %@", self.inviteSnapSenderDelegate);
	NSLog(@"Nightmare::NSArray *invitedRecipients = %@", self.invitedRecipients);
	NSLog(@"Nightmare::_Bool isInitialView = %@", self.isInitialView ? @"true" : @"false");
	NSLog(@"Nightmare::_Bool isLastViewedSnapInStack = %@", self.isLastViewedSnapInStack ? @"true" : @"false");
	NSLog(@"Nightmare::_Bool isPaidToReplay = %@", self.isPaidToReplay ? @"true" : @"false");
	NSLog(@"Nightmare::_Bool needsRetry = %@", self.needsRetry ? @"true" : @"false");
	NSLog(@"Nightmare::unsigned long long numAutomaticRetries = %llu", self.numAutomaticRetries);
	NSLog(@"Nightmare::unsigned long long numTimesCanBeReplayed = %llu", self.numTimesCanBeReplayed);
	NSLog(@"Nightmare::unsigned long long numTimesReloaded = %llu", self.numTimesReloaded);
	NSLog(@"Nightmare::_Bool pending = %@", self.pending ? @"true" : @"false");
	NSLog(@"Nightmare::AVPlayerItem *playerItem = %@", self.playerItem);
	NSLog(@"Nightmare::_Bool recentlyViewedAndHasNotLeftView = %@", self.recentlyViewedAndHasNotLeftView ? @"true" : @"false");
	NSLog(@"Nightmare::NSString* recipient = %@", self.recipient);
	NSLog(@"Nightmare::NSString *recipientOutAlpha = %@", self.recipientOutAlpha);
	NSLog(@"Nightmare::NSArray *recipients = %@", self.recipients);
	NSLog(@"Nightmare::long long replayAnimationStateChat = %lld", self.replayAnimationStateChat);
	NSLog(@"Nightmare::long long replayAnimationStateFeed = %lld", self.replayAnimationStateFeed);
	NSLog(@"Nightmare::_Bool replayed = %@", self.replayed ? @"true" : @"false");
	NSLog(@"Nightmare::long long screenshots = %lld", self.screenshots);
	NSLog(@"Nightmare::double secondsViewed = %f", self.secondsViewed);
	NSLog(@"Nightmare::NSString *sender = %@", self.sender);
	NSLog(@"Nightmare::NSString *senderOutAlpha = %@", self.senderOutAlpha);
	NSLog(@"Nightmare::NSDate *sentTimestamp = %@", self.sentTimestamp);
	NSLog(@"Nightmare::NSNumber *snapStreakCount = %@", self.snapStreakCount);
	NSLog(@"Nightmare::NSDate *snapStreakExpiryTime = %@", self.snapStreakExpiryTime);
	NSLog(@"Nightmare::SnapTrophyMetrics *snapTrophyMetrics = %@", self.snapTrophyMetrics);
	NSLog(@"Nightmare::NSString *stackId = %@", self.stackId);
	NSLog(@"Nightmare::long long state = %lld", self.state);
	NSLog(@"Nightmare::long long status = %lld", self.status);
	NSLog(@"Nightmare::double timeStartedOnScreen = %f", self.timeStartedOnScreen);
	NSLog(@"Nightmare::NSNumber *time_left = %@", self.time_left);
	NSLog(@"Nightmare::NSDate *timestamp = %@", self.timestamp);
	NSLog(@"Nightmare::long long viewSource = %lld", self.viewSource);
	
	NSLog(@"Nightmare::Ephemeral Media properties after send method");
	NSLog(@"Nightmare::NSString *_id = %@", self._id);
	NSLog(@"Nightmare::NSArray *allGeoFilterIds = %@", self.allGeoFilterIds);
	NSLog(@"Nightmare::_Bool cameraFrontFacing = %@", self.cameraFrontFacing ? @"true" : @"false");
	NSLog(@"Nightmare::NSString *captionText = %@", self.captionText);
	NSLog(@"Nightmare::NSString *clientId = %@", self.clientId);
	NSLog(@"Nightmare::SCSnapCommonLoggingParameters *commonLoggingParameters = %@", self.commonLoggingParameters);
	NSLog(@"Nightmare::EphemeralMedia *doublePostParent = %@", self.doublePostParent);
	NSLog(@"Nightmare::NSString *encryptedGeoData = %@", self.encryptedGeoData);
	NSLog(@"Nightmare::long long ephemeralMediaState = %lld", self.ephemeralMediaState);
	NSLog(@"Nightmare::NSMutableDictionary *eventLoggingParams = %@", self.eventLoggingParams);
	NSLog(@"Nightmare::NSDate *firstPostDate = %@", self.firstPostDate);
	NSLog(@"Nightmare::NSString *geoFilterId = %@", self.geoFilterId);
	NSLog(@"Nightmare::long long geoFilterImpressions = %lld", self.geoFilterImpressions);
	NSLog(@"Nightmare::NSString *iv = %@", self.iv);
	NSLog(@"Nightmare::NSString *key = %@", self.key);
	NSLog(@"Nightmare::CLLocation *location = %@", self.location);
	NSLog(@"Nightmare::Media *media = %@", self.media);
	NSLog(@"Nightmare::unsigned long long numberOfTimesReloaded = %llu", self.numberOfTimesReloaded);
	NSLog(@"Nightmare::long long orientation = %lld", self.orientation);
	NSLog(@"Nightmare::NSData *rawThumbnailData = %@", self.rawThumbnailData);
	NSLog(@"Nightmare::NSMutableDictionary *secretShareLoggingParams = %@", self.secretShareLoggingParams);
	NSLog(@"Nightmare::NSMutableDictionary *shareLoggingParams = %@", self.shareLoggingParams);
	NSLog(@"Nightmare::_Bool shouldIncludeLocationData = %@", self.shouldIncludeLocationData ? @"true" : @"false");
	NSLog(@"Nightmare::NSString *storyFilterId = %@", self.storyFilterId);
	NSLog(@"Nightmare::NSString *storyLensId = %@", self.storyLensId);
	NSLog(@"Nightmare::NSMutableArray *targets = %@", self.targets);
	NSLog(@"Nightmare::Media *thumbnailMedia = %@", self.thumbnailMedia);
	NSLog(@"Nightmare::double time = %f", self.time);
	NSLog(@"Nightmare::double timeLeft = %f", self.timeLeft);
	NSLog(@"Nightmare::double timeStartedViewing = %f", self.timeStartedViewing);
	NSLog(@"Nightmare::long long type = %lld", self.type);
	NSLog(@"Nightmare::NSArray *unlockablesVendorTags = %@", self.unlockablesVendorTags);
	NSLog(@"Nightmare::SnapVideoFilter *videoFilter = %@", self.videoFilter);
	NSLog(@"Nightmare::double videoTimeSoFar = %f", self.videoTimeSoFar);
	NSLog(@"Nightmare::NSDate *viewedTimestamp = %@", self.viewedTimestamp);
	NSLog(@"Nightmare::NSMutableArray *viewingTimestamps = %@", self.viewingTimestamps);
	
	//NSLog(@"Nightmare::Snap debugDescription= %@", self.debugDescription);
	%orig;
}
%end

%hook RequestTableViewController
// Sets the background of the 'Added Me' view controller to purple
- (id)backgroundColorForHeader {
	return snapPurpleColor;
}
// Sets the text color of 'Added Me' header to white
- (id)textColorForHeader:(id)arg1 {
	return [UIColor whiteColor];
}
// Makes the back arrow button for the 'Added Me' header white
- (id)imageForLeftButtonInState:(unsigned long long)arg1 {
	NSString *imagePath = [bundle pathForResource:@"Back_Button@2x" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	return image;
}

- (void)viewWillAppear:(_Bool)arg1 {
	%orig();
	// Sets the background color behind the 'Added Me' cells to dark
	self.tableView.backgroundColor = darkPurpleColor;
	
	// Sets the color of the bar under the 'Added Me' header to light
	self.header.bottomBorderedView.borderColor = lightPurpleColor;
}

%end

%hook SCTabBarView
// Gets rid of white boxes around the navigation buttons at the bottom
- (id)initWithFrame:(struct CGRect)arg1 userSession:(id)arg2 {
	self = %orig();
	if(self){
		self.backgroundView.hidden = true;
	}
	return self;
}
%end

%hook SendViewController
// Background color for the header set to snap blue
- (id)backgroundColorForHeader {
	return snapBlueColor;
}
// Text color for header to white 'Send to...'
- (id)textColorForHeader:(id)arg1 {
	return [UIColor whiteColor];
}

// Sets background of stories view controller to dark
- (void)viewDidAppear:(_Bool)arg1 {
	%orig;
	self.view.backgroundColor = darkBlueColor;
}

// Makes the back arrow button for the send header white
- (id)imageForLeftButtonInState:(unsigned long long)arg1 {
	NSString *imagePath = [bundle pathForResource:@"Back_Button@2x" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	return image;
}

// Makes the Add Friend button for the send header white
- (id)imageForRightButtonInState:(unsigned long long)arg1 {
	NSString *imagePath = [bundle pathForResource:@"Add_Friend_Button@2x" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	return image;
}

- (void)viewWillAppear:(_Bool)arg1 {
	%orig();
	// Sets the color of the bar under the 'Send To...' header to light
	SCHeader *header = MSHookIvar<SCHeader *>(self, "_header");
	header.bottomBorderedView.borderColor = lightBlueColor;
	// Sets the color of the search bar in 'Send To...' to dark
	self.selectRecipientsView.searchBar.backgroundColor = darkBlueColor;
}

- (void)didPressSend {
	if([prefs[@"kRememberCaptionEnabled"] boolValue]) {
		NSLog(@"Nightmare::didPressSend starting");
		//NSLog(@"Nightmare::didPressSend receives the caption as = %@", caption);
		// Grabs name of person to whom you're sending the snap
		NSArray *recipients = self.sendConfirmationView.recipients; // Array of 'Friend' objects
		for (Friend* recipient in recipients) {
			NSString *username = recipient.atomicName;
			//NSLog(@"Nightmare::recipient of SendViewController = %@", username);
			// Checks to make sure caption is NSString
			if ([caption isKindOfClass:[NSString class]]) {
				[captions setObject:caption forKey:username];
			} else {
				NSString *classType = [NSString stringWithFormat:@"%@", [caption class]];
				NSLog(@"Nightmare::caption classType = %@", classType);
				NSLog(@"Nightmare::caption contents = %@", [caption description]);
				[captions setObject:@"[Error] Something went wrong in saving the caption :(" forKey:username];
			}
		}
		[captions writeToFile:captionsPath atomically:YES];
		//NSLog(@"Nightmare::Dictionary = %@", captions);
		NSLog(@"Nightmare::didPressSend ending");
	}
	%orig();
}

%end

%hook SCHeader
//self.bottomBorderedView.borderColor = lightPurpleColor;
- (id)initWithBottomBorder {
	self = %orig();
	if(self){
		self.bottomBorderedView.borderColor = lightPurpleColor;
	}
	return self;
}

- (void)leftButtonPressed {
	// Add action to this later
	%orig();
}
%end

// When you click on 'My Friends' after swiping down on the main camera view (this is the view controller)
%hook SCMyContactsViewController
// Changes the header color to purple
- (id)backgroundColorForHeader {
	return snapPurpleColor;
}

// Sets the color of 'Add from Contacts' header inside of 'Add Friends' -> 'Add From Contacts'
- (id)textColorForHeader:(id)arg1 {
	return [UIColor whiteColor];
}

// Makes the camera button on the 'My Friends' header white
- (id)imageForLeftButtonInState:(unsigned long long)arg1 {
	NSString *imagePath = [bundle pathForResource:@"Back_Button@2x" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	return image;
}

- (id)tableView:(id)arg1 viewForHeaderInSection:(long long)arg2 {
	UIView* header = %orig();
	// Sets color behind 'BEST FRIENDS' and 'MY FRIENDS'
	header.backgroundColor = darkPurpleColor;
	return header;
}

- (void)viewWillAppear:(_Bool)arg1 {
	%orig();
	// Sets the background color behind the 'My Friends' cells to dark
	self.tableView.backgroundColor = darkPurpleColor;
	
	// Sets the color of the bar under the 'My Friends' header to light
	self.header.bottomBorderedView.borderColor = lightPurpleColor;
}
%end

// Think this is for when you search for contacts inside of 'My Friends'
%hook SCSearchFriendsSubViewController
- (id)tableView:(id)arg1 viewForHeaderInSection:(long long)arg2 {
	UIView* header = %orig();
	// Sets color behind 'SNAPCHATTERS IN MY CONTACTS'
	header.backgroundColor = darkPurpleColor;
	return header;
}

- (void)viewWillAppear:(_Bool)arg1 {
	%orig();
	// Sets the background color behind the 'My Friends' cells when searching for a name to dark
	self.searchResultsTableView.backgroundColor = darkPurpleColor;
}
%end

%hook SCFriendProfileCellTextView
// Sets the text color of the names to white in 'Add Friends' and 'My Friends'
- (id)_getMainLabelTextColor:(long long)arg1 {
	return [UIColor whiteColor];
}
%end

// Makes the keyboard dark, the same style as when you are entering your password in the app store
// Only does this for the search bar
%hook SCPlaceholderTextField
- (void)drawPlaceholderInRect:(struct CGRect)arg1 {
	%orig();
	self.keyboardAppearance = UIKeyboardAppearanceDark;
}
%end

%hook SCPlaceholderTextView
// Makes the keyboard dark, the same style as when you are entering your password in the app store
// Only does this for chat fields (even sending someone's story)
// When doing an individual chat it is lighter, NEED TO FIX THIS
- (id)initWithFrame:(struct CGRect)arg1 textContainer:(id)arg2 pasteMediaDelegate:(id)arg3 {
	self = %orig();
	if (self) {
		self.keyboardAppearance = UIKeyboardAppearanceDark;
	}
	return self;
}
%end

// 'Add Friends' view controller
%hook SCFindFriendMenuViewController
// Sets the header background color to purple
- (id)backgroundColorForHeader {
	return snapPurpleColor;
}
// Sets the 'Add Friends' text color to white
- (id)textColorForHeader:(id)arg1 {
	return [UIColor whiteColor];
}

// Makes the back button on the 'Add Friends' header white
- (id)imageForLeftButtonInState:(unsigned long long)arg1 {
	NSString *imagePath = [bundle pathForResource:@"Back_Button@2x" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	return image;
}
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
	UITableViewCell* cell = %orig();
	// Changes the background color of the cells 'Add by Username', 'Add from Contacts', etc.
	cell.backgroundColor = darkPurpleColor;
	return cell;
}

- (void)viewWillAppear:(_Bool)arg1 {
	%orig();
	// Sets the background color behind the 'Add Friends' cells to dark
	self.suggestedFriendTableView.backgroundColor = darkPurpleColor;
	
	// Sets the color of the bar under the 'Add Friends' header to light
	self.header.bottomBorderedView.borderColor = lightPurpleColor;
}
%end

%hook SCFindFriendMenuTableViewCell
- (void)setLabelText:(id)arg1 {
	%orig();
	// Changes the text color of the cells 'Add by Username', 'Add from Contacts', etc.
	self.labelView.textColor = [UIColor whiteColor];
}
// NEED TO CHANGE SEPARATOR COLOR
%end

// This is inside 'Add Friends', it is the controller shown when 'Add by Snapcode' is clicked
%hook SCAddFriendCameraRollPickerViewController
// Sets the header background color to purple
- (id)backgroundColorForHeader {
	return snapPurpleColor;
}
// Sets the 'Camera Roll' text color to white
- (id)textColorForHeader:(id)arg1 {
	return [UIColor whiteColor];
}

// Makes the back button on the 'Camera Roll' header white
- (id)imageForLeftButtonInState:(unsigned long long)arg1 {
	NSString *imagePath = [bundle pathForResource:@"Back_Button@2x" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	return image;
}

- (void)viewWillAppear:(_Bool)arg1 {
	%orig();
	// Sets the color of the bar under the 'Camera Roll' header to light (looks kind of dark though)
	self.header.bottomBorderedView.borderColor = lightPurpleColor;
}
%end

%hook SCAddFriendCameraRollPickerView
- (id)initWithFrame:(struct CGRect)arg1 {
	self = %orig();
	if(self){
		// Sets the color behind all of the photos in 'Camera Roll' which is a part of 'Add by Snapcode' to dark
		self.collectionView.backgroundColor = darkPurpleColor;
	}
	return self;
}
%end

%hook SCAddFriendCameraRollHeaderView
- (id)initWithFrame:(struct CGRect)arg1 {
	self = %orig();
	UILabel *textLabel = MSHookIvar<UILabel *>(self,"_textLabel");
	if(self){
		// Sets the text color of the label 'Tap a photo with a Snapcode to...' to white
		textLabel.textColor = [UIColor whiteColor];
	}
	return self;
}
%end

%hook SCAddFriendViewController
// Sets the header background color to purple
- (id)backgroundColorForHeader {
	return snapPurpleColor;
}
// Sets the 'Add Username' header text color to white
- (id)textColorForHeader:(id)arg1 {
	return [UIColor whiteColor];
}

// Makes the back button on the 'Add Username' header white
- (id)imageForLeftButtonInState:(unsigned long long)arg1 {
	NSString *imagePath = [bundle pathForResource:@"Back_Button@2x" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	return image;
}

- (void)viewWillAppear:(_Bool)arg1 {
	%orig();
	// Sets initial background color of 'Add Username' viewcontroller to dark
	self.view.backgroundColor = darkPurpleColor;
}
%end

%hook AddFriendByNameCell
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 {
	self = %orig();
	UILabel *mainLabel = MSHookIvar<UILabel *>(self, "_mainLabel");
	if (self) {
		// Sets the color of the cell of a new person when searching for a name in the 'Send To...' view OR SCSelectRecipientsView
		self.contentView.backgroundColor = darkBlueColor;
		// Sets the text color of said cell to white
		mainLabel.textColor = [UIColor whiteColor];
		// Sets the bottom separator bar to light
		self.bottomBorder.backgroundColor = lightBlueColor;
	}
	return self;
}
%end

%hook SCStartChatViewController
// Makes the back button on the Chat with... header white
- (id)imageForRightButtonInState:(unsigned long long)arg1 {
	NSString *imagePath = [bundle pathForResource:@"Forward_Button@2x" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	return image;
}
// Sets the color of the header behind 'Chat with...'
- (id)backgroundColorForHeader {
	return snapBlueColor;
}
// Sets the 'Chat with...' text to white
- (id)textColorForHeader:(id)arg1 {
	return [UIColor whiteColor];
}

- (void)viewWillAppear:(_Bool)arg1 {
	%orig();
	// Sets the color of the bar under the 'Chat with...' header to light
	SCHeader *header = MSHookIvar<SCHeader *>(self, "_header");
	header.bottomBorderedView.borderColor = lightBlueColor;
	// Sets the color of the search bar in 'Chat with...' to dark
	self.selectRecipientVC.searchBar.backgroundColor = darkBlueColor;
	// Sets the background color of the viewcontroller to dark
	self.view.backgroundColor = darkBlueColor;
	
	// Sets the text color of the label 'No results (poop emoji)' to white
	self.selectRecipientVC.noSearchResultsLabel.textColor = [UIColor whiteColor];
	// Removes the white background color of the label
	self.selectRecipientVC.noSearchResultsLabel.backgroundColor = [UIColor clearColor];
}
%end

%hook SCAppDelegate
-(BOOL)application:(UIApplication*)application
didFinishLaunchingWithOptions:(NSDictionary*)launchOptions{
	// Only need this when hiding stories
	//if([prefs[@"kHiddenStoriesEnabled"] boolValue]) {
		snapchatVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
		NSLog(@"Nightmare::Just launched application successfully running Snapchat version %@",snapchatVersion);
	
		CPDistributedMessagingCenter *c = [CPDistributedMessagingCenter centerNamed:@"com.andermoran.nightmared"];
		rocketbootstrap_distributedmessagingcenter_apply(c);
		[c sendMessageName:@"applicationLaunched" userInfo:nil];
	
		SendRequestToDaemon();
	//}
	
	return %orig();
}
%end

/* CAUSES NETWORK ERROR
// Logging the caption
%hook PreviewViewController
// When you directly reply to someone
- (void)didPressSend {
	if([prefs[@"kRememberCaptionEnabled"] boolValue]) {
		// Grabs name of person to whom you're sending the snap
		Friend *recipient = self.sendConfirmationView.recipients[0];
		NSString *username = recipient.atomicName;
		// Grabs caption when you send a reply to a snap
		SCCaptionDefaultTextView *defaultTextView = self.captionManager.caption;
		caption = [NSString stringWithFormat:@"%@", defaultTextView.textView.text];
		if ([caption isEqualToString:@""]) {
			caption = @"[no caption]";
		}
		//key = username, value = caption
		//NSLog(@"Nightmare::captionsPath = %@", captionsPath);
		[captions setObject:caption forKey:username];
		[captions writeToFile:captionsPath atomically:YES];
		NSLog(@"Nightmare::Dictionary = %@", captions);
	}
	%orig();
}
// When sending a snap to someone from the main view controller, this is the send button that leads you to SendViewController
- (void)_sendWithSendToViewRequired:(_Bool)arg1 {
	if([prefs[@"kRememberCaptionEnabled"] boolValue]) {
		//NSLog(@"Nightmare::_sendWithSendToViewRequired starting");
		// Makes sure the caption is of type NSString
		if ([caption isKindOfClass:[NSString class]]) {
			// Grabs caption when you click the send button from the main view controller
			SCCaptionDefaultTextView *defaultTextView = self.captionManager.caption;
			caption = [NSString stringWithFormat:@"%@", defaultTextView.textView.text];
			if ([caption isEqualToString:@""]) {
				caption = @"[no caption]";
			}
			//NSLog(@"Nightmare::_sendWithSendToViewRequired sets caption to = %@", caption);
		}
		//NSLog(@"Nightmare::caption inside of PreviewViewController _sendWithSendToViewRequired = %@", caption);
		//NSLog(@"Nightmare::_sendWithSendToViewRequired ending");
	}
	%orig();
}
%end
*/

%hook PreviewViewController
// Enables the snapcraft feature when taking a normal snap
// Only shows up after you clicking drawing mode for a snap in your memories gallery. Haven't put in really any time to work around this :)
- (_Bool)_shouldShowSnapCraftButton {return true;}
%end

%hook MainViewController
- (void)viewDidLoad {
	%orig();
	[self.middleVC snapCraftButtonPressed]; // Running this twice toggles snapcraft on/off and initializes it allowing the button to be shown
	[self.middleVC snapCraftButtonPressed];
	controller = self.middleVC;
}
%end

%hook SCCameraOverlayView
%new 
- (void)toggleRealtimeSnapCraftButton:(id)sender {
	//[self.middleVC snapCraftButtonPressed]; // self.middleVC = class with no name
	[controller snapCraftButtonPressed];
}

%new
- (void)initRealtimeSnapCraftButton {
	/*UIButton *realtimeSnapCraftButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[realtimeSnapCraftButton addTarget:self 
			   action:@selector(toggleRealtimeSnapCraftButton:)
	 forControlEvents:UIControlEventTouchUpInside];
	[realtimeSnapCraftButton setTitle:@"Craft" forState:UIControlStateNormal];
	realtimeSnapCraftButton.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
	[self addSubview:realtimeSnapCraftButton];*/
	/*SCGrowingButton *realtimeSnapCraftButton = nil;
	[realtimeSnapCraftButton initWithFrame:CGRectMake(80.0, 210.0, 160.0, 40.0)];
	[realtimeSnapCraftButton drawRect:CGRectMake(80.0, 210.0, 160.0, 40.0)];
	[self addSubview:realtimeSnapCraftButton];
	realtimeSnapCraftButton.hidden = false;*/
	self.snapCraftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 50, 320, 430)];
	//realtimeSnapCraftButton.target = "SCDrawingButton";
	[self addSubview:self.snapCraftButton];
	//[realtimeSnapCraftButton release];
}
	
- (id)initWithFrame:(struct CGRect)arg1 delegate:(id)arg2 userSession:(id)arg3 {
	self = %orig();
	if (self) {
		[self initRealtimeSnapCraftButton];
	}
	return self;
}
%end

/*
%hook SCCaptionDefaultTextView
- (id)initWithState:(id)arg1 delegate:(id)arg2 isLagunaMedia:(_Bool)arg3 initialTransform:(struct CGAffineTransform)arg4 originalContentBounds:(struct CGRect)arg5 orientation:(long long)arg6 superviewBounds:(struct CGRect)arg7 superviewContentBounds:(struct CGRect)arg8 {
	self = %orig();
	if (self) {
		// Makes the keyboard dark when writing the caption for a snap
		self.textView.keyboardAppearance = UIKeyboardAppearanceDark;
	}
	return self;
}
%end
*/
%end

%group brushHooks

// Contents stored in brushHooks.txt (not using them now because conflict with Phantom)

%end

%group bypassHooks

//%hook User
//// Prevents you from being logged out
//- (void)forceLogoutUser { 
//	/* Don't force me out >:( */
//	
//	/*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"forceLogoutUser" 
//													message:@"" 
//													delegate:self 
//													cancelButtonTitle:@"Dismiss" 
//													otherButtonTitles:nil];
//	[alert show];*/
//}
//%end

%end

/* Probelmatic classes (cause a cannot connect error when hooking)
	" P.h"
	PreviewViewController.h
*/
// Ignore this
/*static const char * (*old__dyld_get_image_name)(uint32_t image_index);
static const char * new__dyld_get_image_name(uint32_t image_index)
{
	//NSLog(@"old__dyld_get_image_name: %s", old__dyld_get_image_name(image_index));
	return old__dyld_get_image_name(image_index);
}*/

%ctor {
	loadPreferences();
	// If disabled then do nothing :)
	if([prefs[@"kEnabled"] boolValue]) {
		// Ignore this
		/*MSHookFunction((void *)_dyld_get_image_name, (void *)&new__dyld_get_image_name, (void **)&old__dyld_get_image_name); */
		// Loads phantom first 
		dlopen("/Library/MobileSubstrate/DynamicLibraries/saladLite.dylib", RTLD_NOW);
		if (false) {
			%init(settingsHooks); // Disabled for now because " P.h" is problematic
		}
		%init(otherHooks);
		//%init(settingsHooks,B=objc_getClass(" P")); // Disabled for now
		if (false) {
			%init(brushHooks);
		}
		%init(bypassHooks);
		%init(memoriesHooks);
		%init(chatHooks);
		%init(storyHooks);
		%init(discoverHooks);
		%init(individualChatView);
	}
}
