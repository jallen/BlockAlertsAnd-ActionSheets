//
//  BlockActionSheet.h
//
//

#import <UIKit/UIKit.h>

/**
 * A simple block-enabled API wrapper on top of UIActionSheet.
 */
@interface BlockActionSheet : NSObject

@property (nonatomic, readonly, strong) UIView *view;
@property (nonatomic, readwrite) BOOL vignetteBackground;

+ (id)sheetWithTitle:(NSString *)title;

- (id)initWithTitle:(NSString *)title;

- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block;
- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block;
- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block;

- (void)setCancelButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block;
- (void)setDestructiveButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block;
- (void)addButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block;
- (void)addButtonWithTitle:(NSString *)title color:(UIColor *)color block:(void (^)())block;
- (void)addButtonWithTitle:(NSString *)title color:(UIColor *)color block:(void (^)())block atIndex:(NSInteger)index;
- (void)addView:(UIView *)view atIndex:(NSInteger)index;

- (void)showInView:(UIView *)passedView completion:(void (^)())completion;
- (void)showInView:(UIView *)passedView;

- (void)dismiss:(BOOL)animated;
- (void)dismiss:(BOOL)animated withCompletion:(void(^)())completion;

- (NSUInteger)buttonCount;

@end
