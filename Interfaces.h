#import <CoreFoundation/CoreFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/objc-runtime.h>
#import <math.h>
//#import <HueSDK_iOS/HueSDK.h>
#import <math.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>

#define kBundlePath @"/Library/Application Support/Nightmare/NightmareArt.bundle"

typedef id CDUnknownBlockType;

@interface AVCameraViewController : UIViewController
- (void)snapCraftButtonPressed;
@end

@protocol SwipeView <NSObject>
@end

@interface SCTPresenceBarVC : UIViewController
@end

@interface SOJUUpdatesResponseBuilder : NSObject
@end

@interface SCCaption : NSObject
@end

@interface SCCaptionDefaultTextView : NSObject
@property(retain, nonatomic) UITextView *textView;
@end

@interface SCCaptionManager : NSObject
@property(retain, nonatomic) id caption;
- (id)attributedText;
@end

@interface CPDistributedMessagingCenter : NSObject
+ (instancetype)centerNamed:(NSString *)name;
- (void)runServer;
- (void)runServerOnCurrentThread;
- (void)stopServer;
- (void)registerForMessageName:(NSString *)messageName target:(id)target selector:(SEL)selector;
- (BOOL)sendMessageName:(NSString *)messageName userInfo:(NSDictionary *)userInfo;
- (NSDictionary *)sendMessageAndReceiveReplyName:(NSString *)messageName userInfo:(NSDictionary *)userInfo;
- (NSDictionary *)sendMessageAndReceiveReplyName:(NSString *)messageName userInfo:(NSDictionary *)userInfo error:(NSError **)error;
@end

@interface SCAlertViewActionButton : UIButton
@end

@interface SCLoadingIndicatorView : UIView
@end

@interface SCColorPicker : UIImageView
@end

@interface SCExpandedButton : UIButton
@end

@protocol SCInviteSnapSenderDelegate <NSObject>
@end

@interface SCFeedHeader : UIView 
@end

@interface Media : NSObject
//@property(nonatomic) __weak id <BaseNoteMediaProcessingDelegate> baseNoteMediaProcessingDelegate; // @synthesize baseNoteMediaProcessingDelegate=_baseNoteMediaProcessingDelegate;
@property(retain, nonatomic) NSNumber *captionOrientation; // @synthesize captionOrientation=_captionOrientation;
@property(retain, nonatomic) NSNumber *captionScreenPosition; // @synthesize captionScreenPosition=_captionScreenPosition;
@property(retain, nonatomic) NSString *captionText; // @synthesize captionText=_captionText;
//@property(nonatomic) __weak id <MediaDataSource> dataSource; // @synthesize dataSource=_dataSource;
//@property(nonatomic) __weak id <MediaDelegate> delegate; // @synthesize delegate=_delegate;
//@property(retain, nonatomic) id <SCMediaDownloadUnarchiver> downloadUnarchiver; // @synthesize downloadUnarchiver=_downloadUnarchiver;
@property(nonatomic) _Bool finishedPlaying; // @synthesize finishedPlaying=_finishedPlaying;
//@property(nonatomic) __weak id <MediaImageProcessingDelegate> imageProcessingDelegate; // @synthesize imageProcessingDelegate=_imageProcessingDelegate;
@property(nonatomic) _Bool isLoading; // @synthesize isLoading=_isLoading;
@property(nonatomic) _Bool isThumbnail; // @synthesize isThumbnail=_isThumbnail;
@property(nonatomic) long long loadContext; // @synthesize loadContext=_loadContext;
@property(retain, nonatomic) NSData *mediaDataToUpload; // @synthesize mediaDataToUpload=_mediaDataToUpload;
@property(retain, nonatomic) NSData *overlayDataToUpload; // @synthesize overlayDataToUpload=_overlayDataToUpload;
@property(nonatomic) _Bool overlayPresent; // @synthesize overlayPresent=_overlayPresent;
@property(retain, nonatomic) AVPlayerItem *playerItem; // @synthesize playerItem=_playerItem;
//@property(retain, nonatomic) id <SCMediaUploadArchiver> uploadArchiver; // @synthesize uploadArchiver=_uploadArchiver;
//@property(nonatomic) __weak id <MediaUploadDelegate> uploadDelegate; // @synthesize uploadDelegate=_uploadDelegate;
//@property(retain, nonatomic) id <MediaUrl> uploadUrl; // @synthesize uploadUrl=_uploadUrl;
@property(retain, nonatomic) AVURLAsset *videoAsset; // @synthesize videoAsset=_videoAsset;
@end

@protocol SendSnapNavigationControllerDelegate <NSObject>
@end

@interface SnapVideoFilter : NSObject
@end

@interface SCSnapCommonLoggingParameters : NSObject
@end

