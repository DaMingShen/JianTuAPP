//
//  UIImage+SU.m
//  JianTu
//
//  Created by KevinSu on 16/7/31.
//  Copyright © 2016年 KevinSu. All rights reserved.
//

#import "UIImage+SU.h"

@implementation UIImage (SU)

- (UIImage *)clipImageWithRect:(CGRect)rect {
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage * clipImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationRight];
    CGImageRelease(imageRef);
    return clipImage;
}



@end
