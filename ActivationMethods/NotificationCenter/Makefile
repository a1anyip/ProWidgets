BUNDLE_NAME = ProWidgets
ProWidgets_FILES = Controller.m View.m PWNCButton.x PWNCButtonLayoutView.x
ProWidgets_FRAMEWORKS = CoreFoundation Foundation UIKit CoreGraphics QuartzCore
ProWidgets_PRIVATE_FRAMEWORKS = SpringBoardUI SpringBoardUIServices
ProWidgets_LIBRARIES = substrate prowidgets
ProWidgets_INSTALL_PATH = /System/Library/WeeAppPlugins/
ProWidgets_CFLAGS = -I../../
ProWidgets_LDFLAGS = -L../../$(THEOS_OBJ_DIR_NAME)

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 backboardd"