@interface SCPlaceholderTextField : UITextField
@end

@interface SCFeedScoreboardView : UIView
@property(retain, nonatomic) UIView *snapchatLabel;
@end

@interface SCFeedComponentView : UIView {
	UIImageView *_feedIconView;
}
- (id)feedIconView;
@end

@interface SCSearchBar : UIView
@property(retain, nonatomic) SCPlaceholderTextField *inputTextField; // @synthesize inputTextField=_inputTextField;
@property(retain, nonatomic) UIView *bottomBorderView;
@property(retain, nonatomic) UIView *topBorderView;
@end

@interface SCFriendmojiView : UIView
@property(retain, nonatomic) UILabel *label;
@end

@interface SCBottomBorderedView : UIView
@property(retain, nonatomic) UIColor *borderColor;
@end

@interface SCHeader : UIView 
@property(retain, nonatomic) UILabel *headerLabel;
@property(retain, nonatomic) UIButton *leftButton;
@property(retain, nonatomic) SCBottomBorderedView *bottomBorderedView;
@property(retain, nonatomic) UIColor *borderColor;
- (void)leftButtonPressed;
@end

@interface SCTabBarView : UIView
@property(retain, nonatomic) UIView *backgroundView;
@end

@interface SCGradientView : UIView
@end

@interface SCChatTableViewCell : UITableViewCell
@property(retain, nonatomic) UIView *bodyView; // @synthesize bodyView=_bodyView;
@end

@interface SCFeedViewController : UIViewController
@property(retain, nonatomic) UILabel *emptyFeedListPlaceholder;
@property(retain, nonatomic) SCFeedHeader *header;
@property(retain, nonatomic) UITableView *tableView;
@end

@interface MainViewController : UIViewController
@property(retain, nonatomic) AVCameraViewController<SwipeView> *middleVC;
- (void)initSnapCraftButton;
@end

@interface SCTilesCollectionViewController : UIViewController
@property(retain, nonatomic) UICollectionView *collectionView;
@end

@interface SCStoriesViewController : UIViewController <UIViewControllerPreviewingDelegate>
- (void)didPullToRefresh;
@property(retain, nonatomic) SCHeader *header;
@property(retain, nonatomic) SCTilesCollectionViewController *featuredTilesController;
@property(retain, nonatomic) SCSearchBar *searchBar;
@property(retain, nonatomic) UITableView *tableView;
@property(copy, nonatomic) NSArray *filteredUserFriendStories;
@end

@interface SCChatMainViewController : UIViewController
@end

@interface SCMultiScrollTableView : UITableView
@end

@interface SCChatBaseTableView : SCMultiScrollTableView
@end

@interface SCChatInputViewGradientView : UIView
@end

@interface TTTAttributedLabel : UILabel
@end

@interface SCChatTextLabel : TTTAttributedLabel
@end

@interface SCPlaceholderTextView : UITextView
@end

@interface SCStoriesSelectableCell : UITableViewCell
@end

@interface StoriesCell : SCStoriesSelectableCell
@property(retain, nonatomic) UILabel *nameLabel;
@property(retain, nonatomic) UIButton *replySnapButton;
@property(retain, nonatomic) SCFriendmojiView *friendMojiView;
@property(retain, nonatomic) UILabel *subLabel;
@property(retain, nonatomic) UIView *bottomBorder;
@property(retain, nonatomic) SCExpandedButton *expandMyStoryButton;
@end

@interface SCFriendProfileCellView : UIView
@end

@interface SCFriendProfileCellTextViewV2 : UIView
@end

@interface SCAddFriendCellView : UIView
@property(retain, nonatomic) UILabel *nameLabel;
@property(retain, nonatomic) UILabel *subLabel;
@end

@interface SCStoriesViewHeader : UIView
@property(retain, nonatomic) UIView *leftLine; // @synthesize rightLine=_rightLine;
@end

@interface SCHorizontalScrollCell : UITableViewCell
@property(retain, nonatomic) UIView *topBorder; // @synthesize topBorder=_topBorder;
@property(retain, nonatomic) UIView *view; // @synthesize view=_view;
@end

@interface SCLeftSwipableViewController : UIViewController
@end

@interface RequestTableViewController : SCLeftSwipableViewController
@property(retain, nonatomic) UITableView *tableView;
@property(retain, nonatomic) SCHeader *header;
@end

@interface SCHeaderStatusView : UIView
@end

@interface SCMessageChatTableViewCell : SCChatTableViewCell
@property(retain, nonatomic) UIView *payloadView;
@end

@interface SCSnapChatTableViewCellV2 : SCMessageChatTableViewCell
@property(retain, nonatomic) SCChatTextLabel *chatLabel;
@end

