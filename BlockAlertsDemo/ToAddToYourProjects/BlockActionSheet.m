//
//  BlockActionSheet.m
//
//

#import "BlockActionSheet.h"
#import "BlockBackground.h"
#import "BlockUI.h"
#import "ColorButton.h"

@interface BlockActionSheet() {
	NSMutableArray *_blocks;
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
        _blocks = [[NSMutableArray alloc] init];
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
    return _blocks.count;
}

- (void)addButtonWithTitle:(NSString *)title color:(NSString*)color block:(void (^)())block atIndex:(NSInteger)index {
	UIColor *buttonColor;
	if ([color isEqualToString:@"red"]) {
		buttonColor = [UIColor redColor];
	} else if ([color isEqualToString:@"black"]) {
		buttonColor = [UIColor colorWithWhite:0.2	alpha:1.0];
	} else {
		buttonColor = [UIColor grayColor];
	}
	
	ColorButton *button = [[ColorButton alloc] initWithFrame:CGRectMake(kActionSheetBorder,
																																			_height,
																																			_view.bounds.size.width-kActionSheetBorder*2,
																																			kActionSheetButtonHeight)];
	button.color = buttonColor;
	button.titleLabel.font = buttonFont;
	[button setTitle:title forState:UIControlStateNormal];
	[button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	_height += kActionSheetButtonHeight + kActionSheetBorder;
	
	if (!block) {
		block = ^{};
	}
	
	if (index >= 0) {
		[_blocks insertObject:block atIndex:index];
		[_views insertObject:button atIndex:index];
	} else {
		[_blocks addObject:block];
		[_views addObject:button];
	}
}

- (void)addView:(UIView *)view atIndex:(NSInteger)index {
	view.frame = CGRectMake(kActionSheetBorder, _height, _view.bounds.size.width-kActionSheetBorder*2, view.frame.size.height);
	if (index >= 0) {
		[_blocks insertObject:[NSNull null] atIndex:index];
		[_views insertObject:view atIndex:index];
	} else {
		[_blocks addObject:[NSNull null]];
		[_views addObject:view];
	}
	
	_height += view.frame.size.height + kActionSheetBorder;
}

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title color:@"red" block:block atIndex:-1];
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title color:@"black" block:block atIndex:-1];
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block 
{
    [self addButtonWithTitle:title color:@"gray" block:block atIndex:-1];
}

- (void)setDestructiveButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block
{
    [self addButtonWithTitle:title color:@"red" block:block atIndex:index];
}

- (void)setCancelButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block
{
    [self addButtonWithTitle:title color:@"black" block:block atIndex:index];
}

- (void)addButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block 
{
    [self addButtonWithTitle:title color:@"gray" block:block atIndex:index];
}

- (void)showInView:(UIView *)passedView completion:(void (^)())completion {
	for (UIView *view in _views) {
		[_view addSubview:view];
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

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated 
{
	if (buttonIndex >= 0 && buttonIndex < [_blocks count])
	{
			id obj = [_blocks objectAtIndex: buttonIndex];
			if (![obj isEqual:[NSNull null]])
			{
					((void (^)())obj)();
			}
	}
  
	[self dismiss:animated];
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

#pragma mark - Action

- (void)buttonClicked:(id)sender
{
    /* Run the button's block */
    int buttonIndex = [_views indexOfObject:sender];
    [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

@end
