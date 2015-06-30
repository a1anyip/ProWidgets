BUNDLE_NAME = GoogleAuthenticator
GoogleAuthenticator_FILES = Authenticator.m ViewController.m Theme.m Cell.m
GoogleAuthenticator_INSTALL_PATH = /Library/ProWidgets/Widgets/
GoogleAuthenticator_FRAMEWORKS = UIKit CoreGraphics QuartzCore
GoogleAuthenticator_LIBRARIES = prowidgets objcipc
GoogleAuthenticator_CFLAGS = -I../../
GoogleAuthenticator_LDFLAGS = -L../../$(THEOS_OBJ_DIR_NAME)
GoogleAuthenticator_BUNDLE_EXTENSION = widget

SUBPROJECTS = AuthenticatorSubstrate

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/aggregate.mk