@interface SCRightSwipeableViewController : UIViewController
@end

@interface SCChatViewHeader : NSObject
@property(retain, nonatomic) SCHeader *header;
@end

@interface SCBaseChatCellViewModel : NSObject
@end

@interface SCMessageChatViewModel : SCBaseChatCellViewModel
@end

@interface SCSavedChatNotificationView : UIView
@property(retain, nonatomic) UILabel *unsavedLabel;
@property(retain, nonatomic) UILabel *savedLabel;
@end

@interface SCBaseMediaCardView : UIView
@end

@interface SCSnapMediaCardView : SCBaseMediaCardView
@end

@interface SCStatusView : UIView
@property(readonly, nonatomic) TTTAttributedLabel *statusLabel;
@property(readonly, nonatomic) UIImageView *statusIconImageView;
@end

@interface SCSnapStatusView : SCStatusView
@end

@interface SCChatInputController : NSObject
@end

@interface SCSavableItemChatTableViewCell : SCMessageChatTableViewCell
@property(retain, nonatomic) SCSavedChatNotificationView *savedNotifView;
@end

@interface SCMediaChatTableViewCell : SCSavableItemChatTableViewCell
@property(retain, nonatomic) UIView *payloadView;
@end

@interface SCTextChatTableViewCellV2 : SCSavableItemChatTableViewCell
@property(retain, nonatomic) SCChatTextLabel *chatLabel;
@end

@interface SWTableViewCell : UITableViewCell
@end

@interface AddFriendCell : SWTableViewCell
@property(retain, nonatomic) UIButton *addFriendButton;
@end

@interface SCAddFriendButtonV2 : UIView
@property(retain, nonatomic) UILabel *buttonTitleLabel;
@end

@interface SCDrawingView : UIView
@end

@interface SCGrowingButton : UIView
- (void)drawRect:(CGRect)rect;
@end

@interface SCDrawingButton : SCGrowingButton
@property(retain, nonatomic) SCDrawingView *drawingView;
@property(retain, nonatomic) UIColor *color;
@end

@interface SCSingleStrokeDrawingView : UIView
@property(retain, nonatomic) UIColor *lineColor;
@property(nonatomic) double lineWidth;
@end

@interface SCSendConfirmationView : UIView
@property(copy, nonatomic) NSArray *recipients;
@end

@interface PreviewViewController : UIViewController
@property(retain, nonatomic) SCDrawingView *drawingView;
@property(retain, nonatomic) SCDrawingButton *drawingButton;
@property(retain, nonatomic) SCCaptionManager *captionManager;
@property(retain, nonatomic) SCSendConfirmationView *sendConfirmationView;
@property(retain, nonatomic) SCGrowingButton *shareButton;
@property(retain, nonatomic) SCGrowingButton *sendButton;
- (void)setupSnapCraft;
@end

@interface SCLongPressGestureRecognizer : UILongPressGestureRecognizer
@end

@interface SCDrawingStroke : NSObject
@property(readonly, nonatomic) double lineWidth;
@end

@interface SCBaseAlertView : UIView
@end

@interface SCAlertView : SCBaseAlertView
@end

@interface SCAlertContentItem : NSObject
@end

@interface SCAlertViewActionButtonController : NSObject
@property(retain, nonatomic) UIButton *actionButton; // @synthesize actionButton=_actionButton;
@property(readonly, copy, nonatomic) CDUnknownBlockType actionHandler; // @synthesize actionHandler=_actionHandler;
@property(readonly, nonatomic) unsigned long long style; // @synthesize style=_style;
@property(readonly, copy, nonatomic) NSString *title; // @synthesize title=_title; 
@end

@interface SVGToQuartz : NSObject
@end

