#import "header.h"

@interface PWPrefURLInstallationInfoView : UIView {
	
	UIImageView *_iconView;
	UILabel *_nameLabel;
	UILabel *_authorLabel;
	UIView *_separator;
	UITextView *_descriptionTextView;
	UIButton *_confirmButton;
}

- (void)setIcon:(UIImage *)icon;
- (void)setName:(NSString *)name;
- (void)setAuthor:(NSString *)author;
- (void)setDescription:(NSString *)description;

@end