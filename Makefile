ARCHS = armv7 arm64
THEOS_DEVICE_IP = localhost -p 2222
THEOS = /opt/theos/
export SDKVERSION=9.3
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Nightmare
Nightmare_FILES = Tweak.xm
Nightmare_FRAMEWORKS = UIKit Foundation CoreLocation CoreGraphics
Nightmare_PRIVATE_FRAMEWORKS = AppSupport
Nightmare_LIBRARIES = rocketbootstrap
Nightmare_CFLAGS = -DTHEOS -Wno-deprecated-declarations
include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = NightmareArt
NightmareArt_INSTALL_PATH = /Library/Application Support/Nightmare
include $(THEOS)/makefiles/bundle.mk

after-install::
	install.exec "killall -9 Snapchat; killall -9 Preferences"
SUBPROJECTS += nightmare
SUBPROJECTS += nightmared
SUBPROJECTS += friendlist
include $(THEOS_MAKE_PATH)/aggregate.mk