@interface SOJUSendSnapRequest : NSObject
@property(readonly, copy, nonatomic) NSString *cameraFrontFacing; // @synthesize cameraFrontFacing=_cameraFrontFacing;
@property(readonly, copy, nonatomic) NSString *clientId; // @synthesize clientId=_clientId;
@property(readonly, copy, nonatomic) NSData *data; // @synthesize data=_data;
@property(readonly, copy) NSString *description;
@property(readonly, copy, nonatomic) NSString *encGeoData; // @synthesize encGeoData=_encGeoData;
@property(readonly, copy, nonatomic) NSDictionary *fideliusPackage; // @synthesize fideliusPackage=_fideliusPackage;
@property(readonly, copy, nonatomic) NSNumber *fideliusTimestamp; // @synthesize fideliusTimestamp=_fideliusTimestamp;
@property(readonly, copy, nonatomic) NSString *fideliusVersion; // @synthesize fideliusVersion=_fideliusVersion;
@property(readonly, copy, nonatomic) NSString *filterId; // @synthesize filterId=_filterId;
@property(readonly) unsigned long long hash;
@property(readonly, copy, nonatomic) NSArray *invitedRecipients; // @synthesize invitedRecipients=_invitedRecipients;
@property(readonly, copy, nonatomic) NSNumber *isEnc; // @synthesize isEnc=_isEnc;
@property(readonly, copy, nonatomic) NSString *iv; // @synthesize iv=_iv;
@property(readonly, copy, nonatomic) NSString *key; // @synthesize key=_key;
@property(readonly, copy, nonatomic) NSString *lensId; // @synthesize lensId=_lensId;
@property(readonly, copy, nonatomic) NSString *mediaId; // @synthesize mediaId=_mediaId;
@property(readonly, copy, nonatomic) NSNumber *orientation; // @synthesize orientation=_orientation;
@property(readonly, copy, nonatomic) NSArray *recipientIds; // @synthesize recipientIds=_recipientIds;
@property(readonly, copy, nonatomic) NSString *recipientOutAlpha; // @synthesize recipientOutAlpha=_recipientOutAlpha;
@property(readonly, copy, nonatomic) NSArray *recipients; // @synthesize recipients=_recipients;
@property(readonly, copy, nonatomic) NSString *reqToken; // @synthesize reqToken=_reqToken;
@property(readonly, copy, nonatomic) NSString *senderOutAlpha; // @synthesize senderOutAlpha=_senderOutAlpha;
@property(readonly, copy, nonatomic) NSNumber *time; // @synthesize time=_time;
@property(readonly, copy, nonatomic) NSString *timestamp; // @synthesize timestamp=_timestamp;
@property(readonly, copy, nonatomic) NSNumber *type; // @synthesize type=_type;
@property(readonly, copy, nonatomic) NSString *uploadUrl; // @synthesize uploadUrl=_uploadUrl;
@property(readonly, copy, nonatomic) NSString *username; // @synthesize username=_username;
@property(readonly, copy, nonatomic) NSString *zipped; // @synthesize zipped=_zipped;
@end

@interface EphemeralMedia : NSObject
@property(retain, nonatomic) NSString *_id; // @synthesize _id=__id;
@property(retain, nonatomic) NSArray *allGeoFilterIds; // @synthesize allGeoFilterIds=_allGeoFilterIds;
@property(nonatomic) _Bool cameraFrontFacing; // @synthesize cameraFrontFacing=_cameraFrontFacing;
@property(retain, nonatomic) NSString *captionText; // @synthesize captionText=_captionText;
@property(retain, nonatomic) NSString *clientId; // @synthesize clientId=_clientId;
@property(copy, nonatomic) SCSnapCommonLoggingParameters *commonLoggingParameters; // @synthesize commonLoggingParameters=_commonLoggingParameters;
@property(retain, nonatomic) EphemeralMedia *doublePostParent; // @synthesize doublePostParent=_doublePostParent;
@property(retain, nonatomic) NSString *encryptedGeoData; // @synthesize encryptedGeoData=_encryptedGeoData;
@property(nonatomic) long long ephemeralMediaState; // @synthesize ephemeralMediaState=_ephemeralMediaState;
@property(retain, nonatomic) NSMutableDictionary *eventLoggingParams; // @synthesize eventLoggingParams=_eventLoggingParams;
@property(retain, nonatomic) NSDate *firstPostDate; // @synthesize firstPostDate=_firstPostDate;
@property(retain, nonatomic) NSString *geoFilterId; // @synthesize geoFilterId=_geoFilterId;
@property(nonatomic) long long geoFilterImpressions; // @synthesize geoFilterImpressions=_geoFilterImpressions;
@property(retain, nonatomic) NSString *iv; // @synthesize iv=_iv;
@property(retain, nonatomic) NSString *key; // @synthesize key=_key;
@property(retain, nonatomic) CLLocation *location; // @synthesize location=_location;
@property(retain, nonatomic) Media *media; // @synthesize media=_media;
@property(nonatomic) unsigned long long numberOfTimesReloaded; // @synthesize numberOfTimesReloaded=_numberOfTimesReloaded;
@property(nonatomic) long long orientation; // @synthesize orientation=_orientation;
@property(copy, nonatomic) NSData *rawThumbnailData; // @synthesize rawThumbnailData=_rawThumbnailData;
@property(retain, nonatomic) NSMutableDictionary *secretShareLoggingParams; // @synthesize secretShareLoggingParams=_secretShareLoggingParams;
@property(retain, nonatomic) NSMutableDictionary *shareLoggingParams; // @synthesize shareLoggingParams=_shareLoggingParams;
@property(nonatomic) _Bool shouldIncludeLocationData; // @synthesize shouldIncludeLocationData=_shouldIncludeLocationData;
@property(retain, nonatomic) NSString *storyFilterId; // @synthesize storyFilterId=_storyFilterId;
@property(retain, nonatomic) NSString *storyLensId; // @synthesize storyLensId=_storyLensId;
@property(retain, nonatomic) NSMutableArray *targets; // @synthesize targets=_targets;
@property(retain, nonatomic) Media *thumbnailMedia; // @synthesize thumbnailMedia=_thumbnailMedia;
@property(nonatomic) double time; // @synthesize time=_time;
@property(nonatomic) double timeLeft; // @synthesize timeLeft=_timeLeft;
@property(nonatomic) double timeStartedViewing; // @synthesize timeStartedViewing=_timeStartedViewing;
@property(nonatomic) long long type; // @synthesize type=_type;
@property(retain, nonatomic) NSArray *unlockablesVendorTags; // @synthesize unlockablesVendorTags=_unlockablesVendorTags;
@property(retain, nonatomic) SnapVideoFilter *videoFilter; // @synthesize videoFilter=_videoFilter;
@property(nonatomic) double videoTimeSoFar; // @synthesize videoTimeSoFar=_videoTimeSoFar;
@property(retain, nonatomic) NSDate *viewedTimestamp; // @synthesize viewedTimestamp=_viewedTimestamp;
@property(retain, nonatomic) NSMutableArray *viewingTimestamps; // @synthesize viewingTimestamps=_viewingTimestamps;
@end

