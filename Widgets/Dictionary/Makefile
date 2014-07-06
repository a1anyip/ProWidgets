BUNDLE_NAME = Dictionary
Dictionary_FILES = Dictionary.m Main.m Result.m
Dictionary_INSTALL_PATH = /Library/ProWidgets/Widgets/
Dictionary_FRAMEWORKS = UIKit CoreGraphics QuartzCore AVFoundation
Dictionary_LIBRARIES = prowidgets
Dictionary_CFLAGS = -I../../
Dictionary_LDFLAGS = -L../../$(THEOS_OBJ_DIR_NAME)
Dictionary_BUNDLE_EXTENSION = widget

SUBPROJECTS = preference Substrate

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/aggregate.mk