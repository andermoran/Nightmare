THEOS = /opt/theos/
export SDKVERSION = 9.3
include $(THEOS)/makefiles/common.mk

ARCHS = armv7 arm64 

BUNDLE_NAME = Nightmare
Nightmare_FILES = NightmareListRootListController.m PFHeaderCell.mm
Nightmare_INSTALL_PATH = /Library/PreferenceBundles
Nightmare_FRAMEWORKS = UIKit
Nightmare_PRIVATE_FRAMEWORKS = Preferences AppSupport
Nightmare_LIBRARIES = colorpicker

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Nightmare.plist$(ECHO_END)
