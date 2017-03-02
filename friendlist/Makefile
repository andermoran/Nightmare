THEOS = /opt/theos/
include $(THEOS)/makefiles/common.mk

ARCHS = armv7 arm64 

BUNDLE_NAME = FriendList
FriendList_FILES = FriendTableDataSource.m FriendListController.m 
FriendList_INSTALL_PATH = /System/Library/PreferenceBundles
FriendList_FRAMEWORKS = UIKit
FriendList_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
