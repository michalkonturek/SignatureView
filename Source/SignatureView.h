//
//  SignatureView.h
//  SignatureView
//
//  Created by Michal Konturek on 05/05/2014.
//  Copyright (c) 2014 Michal Konturek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignatureView : UIImageView

@property (nonatomic, strong) UIColor *activeLineColor;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) NSInteger lineWidth;

@property (nonatomic, strong) UILongPressGestureRecognizer *recognizer;

- (void)clear;
- (void)clearWithColor:(UIColor *)color;

- (NSData *)imageData;

- (BOOL)isSigned;

@end
