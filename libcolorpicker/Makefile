
GO_EASY_ON_ME = 1
ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest:6.0
THEOS = /opt/theos/

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libcolorpicker
libcolorpicker_FILES = libcolorpicker.mm UIColor+PFColor.m PFColorPicker.m PFColorTransparentView.m PFColorViewController.m PFColorCell.mm
libcolorpicker_FRAMEWORKS = UIKit CoreGraphics Foundation
libcolorpicker_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/library.mk