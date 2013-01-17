//
//  ColorButton.h
//  InstaQuote
//
//  Created by Jared Allen on 1/16/13.
//  Copyright (c) 2013 Peapod Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorButton : UIButton

@property (nonatomic, strong) UIColor *color; // Defaults to cyan
@property (nonatomic, assign) CGFloat cornerRadius; // Defaults to 6.f
@property (nonatomic, assign) CGFloat borderWidth; // Defaults to 4.f

@end
