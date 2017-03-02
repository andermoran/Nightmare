THEOS = /opt/theos/
include $(THEOS)/makefiles/common.mk

TOOL_NAME = nightmared
nightmared_FILES = main.mm
nightmared_PRIVATE_FRAMEWORKS = AppSupport
nightmared_LIBRARIES = rocketbootstrap

nightmared_CODESIGN_FLAGS = -Sentitlements.xml

include $(THEOS_MAKE_PATH)/tool.mk