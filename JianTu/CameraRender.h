//
//  CameraRender.h
//  JianTu
//
//  Created by 万众科技 on 16/8/3.
//  Copyright © 2016年 KevinSu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CameraRender : NSObject

@property (nonatomic, strong) UIView * view;
@property (nonatomic, copy) void(^takePhotoBlock)(UIImage * image);

//启动相机
- (void)start;
//拍照
- (void)takePhoto;
//切换摄像头
- (void)switchCamera;
//关闭相机
- (void)stop;

@end