@interface TrophyMetricsContainer : NSObject
@end

@interface SnapTrophyMetrics : TrophyMetricsContainer
@end

@interface Snap : EphemeralMedia
@property(retain, nonatomic) NSString *broadcastActionText; // @synthesize broadcastActionText=_broadcastActionText;
@property(retain, nonatomic) NSURL *broadcastMediaUrl; // @synthesize broadcastMediaUrl=_broadcastMediaUrl;
@property(retain, nonatomic) NSString *broadcastSecondaryText; // @synthesize broadcastSecondaryText=_broadcastSecondaryText;
@property(nonatomic) _Bool broadcastSnap; // @synthesize broadcastSnap=_broadcastSnap;
@property(retain, nonatomic) NSURL *broadcastUrlToOpen; // @synthesize broadcastUrlToOpen=_broadcastUrlToOpen;
@property(nonatomic) _Bool clearedByRecipient; // @synthesize clearedByRecipient=_clearedByRecipient;
@property(nonatomic) _Bool clearedBySender; // @synthesize clearedBySender=_clearedBySender;
@property(nonatomic) double closedAt; // @synthesize closedAt=_closedAt;
@property(retain, nonatomic) NSString *correspondentId; // @synthesize correspondentId=_correspondentId;
@property(readonly, copy) NSString *description;
@property(retain, nonatomic) NSString *display; // @synthesize display=_display;
@property(nonatomic) _Bool displayedActionTextInFeed; // @synthesize displayedActionTextInFeed=_displayedActionTextInFeed;
@property(nonatomic) _Bool doubleTap; // @synthesize doubleTap=_doubleTap;
@property(copy, nonatomic) NSString *encryptedSnapId; // @synthesize encryptedSnapId=_encryptedSnapId;
@property(nonatomic) _Bool expiredWhileStackNotEmpty; // @synthesize expiredWhileStackNotEmpty=_expiredWhileStackNotEmpty;
@property(nonatomic) _Bool failedAtLeastOnce; // @synthesize failedAtLeastOnce=_failedAtLeastOnce;
@property(retain, nonatomic) NSDate *fideliusSendTimestamp; // @synthesize fideliusSendTimestamp=_fideliusSendTimestamp;
@property(retain, nonatomic) NSString *fideliusSnapIv; // @synthesize fideliusSnapIv=_fideliusSnapIv;
@property(retain, nonatomic) NSString *fideliusSnapKey; // @synthesize fideliusSnapKey=_fideliusSnapKey;
@property(retain, nonatomic) NSString *fideliusVersion; // @synthesize fideliusVersion=_fideliusVersion;
@property(retain, nonatomic) NSDate *finishViewingTimestamp; // @synthesize finishViewingTimestamp=_finishViewingTimestamp;
@property(nonatomic) long long groupId; // @synthesize groupId=_groupId;
@property(nonatomic) _Bool hideBroadcastTimer; // @synthesize hideBroadcastTimer=_hideBroadcastTimer;
@property(retain, nonatomic) NSDictionary *inviteSnapMetadata; // @synthesize inviteSnapMetadata=_inviteSnapMetadata;
@property(nonatomic) __weak id <SCInviteSnapSenderDelegate> inviteSnapSenderDelegate; // @synthesize inviteSnapSenderDelegate=_inviteSnapSenderDelegate;
@property(retain, nonatomic) NSArray *invitedRecipients; // @synthesize invitedRecipients=_invitedRecipients;
@property(nonatomic) _Bool isInitialView; // @synthesize isInitialView=_isInitialView;
@property(nonatomic) _Bool isLastViewedSnapInStack; // @synthesize isLastViewedSnapInStack=_isLastViewedSnapInStack;
@property(nonatomic) _Bool isPaidToReplay; // @synthesize isPaidToReplay=_isPaidToReplay;
@property(nonatomic) _Bool needsRetry; // @synthesize needsRetry=_needsRetry;
@property(nonatomic) unsigned long long numAutomaticRetries; // @synthesize numAutomaticRetries=_numAutomaticRetries;
@property(nonatomic) unsigned long long numTimesCanBeReplayed; // @synthesize numTimesCanBeReplayed=_numTimesCanBeReplayed;
@property(nonatomic) unsigned long long numTimesReloaded; // @synthesize numTimesReloaded=_numTimesReloaded;
@property(nonatomic) _Bool pending; // @synthesize pending=_pending;
@property(retain, nonatomic) AVPlayerItem *playerItem; // @synthesize playerItem=_playerItem;
@property(nonatomic) _Bool recentlyViewedAndHasNotLeftView; // @synthesize recentlyViewedAndHasNotLeftView=_recentlyViewedAndHasNotLeftView;
@property(retain, nonatomic) NSString *recipient; // @synthesize recipient=_recipient;
@property(retain, nonatomic) NSString *recipientOutAlpha; // @synthesize recipientOutAlpha=_recipientOutAlpha;
@property(retain, nonatomic) NSArray *recipients; // @synthesize recipients=_recipients;
@property(nonatomic) long long replayAnimationStateChat; // @synthesize replayAnimationStateChat=_replayAnimationStateChat;
@property(nonatomic) long long replayAnimationStateFeed; // @synthesize replayAnimationStateFeed=_replayAnimationStateFeed;
@property(nonatomic) _Bool replayed; // @synthesize replayed=_replayed;
@property(nonatomic) long long screenshots; // @synthesize screenshots=_screenshots;
@property(nonatomic) double secondsViewed; // @synthesize secondsViewed=_secondsViewed;
@property(retain, nonatomic) NSString *sender; // @synthesize sender=_sender;
@property(retain, nonatomic) NSString *senderOutAlpha; // @synthesize senderOutAlpha=_senderOutAlpha;
@property(retain, nonatomic) NSDate *sentTimestamp; // @synthesize sentTimestamp=_sentTimestamp;
@property(retain, nonatomic) NSNumber *snapStreakCount; // @synthesize snapStreakCount=_snapStreakCount;
@property(retain, nonatomic) NSDate *snapStreakExpiryTime; // @synthesize snapStreakExpiryTime=_snapStreakExpiryTime;
@property(retain, nonatomic) SnapTrophyMetrics *snapTrophyMetrics; // @synthesize snapTrophyMetrics=_snapTrophyMetrics;
@property(copy, nonatomic) NSString *stackId; // @synthesize stackId=_stackId;
@property(nonatomic) long long state; // @synthesize state=_state;
@property(nonatomic) long long status; // @synthesize status=_status;
@property(nonatomic) double timeStartedOnScreen; // @synthesize timeStartedOnScreen=_timeStartedOnScreen;
@property(retain, nonatomic) NSNumber *time_left; // @synthesize time_left=_time_left;
@property(retain, nonatomic) NSDate *timestamp; // @synthesize timestamp=_timestamp;
@property(nonatomic) long long viewSource; // @synthesize viewSource=_viewSource;
- (void)send;
@property(readonly, copy) NSString *debugDescription;
@end


