@class SBNotificationCenterController;
@class SBTodayWidgetAndTomorrowSectionHeaderView, SBBulletinViewController, SBBBSectionInfo;

@interface SBWallpaperController : NSObject

+ (id)sharedInstance;
- (CGColorRef)homescreenLightForegroundBlurColor;

@end

@interface SBWallpaperEffectView : UIView

+ (UIImage *)imageInRect:(CGRect)rect forVariant:(int)variant withStyle:(int)style zoomFactor:(float)factor mask:(id)mask masksBlur:(BOOL)blur masksTint:(BOOL)tint;

- (instancetype)initWithWallpaperVariant:(int)wallpaperVariant;
- (void)setStyle:(int)style;
- (void)setMaskImage:(id)image masksBlur:(BOOL)blur masksTint:(BOOL)tint;

@end

@interface _SBFVibrantSettings : NSObject

+ (id)vibrantSettingsWithReferenceColor:(id)arg1 legibilitySettings:(id)arg2;

- (id)lightTintViewWithFrame:(struct CGRect)arg1;
- (id)darkTintViewWithFrame:(struct CGRect)arg1;
- (id)colorCompositingViewWithFrame:(struct CGRect)arg1;

@end

@interface _UILegibilitySettingsProvider : NSObject

+ (int)styleForContentColor:(id)arg1;

@end

@interface SBNotificationCenterController : NSObject

+ (id)sharedInstance;
- (void)dismissAnimated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated completion:(id)completion;

@end

@interface SBTodayWidgetAndTomorrowSectionHeaderView : UITableViewHeaderFooterView

- (UITableView *)tableView;
- (void)updateVisibility;
- (void)_pw_pressed;

@end

@interface SBBulletinViewController : UIViewController

@end

@interface SBBBSectionInfo : NSObject

- (NSString *)identifier;

@end

@interface UITableView ()

- (NSInteger)_sectionForHeaderView:(id)headerView;

@end