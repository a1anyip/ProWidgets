PREF = PWPrefController.m
PREF += PWPrefView.m
PREF += PWPrefInfoViewController.m
PREF += PWPrefInfoView.m

PREF += PWPrefWidgets.m
PREF += PWPrefWidgetsView.m
PREF += PWPrefWidgetPreference.m

PREF += PWPrefThemes.m
PREF += PWPrefThemesView.m

PREF += PWPrefActivation.m
PREF += PWPrefActivationView.m
PREF += PWPrefActivationPreference.m

PREF += PWPrefConfiguration.m
PREF += PWPrefExperimentalSettings.m

PREF += PWPrefPageViewController.m
PREF += PWPrefListController.m

PREF += PWPrefURLInstallation.m
PREF += PWPrefURLInstallationRootController.m
PREF += PWPrefURLInstallationRootView.m

BUNDLE_NAME = ProWidgets
ProWidgets_FILES = $(PREF)
ProWidgets_INSTALL_PATH = /Library/PreferenceBundles
ProWidgets_FRAMEWORKS = UIKit CoreGraphics Accounts Social
ProWidgets_PRIVATE_FRAMEWORKS = Preferences
ProWidgets_LIBRARIES = prowidgets
ProWidgets_CFLAGS = -I../
ProWidgets_LDFLAGS = -L../$(THEOS_OBJ_DIR_NAME)

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ProWidgets.plist$(ECHO_END)