@interface SCSnapPlayController : NSObject
@property(retain, nonatomic) Snap *visibleSnap;
@end

@interface SCSelectRecipientsView : UIView
@property(readonly, nonatomic) UITableView *tableView;
@property(retain, nonatomic) UILabel *createMischiefLabel;
@property(retain, nonatomic) SCSearchBar *searchBar;
@property(retain, nonatomic) UILabel *noSearchResultsLabel;
@end

@interface SendViewController : UIViewController
@property(retain, nonatomic) SCSelectRecipientsView *selectRecipientsView;
@property(retain, nonatomic) SCSendConfirmationView *sendConfirmationView;
@end

@interface SelectContactCell : UITableViewCell
@property(retain, nonatomic) UILabel *nameLabel;
@property(retain, nonatomic) UILabel *subNameLabel;
@end

@interface SCMiniProfileTextView
@end

@interface SCMiniProfileBaseView
@property(retain, nonatomic) UIView *card;
@end

@interface SCMiniProfileView : SCMiniProfileBaseView

@end

@interface Friend : NSObject
@property(copy, nonatomic) NSString *name;
@property(nonatomic) _Bool isVerified;
@property(copy, nonatomic) NSString *display;
@property(retain, nonatomic) NSString *kvoName;
@property(copy) NSString *atomicName;
@end

