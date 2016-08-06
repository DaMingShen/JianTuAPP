//
//  UIView+SU.h
//  JianTu
//
//  Created by KevinSu on 16/8/1.
//  Copyright © 2016年 KevinSu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SU)

@property (nonatomic, assign) float h;
@property (nonatomic, assign) float w;
@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;


@property (nonatomic,readonly) float top;
@property (nonatomic,readonly) float bottom;
@property (nonatomic,readonly) float left;
@property (nonatomic,readonly) float right;

//截屏
- (UIImage *)captureView;

@end
