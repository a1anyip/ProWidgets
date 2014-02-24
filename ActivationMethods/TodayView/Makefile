TWEAK_NAME = PWTodayView
PWTodayView_FILES = PWTodayView.x
PWTodayView_FRAMEWORKS = CoreFoundation Foundation UIKit
PWTodayView_LIBRARIES = prowidgets
PWTodayView_CFLAGS = -I../../
PWTodayView_LDFLAGS = -L../../$(THEOS_OBJ_DIR_NAME)

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"