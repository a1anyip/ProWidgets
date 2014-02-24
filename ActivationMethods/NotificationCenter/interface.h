#import <objc/runtime.h>

@class PWButtonLayoutView;
@class SBControlCenterController, SBCCButtonLayoutView, SBControlCenterButton, SBUIControlCenterButton;

// PWNCButtonLayoutView
// SBCCButtonLayoutView
// SBControlCenterSectionView
@interface PWNCButtonLayoutView : UIView
{
	NSMutableArray* _buttons;
	float _interButtonPadding;
	UIEdgeInsets _contentEdgeInsets;
}

@property(assign, nonatomic) UIEdgeInsets contentEdgeInsets;
@property(assign, nonatomic) float interButtonPadding;

- (void)layoutSubviews;
- (id)buttons;
- (void)removeButton:(id)button;
- (void)addButton:(id)button;
- (void)dealloc;
- (id)initWithFrame:(CGRect)frame;

@end

@interface SBControlCenterController : NSObject

+ (instancetype)sharedInstance;
- (void)dismissAnimated:(BOOL)animated;

@end

@interface SBUIControlCenterButton : UIButton
{
    struct UIEdgeInsets _bgCapInsets;
    id _delegate;
    UIImage *_normalBGImage;
    UIImage *_selectedBGImage;
    UIImage *_sourceGlyphImage;
    UIImage *_normalGlyphImage;
    UIImage *_selectedGlyphImage;
    double _naturalHeight;
}

+ (UIEdgeInsets)visibleContentInsets;
+ (id)_buttonWithBGImage:(id)arg1 selectedBGImage:(id)arg2 glyphImage:(id)arg3 naturalHeight:(double)arg4;
+ (id)roundRectButtonWithGlyphImage:(id)arg1;
+ (id)circularButtonWithGlyphImage:(id)arg1;
+ (id)roundRectButton;
+ (id)circularButton;
+ (id)_roundRectBackgroundImageForState:(long long)arg1;
+ (id)_circleBackgroundImageForState:(long long)arg1;
+ (void)controlAppearanceDidChangeForState:(long long)arg1;
+ (void)initialize;
@property(nonatomic) double naturalHeight; // @synthesize naturalHeight=_naturalHeight;
@property(retain, nonatomic) UIImage *selectedGlyphImage; // @synthesize selectedGlyphImage=_selectedGlyphImage;
@property(retain, nonatomic) UIImage *normalGlyphImage; // @synthesize normalGlyphImage=_normalGlyphImage;
@property(retain, nonatomic) UIImage *sourceGlyphImage; // @synthesize sourceGlyphImage=_sourceGlyphImage;
@property(retain, nonatomic) UIImage *selectedBGImage; // @synthesize selectedBGImage=_selectedBGImage;
@property(retain, nonatomic) UIImage *normalBGImage; // @synthesize normalBGImage=_normalBGImage;
@property(nonatomic, assign) id delegate; // @synthesize delegate=_delegate;
- (void)controlConfigurationDidChangeForState:(long long)arg1;
- (void)controlAppearanceDidChangeForState:(long long)arg1;
- (void)setEnabled:(BOOL)arg1;
- (void)setHighlighted:(BOOL)arg1;
- (void)setSelected:(BOOL)arg1;
- (void)_updateSelected:(BOOL)arg1 highlighted:(BOOL)arg2;
- (BOOL)_drawingAsSelected;
- (void)_pressAction;
- (struct CGSize)visibleContentSize;
- (void)setBackgroundImage:(id)arg1;
- (void)_setBackgroundImage:(id)arg1 selectedBackgroundImage:(id)arg2 naturalHeight:(double)arg3;
- (void)_rebuildBackgroundImages;
- (void)setGlyphImage:(id)arg1 selectedGlyphImage:(id)arg2;
- (void)_rebuildGlyphImages;
- (void)_updateForStateChange;
- (void)setBackgroundImage:(id)arg1 forState:(unsigned long long)arg2;
- (void)setImage:(id)arg1 forState:(unsigned long long)arg2;
- (long long)_currentState;
- (struct CGSize)sizeThatFits:(struct CGSize)arg1;
- (void)drawRect:(CGRect)arg1;
- (BOOL)_shouldAnimatePropertyWithKey:(id)arg1;
- (void)dealloc;
- (id)initWithFrame:(CGRect)arg1;
- (id)initWithFrame:(CGRect)arg1 backgroundImage:(id)arg2 selectedBackgroundImage:(id)arg3 glyphImage:(id)arg4 naturalHeight:(double)arg5;

@end

// PWNCButton
// SBUIControlCenterButton
@interface PWNCButton : SBUIControlCenterButton

@property(copy, nonatomic) NSNumber* sortKey;
@property(copy, nonatomic) NSString* identifier;

@end

@protocol _SBUIWidgetHost <NSObject>
- (void)invalidatePreferredViewSize;
- (void)requestLaunchOfURL:(id)url;
- (void)requestPresentationOfViewController:(id)viewController presentationStyle:(int)style context:(id)context completion:(id)completion;
@end

@interface _SBUIWidgetViewController : UIViewController <_SBUIWidgetHost> {
    id<_SBUIWidgetHost> *_widgetHost;
    NSString *_widgetIdentifier;
    int _widgetIdiom;
    NSString *_widgetidentifier;
}
+ (id)_exportedInterface;
+ (id)_remoteViewControllerInterface;
- (void)__hostDidDismiss;
- (void)__hostDidPresent;
- (void)__hostWillDismiss;
- (void)__hostWillPresent;
- (void)__requestPreferredViewSizeWithReplyHandler:(id)arg1;
- (void)__setWidgetIdentifier:(id)arg1;
- (void)__setWidgetIdiom:(int)arg1;
- (void)dealloc;
- (void)hostDidDismiss;
- (void)hostDidPresent;
- (void)hostWillDismiss;
- (void)hostWillPresent;
- (void)invalidatePreferredViewSize;
- (CGSize)preferredViewSize;
- (void)requestLaunchOfURL:(id)arg1;
- (void)requestPresentationOfViewController:(id)arg1 presentationStyle:(int)arg2 context:(id)arg3 completion:(id)arg4;
- (void)setWidgetHost:(id<_SBUIWidgetHost>)arg1;
- (void)setWidgetIdentifier:(NSString *)arg1;
- (void)setWidgetIdiom:(int)arg1;
- (id)widgetHost;
- (id)widgetIdentifier;
- (int)widgetIdiom;
-(void)unloadView;
@end