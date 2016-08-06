//
//  CameraRender.m
//  JianTu
//
//  Created by 万众科技 on 16/8/3.
//  Copyright © 2016年 KevinSu. All rights reserved.
//
//http://www.jianshu.com/p/5860087c8981
//http://blog.csdn.net/qq_30513483/article/details/51198464
//http://www.jianshu.com/p/b99138259c25
//http://blog.163.com/chester_lp/blog/static/139794082012119112834437/
// http://www.cocoachina.com/ios/20150311/11296.html
// http://blog.csdn.net/smiling8866/article/details/47002007

#import "CameraRender.h"

@interface CameraRender ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL usingFrontCamera;
@property (nonatomic, assign) CGFloat beginScale;
@property (nonatomic, assign) CGFloat effectiveScale;
@property (nonatomic, strong) AVCaptureSession * session;
@property (nonatomic, strong) AVCaptureDeviceInput * videoInput;
@property (nonatomic, strong) UIView * previewView;
@property (nonatomic, strong) UIImageView * focusView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * previewLayer;
@property (nonatomic, strong) AVCaptureStillImageOutput * stillImageOutput; //照片输出

@end

@implementation CameraRender

#pragma mark - 相机 Getter/Setter
- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc]init];
        AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        self.videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:device error:nil];
        NSDictionary * outputSetting = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc]init];
        [self.stillImageOutput setOutputSettings:outputSetting];
        if ([_session canAddInput:self.videoInput]) {
            [_session addInput:self.videoInput];
        }
        if ([_session canAddOutput:self.stillImageOutput]) {
            [_session addOutput:self.stillImageOutput];
        }
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:_session];
        [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        self.previewLayer.frame = ScreenB;
        [self.previewView.layer insertSublayer:self.previewLayer atIndex:0];
    }
    return _session;
}

- (UIView *)previewView {
    if (!_previewView) {
        _previewView = [[UIView alloc]initWithFrame:ScreenB];
        UIPinchGestureRecognizer * pinchGes = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(previewPinchAction:)];
        pinchGes.delegate = self;
        [_previewView addGestureRecognizer:pinchGes];
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(previewTapAction:)];
        [_previewView addGestureRecognizer:tapGes];
        [_previewView addSubview:self.focusView];
    }
    return _previewView;
}

- (UIImageView *)focusView {
    if (!_focusView) {
        _focusView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 64, 64)];
        _focusView.image = [UIImage imageNamed:@"tool-focus"];
        _focusView.hidden = YES;
    }
    return _focusView;
}

- (CGFloat)beginScale {
    if (_beginScale < 1.0) {
        _beginScale = 1.0;
    }
    return _beginScale;
}

- (CGFloat)effectiveScale {
    if (_effectiveScale < 1.0) {
        _effectiveScale = 1.0;
    }
    return _effectiveScale;
}

#pragma mark - 相机 Action
- (void)previewPinchAction:(UIPinchGestureRecognizer *)recognizer {
    self.effectiveScale = self.beginScale * recognizer.scale;
    if (self.effectiveScale < 1.0) self.effectiveScale = 1.0;
    
    CGFloat maxScaleAndCropFactor = [[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
    if (self.effectiveScale > maxScaleAndCropFactor) self.effectiveScale = maxScaleAndCropFactor;
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.025];
    [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
    [CATransaction commit];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        self.beginScale = self.effectiveScale;
    }
    return YES;
}

- (void)previewTapAction:(UITapGestureRecognizer *)recognizer {
    AVCaptureDevice * device = self.videoInput.device;
    if (device.isFocusPointOfInterestSupported) {
        CGPoint location = [recognizer locationInView:self.previewView];
        [device lockForConfiguration:nil];
        //对焦模式和对焦点
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device setFocusPointOfInterest:location];
        }
        //曝光模式和曝光点
        if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            [device setExposureMode:AVCaptureExposureModeAutoExpose];
            [device setExposurePointOfInterest:location];
        }
        [device unlockForConfiguration];
        
        self.focusView.center = location;
        self.focusView.hidden = NO;
        self.focusView.transform = CGAffineTransformMakeScale(1.2, 1.2);
        [UIView animateWithDuration:0.4 animations:^{
            self.focusView.transform = CGAffineTransformIdentity;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 animations:^{
                self.focusView.alpha = 0.5;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.15 animations:^{
                    self.focusView.alpha = 1.0;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.15 animations:^{
                        self.focusView.alpha = 0.5;
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.15 animations:^{
                            self.focusView.alpha = 1.0;
                        } completion:^(BOOL finished) {
                            self.focusView.hidden = YES;
                        }];
                    }];
                }];
            }];
        }];
    }else {
        NSLog(@"not support autoFocus");
    }
}

#pragma mark - 相机 Function
- (void)switchCamera {
    AVCaptureDevicePosition position = self.usingFrontCamera ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    WZLog_INFO([self.session.inputs[0] device]);
    for (AVCaptureDevice * device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if (device.position == position) {
            [self.session beginConfiguration];
            [self.session removeInput:self.videoInput];
//            self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
            self.videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:device error:nil];
            [self.session addInput:self.videoInput];
            [self.session commitConfiguration];
            break;
        }
    }
    self.usingFrontCamera = !self.usingFrontCamera;
}

- (AVCaptureVideoOrientation)currentCaptureOrientation {
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice]orientation];
    AVCaptureVideoOrientation captureOrientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            captureOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            captureOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            captureOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        default:
            captureOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
    }
    return captureOrientation;
}

- (void)takePhoto {
    AVCaptureConnection * connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [connection setVideoOrientation:[self currentCaptureOrientation]];
    [connection setVideoScaleAndCropFactor:self.effectiveScale];
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData * jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage * image = [UIImage imageWithData:jpegData];
        if (self.takePhotoBlock) {
            self.takePhotoBlock([image clipImageWithRect:CGRectMake(0, 0, image.size.width, image.size.width)]);
        }
        [self stopTakingPhoto];
    }];
}

- (void)stopTakingPhoto {
    [self.session stopRunning];
    self.session = nil;
    [self.previewView removeFromSuperview];
    self.previewView = nil;
}


#pragma mark - 公共 API
- (void)start {
    [self.session startRunning];
}

- (void)stop {
    [self stopTakingPhoto];
}

- (UIView *)view {
    return self.previewView;
}



@end
