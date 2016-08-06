//
//  UIView+SU.m
//  JianTu
//
//  Created by KevinSu on 16/8/1.
//  Copyright © 2016年 KevinSu. All rights reserved.
//

#import "UIView+SU.h"

@implementation UIView (SU)

//h
-(void)setH:(float)h{
    CGRect frm = self.frame;
    frm.size.height = h;
    self.frame = frm;
}

-(float)h{
    return self.frame.size.height;
}



//w
-(void)setW:(float)w{
    CGRect frm = self.frame;
    frm.size.width = w;
    self.frame = frm;
}

-(float)w{
    return self.frame.size.width;
}


//x
-(void)setX:(float)x{
    CGRect frm = self.frame;
    frm.origin.x = x;
    self.frame = frm;
    
}


-(float)x{
    return self.frame.origin.x;
}



//y
-(void)setY:(float)y{
    CGRect frm = self.frame;
    frm.origin.y = y;
    self.frame = frm;
    
}


-(float)y{
    return self.frame.origin.y;
}


- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}


-(float)top
{
    return self.frame.origin.x;
}

-(float)bottom
{
    return self.top+self.frame.size.height;
}

-(float)left
{
    return self.frame.origin.x;
}

-(float)right
{
    return self.left+self.frame.size.width;
}

- (UIImage *)captureView {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage * captureImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return captureImage;
}

@end
