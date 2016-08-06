//
//  UIImage+SU.h
//  JianTu
//
//  Created by KevinSu on 16/7/31.
//  Copyright © 2016年 KevinSu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SU)

//剪切图片(rect计算单位为图片像素点)
- (UIImage *)clipImageWithRect:(CGRect)rect;

@end
