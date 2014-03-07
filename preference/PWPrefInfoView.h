#import "header.h"

typedef enum {
	
	PWPrefInfoViewConfirmButtonTypeNormal,
	PWPrefInfoViewConfirmButtonTypeWarning,
	PWPrefInfoViewConfirmButtonTypeDisabled
	
} PWPrefInfoViewConfirmButtonType;

@interface PWPrefInfoView : UIView {
	
	UIImageView *_iconView;
	UILabel *_nameLabel;
	UILabel *_authorLabel;
	UIView *_separator;
	UITextView *_descriptionTextView;
	UIButton *_confirmButton;
	id _confirmButtonTarget;
	SEL _confirmButtonAction;
	NSDictionary *_confirmButtonInfo;
}

- (void)setIcon:(UIImage *)icon;
- (void)setName:(NSString *)name;
- (void)setAuthor:(NSString *)author;
- (void)setDescription:(NSString *)description;
- (void)setConfirmButtonType:(PWPrefInfoViewConfirmButtonType)type;
- (void)setConfirmButtonTitle:(NSString *)title;
- (void)setConfirmButtonTarget:(id)target action:(SEL)action;
- (void)setConfirmButtonInfo:(NSDictionary *)info;

@end