@interface SOJUFriend : NSObject
@property(readonly, copy, nonatomic) NSString *name;
@end

@interface FriendsTableIndex : UIView
@property(retain, nonatomic) UIView *background;
@property(retain, nonatomic) UIView *container;
@end

@interface SCStoryReplyMediaThumbnailView : UIView
@end

@interface SCBaseMediaThumbnailView : UIView
@property(retain, nonatomic) UIView *blockingOverlayView;
@end

@interface NavigationController : UINavigationController
@end

@interface SCCardPullToRefreshView : UIView
@end

@interface SCFeedTableViewCell : UITableViewCell
@end

@interface SCFeedSwipeableTableViewCell : SCFeedTableViewCell
@property(retain, nonatomic) SCFeedComponentView *feedComponentView;
@end

@interface SCFeedInteractionEventParser : NSObject
@end

@interface SCInteractionEvent : NSObject
@end

@interface SCFeedChatTableViewCell : SCFeedSwipeableTableViewCell
@end

@interface SCDiscoverViewController : UIViewController
@property(retain, nonatomic) SCHeader *header;
@end

@interface SCMiniProfileController : NSObject
@end

@interface SCFeedTableLoadingView : UIView
@property(retain, nonatomic) UILabel *label;
@end

@interface SCMiniProfileButtonView : UIView
@end

@interface SCStatusBarController : NSObject
@end

@interface SCFeedChatCellViewModel : NSObject
@end

@interface SCSingleIconViewBase : UIView
@property(retain, nonatomic) UIImageView *imageView;
@end

@interface SCInAppNotificationCard : UIView
@end

@interface SCInAppNotificationViewV2 : UIWindow
@end

@interface SCFeedItem : NSObject
@property(readonly, nonatomic) NSString *feedId;
@end

@interface SCGalleryHeaderBar : UIView
@end

@interface SCGalleryTabsSecretCollectionView : UICollectionView
@end

@interface SCGalleryTabCollectionView : SCGalleryTabsSecretCollectionView
@end

@interface SCFriendSearchViewController : SCLeftSwipableViewController
@end

@interface SCFindFriendMenuViewController : SCLeftSwipableViewController
@property(retain, nonatomic) SCHeader *header;
@property(retain, nonatomic) UITableView *suggestedFriendTableView;
@end

@interface GenericSettingsViewController : SCLeftSwipableViewController
@end

@interface MobileSettingsViewController : GenericSettingsViewController 
@end

@interface InformationSettingsViewController : GenericSettingsViewController
@end

@interface SecurityGhostViewController : GenericSettingsViewController
@end

@interface SCStackedChatTableViewCell : SCSavableItemChatTableViewCell
@end

@interface SettingsViewController : SCLeftSwipableViewController
@end

@interface MyProfileStoryCell : SCStoriesSelectableCell
@property(retain, nonatomic) UILabel *captionLabel;
@end

@interface SCGalleryTabCollectionViewFlowLayout : UICollectionViewFlowLayout
@end

@interface SCGalleryViewController : UIViewController
@end

@interface SCGalleryEntryBasedTabController : NSObject
@end

@interface SCGalleryTabBar : UIView 
@end

@interface SCGalleryTabBarItemCell : UICollectionViewCell
@property(nonatomic) double highlightLevel; // @synthesize highlightLevel=_highlightLevel;
@property(retain, nonatomic) UIColor *highlightedStateColor;
//@property(retain, nonatomic) SCGalleryTabBarItem *item; // @synthesize item=_item;
//@property(retain, nonatomic) SCGalleryTabBarItem *item; // @synthesize item=_item;
@property(retain, nonatomic) UIColor *normalStateColor;
@end

@interface SCGallerySnapsTabController : SCGalleryEntryBasedTabController
@end

@interface SCGalleryTabCollectionRoundedCornersOverlayView : UICollectionReusableView
@end

@interface SCGalleryTabCollectionTopRoundedCornersOverlayView : SCGalleryTabCollectionRoundedCornersOverlayView
@end

@interface SCGalleryTabCollectionBottomRoundedCornersOverlayView : SCGalleryTabCollectionRoundedCornersOverlayView
@end

@interface SCMyFriendsHeader : SCHeader
@end

