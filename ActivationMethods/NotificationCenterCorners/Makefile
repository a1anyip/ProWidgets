TWEAK_NAME = PWNCCorners
PWNCCorners_FILES = PWNCCorners.x
PWNCCorners_FRAMEWORKS = CoreFoundation Foundation UIKit CoreGraphics QuartzCore
PWNCCorners_LIBRARIES = prowidgets
PWNCCorners_CFLAGS = -I../../
PWNCCorners_LDFLAGS = -L../../$(THEOS_OBJ_DIR_NAME)

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"