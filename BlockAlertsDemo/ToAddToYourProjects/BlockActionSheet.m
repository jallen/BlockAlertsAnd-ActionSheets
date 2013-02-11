//
//  BlockActionSheet.m
//
//

#import "BlockActionSheet.h"
#import "BlockBackground.h"
#import "BlockUI.h"
#import "ColorButton.h"

@interface BlockActionSheet() {
	NSMutableArray *_views;
	CGFloat _height;
}

@end

@implementation BlockActionSheet

@synthesize view = _view;
@synthesize vignetteBackground = _vignetteBackground;

static UIImage *background = nil;
static UIFont *titleFont = nil;
static UIFont *buttonFont = nil;

#pragma mark - init

+ (void)initialize
{
    if (self == [BlockActionSheet class])
    {
        background = [UIImage imageNamed:kActionSheetBackground];
        background = [background stretchableImageWithLeftCapWidth:0 topCapHeight:kActionSheetBackgroundCapHeight];
        titleFont = kActionSheetTitleFont;
        buttonFont = kActionSheetButtonFont;
    }
}

+ (id)sheetWithTitle:(NSString *)title
{
    return [[BlockActionSheet alloc] initWithTitle:title];
}

- (id)initWithTitle:(NSString *)title 
{
    if ((self = [super init]))
    {
        UIWindow *parentView = [BlockBackground sharedInstance];
        CGRect frame = parentView.bounds;
        _view = [[UIView alloc] initWithFrame:frame];
				_views = [[NSMutableArray alloc] init];
        _height = kActionSheetTopMargin;

        if (title)
        {
            CGSize size = [title sizeWithFont:titleFont
                            constrainedToSize:CGSizeMake(frame.size.width-kActionSheetBorder*2, 1000)
                                lineBreakMode:UILineBreakModeWordWrap];
            
            UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(kActionSheetBorder, _height, frame.size.width-kActionSheetBorder*2, size.height)];
            labelView.font = titleFont;
            labelView.numberOfLines = 0;
            labelView.lineBreakMode = UILineBreakModeWordWrap;
            labelView.textColor = kActionSheetTitleTextColor;
            labelView.backgroundColor = [UIColor clearColor];
            labelView.textAlignment = UITextAlignmentCenter;
            labelView.shadowColor = kActionSheetTitleShadowColor;
            labelView.shadowOffset = kActionSheetTitleShadowOffset;
            labelView.text = title;
            [_view addSubview:labelView];
            
            _height += size.height + 5;
        }
        _vignetteBackground = NO;
    }
    
    return self;
}

- (NSUInteger)buttonCount
{
    return _views.count;
}

- (void)addButtonWithTitle:(NSString *)title color:(UIColor *)color block:(void (^)())block {
	[self addButtonWithTitle:title color:color block:block atIndex:-1];
}

- (void)addButtonWithTitle:(NSString *)title color:(UIColor *)color block:(void (^)())block atIndex:(NSInteger)index {	
	ColorButton *button = [[ColorButton alloc] initWithFrame:CGRectMake(0,
																																			0,
																																			_view.bounds.size.width-kActionSheetBorder*2,
																																			kActionSheetButtonHeight)];
	button.color = color;
	button.titleLabel.font = buttonFont;
	[button setTitle:title forState:UIControlStateNormal];
	button.actionBlock = ^{
		if (block) {
			block();
		}
		[self dismiss:YES];
	};
	
	[self addView:button atIndex:index];
}

- (void)addView:(UIView *)view atIndex:(NSInteger)index {
	view.frame = CGRectMake(0,
													0,
													_view.bounds.size.width-kActionSheetBorder*2,
													view.frame.size.height);
	if (index >= 0 && index < _views.count) {
		NSMutableArray *views = [_views objectAtIndex:index];
		if (!views) {
			views = [[NSMutableArray alloc] init];
			[_views insertObject:views atIndex:index];
		}
		[views addObject:view];
	} else {
		NSMutableArray *views = [[NSMutableArray alloc] init];
		[views addObject:view];
		[_views addObject:views];
	}
}

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block
{
	[self addButtonWithTitle:title color:[UIColor redColor] block:block atIndex:-1];
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title color:[UIColor colorWithWhite:0.2	alpha:1.0] block:block atIndex:-1];
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block 
{
    [self addButtonWithTitle:title color:[UIColor grayColor] block:block atIndex:-1];
}

- (void)setDestructiveButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block
{
    [self addButtonWithTitle:title color:[UIColor redColor] block:block atIndex:index];
}

- (void)setCancelButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block
{
    [self addButtonWithTitle:title color:[UIColor colorWithWhite:0.2	alpha:1.0] block:block atIndex:index];
}

- (void)addButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block 
{
    [self addButtonWithTitle:title color:[UIColor grayColor] block:block atIndex:index];
}

- (void)showInView:(UIView *)passedView completion:(void (^)())completion {
	CGFloat maxHeight;
	CGFloat viewWidth;
	for (NSArray *views in _views) {
		maxHeight = 0.f;
		for (int i = 0; i < views.count; i++) {
			UIView *view = views[i];
			viewWidth = ((_view.bounds.size.width-kActionSheetBorder*2) - kActionSheetBorder * (views.count - 1)) / views.count;
			view.frame = CGRectMake(kActionSheetBorder + ((viewWidth + kActionSheetBorder) * i),
															_height,
															viewWidth,
															view.frame.size.height);
			[_view addSubview:view];
			
			maxHeight = MAX(maxHeight, view.frame.size.height);
		}
		_height += maxHeight + kActionSheetBorder;
	}
	
	UIImageView *modalBackground = [[UIImageView alloc] initWithFrame:_view.bounds];
	modalBackground.image = background;
	modalBackground.contentMode = UIViewContentModeScaleToFill;
	[_view insertSubview:modalBackground atIndex:0];
	
	[BlockBackground sharedInstance].vignetteBackground = _vignetteBackground;
	[[BlockBackground sharedInstance] addToMainWindow:_view];
	CGRect frame = _view.frame;
	frame.origin.y = [BlockBackground sharedInstance].bounds.size.height;
	frame.size.height = _height + kActionSheetBounce;
	_view.frame = frame;
	
	__block CGPoint center = _view.center;
	center.y -= _height + kActionSheetBounce;
	
	[UIView animateWithDuration:0.4
												delay:0.0
											options:UIViewAnimationCurveEaseOut
									 animations:^{
										 [BlockBackground sharedInstance].alpha = 1.0f;
										 _view.center = center;
									 } completion:^(BOOL finished) {
										 [UIView animateWithDuration:0.1
																					 delay:0.0
																				 options:UIViewAnimationOptionAllowUserInteraction
																			animations:^{
																				center.y += kActionSheetBounce;
																				_view.center = center;
																			} completion:^(BOOL finished) {
																				if (completion) {
																					completion();
																				}
																			}];
									 }];
}

- (void)showInView:(UIView *)passedView {
	[self showInView:passedView completion:nil];
}

- (void)dismiss:(BOOL)animated {
	if (animated) {
		CGPoint center = _view.center;
		center.y += _view.bounds.size.height;
		[UIView animateWithDuration:0.4
													delay:0.0
												options:UIViewAnimationCurveEaseIn
										 animations:^{
											 _view.center = center;
											 [[BlockBackground sharedInstance] reduceAlphaIfEmpty];
										 } completion:^(BOOL finished) {
											 [[BlockBackground sharedInstance] removeView:_view];
											 _view = nil;
										 }];
	} else {
		[[BlockBackground sharedInstance] removeView:_view];
		_view = nil;
	}
}

@end
