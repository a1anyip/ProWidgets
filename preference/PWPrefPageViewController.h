#import "header.h"

@interface PWPrefPageViewController : PSViewController<UIAlertViewDelegate> {
	
}

- (Class)viewClass;
- (NSString *)navigationTitle;
- (BOOL)requiresEditBtn;
- (PWPrefURLInstallationType)URLInstallationType;

- (void)toggleEditMode;

- (void)promptURLInstallation;
- (void)proceedURLInstallation:(NSString *)url;

- (void)uninstallPackage:(NSDictionary *)info completionHandler:(void(^)(void))completionHandler;

@end