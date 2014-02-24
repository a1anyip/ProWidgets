TWEAK_NAME = ProWidgets
ProWidgets_FILES = PWBootstrap.x
ProWidgets_FRAMEWORKS = CoreFoundation Foundation UIKit
ProWidgets_LIBRARIES = prowidgets
ProWidgets_CFLAGS = -I../
ProWidgets_LDFLAGS = -L../$(THEOS_OBJ_DIR_NAME)

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"