@interface SCMyContactsViewController : SCLeftSwipableViewController
@property(retain, nonatomic) UITableView *tableView;
@property(retain, nonatomic) SCMyFriendsHeader *header;
@end

@interface SCFriendProfileCellTextView : UIView
@end

@interface SCFeedTableHeaderView : UIView
@end

@interface SCSWFriendProfileCell : SWTableViewCell
@end

@interface SCProfilePictureThumbnail : UIView
@property(retain, nonatomic) UIImageView *ghostBorderView;
@end

@interface SCSearchFriendsSubViewController : UIViewController
@property(retain, nonatomic) SCSearchBar *searchBarView;
@property(retain, nonatomic) UITableView *searchResultsTableView;
@end

@interface SCTransparentParentView : UIView
@end

@interface SCTextView : UIView
@end

@interface SCAddFriendViewController : SCLeftSwipableViewController
@end

@interface SCFindFriendMenuTableViewCell : UITableViewCell
@property(retain, nonatomic) UILabel *labelView;
@end

@interface SCAddFriendCameraRollPickerViewController : SCLeftSwipableViewController
@property(retain, nonatomic) SCHeader *header;
@end

@interface SCAddFriendCameraRollPickerView : UIView
@property(retain, nonatomic) UICollectionView *collectionView;
@end

@interface SCAddFriendCameraRollHeaderView : UICollectionReusableView
@end

@interface SCSettingsTableViewCell : UITableViewCell
@end

@interface AddFriendByNameCell : UITableViewCell
@property(retain, nonatomic) UIView *bottomBorder;
@end

@interface SCStartChatViewController : SCRightSwipeableViewController
@property(retain, nonatomic) SCSelectRecipientsView *selectRecipientVC;
@end

@interface SCManagedCapturer : NSObject
@end

@protocol SCFeedSnapActionCell <NSObject>
- (UIView *)feedIconView;
@end

@interface SCChatBaseViewController : UIViewController
@property(retain, nonatomic) UIView *tableContainerView;
@end

@interface SCChatViewControllerV2 : SCChatBaseViewController
@property(retain, nonatomic) UITableView *tableView;
- (void)showRecentCaption:(id)sender;
- (id)chatInputController;
- (id)chatInputControllerRecipient:(id)arg1;
@end

@interface SCSavableItemChatViewModel : SCMessageChatViewModel
@end

@interface SCTextChatViewModelV2 : SCSavableItemChatViewModel
@end

@interface SCChatTableViewPresenter : NSObject
@property(retain, nonatomic) SCChatBaseTableView *tableView;
@end

@interface SCChatTableViewDataSourceV2 : NSObject
@end

@interface SCBaseMessage : NSObject
@end

@interface SCBaseMediaMessage : SCBaseMessage
@end

@interface SCChatMediaMessage : SCBaseMediaMessage
@end

@interface SCStoryReplyMediaMessage : SCChatMediaMessage
@end

@interface SCStackedNoteChatTableViewCell : SCStackedChatTableViewCell
@end

@interface SCVideoNoteView : UIView
@end

@interface SCStackedCollectionViewCell : UICollectionViewCell
@end

@interface SCStackedNoteCollectionViewCell : SCStackedCollectionViewCell
@end

@interface SCStackedVideoNoteCollectionViewCell : SCStackedNoteCollectionViewCell
@end

@interface SCStackedStickerChatTableViewCell : SCStackedChatTableViewCell
@end

@interface SCStackedStickerCollectionViewCell : SCStackedCollectionViewCell
@end

@interface SCStackedChatTableViewCollectionView : UICollectionView
@end

@interface SCStoryReplyMediaChatViewModel : SCSavableItemChatViewModel
@end

@interface P : SCLeftSwipableViewController
@end

@interface SCMissCallChatTableViewCell : SCMessageChatTableViewCell
@end

@interface FriendStories : NSObject
@property(nonatomic) long long unviewedBatchState;
@end

@interface FriendStoriesCollection : NSObject
@property(retain, nonatomic) NSMutableDictionary *friendsStories;
@end

@interface Friends : NSObject
- (id)getAllFriends;
@end

@interface User : NSObject
@property(retain, nonatomic) Friends *friends;
@end

@interface Manager : NSObject
+ (id)shared;
- (void)fetchUpdatesAndStories;
- (void)logoutForced:(_Bool)arg1;
@property(retain, nonatomic) User *user; 
@end

@interface SCCameraOverlayView : UIView
- (void)initRealtimeSnapCraftButton;
- (void)toggleRealtimeSnapCraftButton:(id)sender;
@property(retain, nonatomic) UIButton *snapCraftButton;
@end

// MY OWN CLASS
@interface SCRealtimeSnapCraftButton : SCGrowingButton
@end