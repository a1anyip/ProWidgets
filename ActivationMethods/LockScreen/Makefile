TWEAK_NAME = PWLockScreen
PWLockScreen_FILES = PWLockScreen.x
PWLockScreen_FRAMEWORKS = CoreFoundation Foundation UIKit CoreGraphics QuartzCore
PWLockScreen_LIBRARIES = prowidgets
PWLockScreen_CFLAGS = -I../../
PWLockScreen_LDFLAGS = -L../../$(THEOS_OBJ_DIR_NAME)

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"