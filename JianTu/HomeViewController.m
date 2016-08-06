//
//  HomeViewController.m
//  JianTu
//
//  Created by KevinSu on 16/7/31.
//  Copyright © 2016年 KevinSu. All rights reserved.
//

#import "HomeViewController.h"
#import "FontListViewController.h"
#import "CameraRender.h"
#import "ShareView.h"
#import <UMSocial.h>

@interface HomeViewController ()<UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *panelView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *filterView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *toolView;
@property (weak, nonatomic) IBOutlet UIButton *colorBtn;
@property (weak, nonatomic) IBOutlet UIButton *fontBtn;
@property (weak, nonatomic) IBOutlet UIButton *albumBtn;
@property (weak, nonatomic) IBOutlet UIButton *cameraBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@property (nonatomic, strong) NSArray * colorArray; //背景色变化
@property (nonatomic, strong) NSArray * colorNameArray;
@property (nonatomic, assign) NSInteger colorIndex;

@property (nonatomic, assign) BOOL takingPhoto;//相机
@property (nonatomic, strong) CameraRender * cameraRender;//相机
@property (nonatomic, strong) UIVisualEffectView * visualEffectView; //模糊效果
@property (nonatomic, strong) ShareView * shareView; //分享

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prefersStatusBarHidden];
    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
}

#pragma mark - Function: UI
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)refreshToolView {
    WZLog(@"调整UI");
    if ((self.textView.text.length > 0 && ![self.textView.text isEqualToString:@"写在这里"]) || self.imageView.image || self.takingPhoto) {
        if (self.confirmBtn.hidden) {
            self.confirmBtn.hidden = NO;
            self.confirmBtn.alpha = 0.f;
            [UIView animateWithDuration:0.5 animations:^{
                self.toolView.y -= 40;
                self.confirmBtn.y += 40;
                self.confirmBtn.alpha = 1.0;
            }];
        }
    }else {
        if (!self.confirmBtn.hidden) {
            [UIView animateWithDuration:0.5 animations:^{
                self.toolView.y += 40;
                self.confirmBtn.y -= 40;
                self.confirmBtn.alpha = 0.f;
            } completion:^(BOOL finished) {
                self.confirmBtn.hidden = YES;
            }];
        }
    }
    if (self.imageView.image) {
        [self.colorBtn setImage:[UIImage imageNamed:@"tool-delete"] forState:UIControlStateNormal];
    }else {
        [self.colorBtn setImage:[UIImage imageNamed:@"tool-color"] forState:UIControlStateNormal];
    }
}

#pragma mark - Function: 相机
- (CameraRender *)cameraRender {
    if (!_cameraRender) {
        WEAKSELF
        _cameraRender = [[CameraRender alloc]init];
        [_cameraRender setTakePhotoBlock:^(UIImage * image) {
            weakSelf.imageView.image = image;
            weakSelf.cameraRender = nil;
            weakSelf.takingPhoto = NO;
            [weakSelf refreshToolView];
        }];
        [self.panelView addSubview:_cameraRender.view];
    }
    return _cameraRender;
}

- (void)setTakingPhoto:(BOOL)takingPhoto {
    _takingPhoto = takingPhoto;
    if (takingPhoto) {
        self.colorBtn.hidden = YES;
        self.cameraBtn.hidden = YES;
        [self.fontBtn setImage:[UIImage imageNamed:@"tool-delete"] forState:UIControlStateNormal];
        [self.albumBtn setImage:[UIImage imageNamed:@"tool-switch"] forState:UIControlStateNormal];
        [self.confirmBtn setImage:[UIImage imageNamed:@"tool-shoot"] forState:UIControlStateNormal];
    }else {
        self.colorBtn.hidden = NO;
        self.cameraBtn.hidden = NO;
        [self.fontBtn setImage:[UIImage imageNamed:@"tool-font"] forState:UIControlStateNormal];
        [self.albumBtn setImage:[UIImage imageNamed:@"tool-album"] forState:UIControlStateNormal];
        [self.confirmBtn setImage:[UIImage imageNamed:@"tool-confirm"] forState:UIControlStateNormal];
    }
}

#pragma mark - Function: 按钮
- (IBAction)changeColor:(UIButton *)sender {
    if (self.imageView.image) {
        self.imageView.image = nil;
        self.filterView.alpha = 0.f;
        self.visualEffectView.alpha = 0.f;
        [self refreshToolView];
    }else {
        self.colorIndex ++;
        if (self.colorIndex >= self.colorArray.count) {
            self.colorIndex = 0;
        }
        self.panelView.backgroundColor = self.colorArray[self.colorIndex];
        if (self.colorIndex == 0 || self.colorIndex == 2 || self.colorIndex == 9) {
            self.textView.textColor = Color_Black;
        }else {
            self.textView.textColor = Color_White;
        }
        [WZMessage showMessage:self.colorNameArray[self.colorIndex] animated:NO];
    }
}

- (IBAction)changeFont:(UIButton *)sender {
    if (self.takingPhoto) {
        [self.cameraRender stop];
        self.cameraRender = nil;
        self.takingPhoto = NO;
        [self refreshToolView];
    }else {
        WEAKSELF
        FontListViewController * fontListVC = [[FontListViewController alloc]init];
        [fontListVC setChangeFontBlock:^(NSString * fontName) {
            UIFont * font = [UIFont fontWithName:fontName size:17.0];
            weakSelf.textView.font = font;
        }];
        UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:fontListVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (IBAction)pickAlbum:(UIButton *)sender {
    if (self.takingPhoto) {
        [self.cameraRender switchCamera];
    }else {
        [self pickPhotoFromAlbum];
    }
}

- (IBAction)takePhoto:(UIButton *)sender {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
        [[[UIAlertView alloc]initWithTitle:@"应用程序无访问相机权限" message:@"请在“设置\"-\"隐私\"-\"相机”中设置允许访问" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"设置", nil]show];
    }else if (status == AVAuthorizationStatusAuthorized) {
        self.takingPhoto = YES;
        [self refreshToolView];
        [self.cameraRender start];
    }else {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                self.takingPhoto = YES;
                [self refreshToolView];
                [self.cameraRender start];
            }
        }];
    }
}

- (IBAction)finishEidting:(UIButton *)sender {
    if (self.takingPhoto) {
        [self.cameraRender takePhoto];
    }else {
        [self sharePhoto];
    }
}

- (IBAction)fontListMenu:(UIButton *)sender {
    FontListViewController * fontListVC = [[FontListViewController alloc]init];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:fontListVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Function: 相册
- (void)pickPhotoFromAlbum {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied) {
        [[[UIAlertView alloc]initWithTitle:@"不能预览图片" message:@"应用程序无访问照片权限, 请在“设置\"-\"隐私\"-\"照片”中设置允许访问" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"设置", nil]show];
    }else if (status == ALAuthorizationStatusAuthorized) {
        UIImagePickerController * pickerController = [[UIImagePickerController alloc]init];
        [pickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [pickerController setDelegate:self];
        [pickerController setAllowsEditing:YES];
        [self presentViewController:pickerController animated:YES completion:nil];
    }else {
        ALAssetsLibrary * assetsLibrary = [[ALAssetsLibrary alloc]init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (*stop) {
                UIImagePickerController * pickerController = [[UIImagePickerController alloc]init];
                [pickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                [pickerController setDelegate:self];
                [pickerController setAllowsEditing:YES];
                [self presentViewController:pickerController animated:YES completion:nil];
            }
            *stop = YES;
        } failureBlock:^(NSError *error) {
            [[[UIAlertView alloc]initWithTitle:@"不能预览图片" message:@"应用程序无访问照片权限, 请在“设置\"-\"隐私\"-\"照片”中设置允许访问" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"设置", nil]show];
        }];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage * image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    self.imageView.image = image;
    [self refreshToolView];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Function: 保存/分享
- (void)sharePhoto {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied) {
        [[[UIAlertView alloc]initWithTitle:@"不能保存图片" message:@"应用程序无访问照片权限, 请在“设置\"-\"隐私\"-\"照片”中设置允许访问" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"设置", nil]show];
    }else if (status == ALAuthorizationStatusAuthorized) {
        [self.shareView showInView:self.view];
    }else {
        ALAssetsLibrary * assetsLibrary = [[ALAssetsLibrary alloc]init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (*stop) {
                [self.shareView showInView:self.view];
            }
            *stop = YES;
        } failureBlock:^(NSError *error) {
            [[[UIAlertView alloc]initWithTitle:@"不能保存图片" message:@"应用程序无访问照片权限, 请在“设置\"-\"隐私\"-\"照片”中设置允许访问" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"设置", nil]show];
        }];
    }
}

- (ShareView *)shareView {
    if (!_shareView) {
        WEAKSELF
        _shareView = [[NSBundle mainBundle] loadNibNamed:@"ShareView" owner:self options:nil][0];
        _shareView.frame = ScreenB;
        [_shareView setShareBlock:^(ShareType shareType) {
            [weakSelf shareWithType:shareType];
        }];
    }
    return _shareView;
}

- (void)shareWithType:(ShareType)shareType {
    if (shareType == ShareTypeSaveToAlbum) {
        UIImageWriteToSavedPhotosAlbum([self.panelView captureView], self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        [self.shareView dismiss:nil];
    }else {
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
        NSArray * types = @[UMShareToSina, UMShareToWechatSession, UMShareToWechatTimeline];
        [[UMSocialDataService defaultDataService] postSNSWithTypes:@[types[shareType]] content:nil image:[self.panelView captureView] location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response) {
            [self.shareView dismiss:nil];
            if (response.responseCode == UMSResponseCodeSuccess) {
                [[[UIAlertView alloc]initWithTitle:@"分享成功!" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil]show];
            }
        }];
    }
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        [[[UIAlertView alloc]initWithTitle:@"保存图片到相册成功!" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil]show];
    }
}



#pragma mark - Function: 手势
- (IBAction)textViewPan:(UIPanGestureRecognizer *)sender {
    self.textView.centerY = [sender locationInView:self.panelView].y;
    if (self.textView.y < 0) {
        self.textView.y = 0;
    }
    if (self.textView.y > self.panelView.h - self.textView.h) {
        self.textView.y = self.panelView.bottom - self.textView.h;
    }
}

- (IBAction)textViewSwipe:(UISwipeGestureRecognizer *)sender {
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (self.textView.textAlignment == NSTextAlignmentRight) {
            self.textView.textAlignment = NSTextAlignmentCenter;
        }else {
            self.textView.textAlignment = NSTextAlignmentLeft;
        }
    }
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        if (self.textView.textAlignment == NSTextAlignmentLeft) {
            self.textView.textAlignment = NSTextAlignmentCenter;
        }else {
            self.textView.textAlignment = NSTextAlignmentRight;
        }
    }
}

- (IBAction)lightEditPan:(UIPanGestureRecognizer *)sender {
    if (!self.imageView.image) {
        return;
    }
    CGPoint location = [sender locationInView:sender.view];
    CGFloat alpha = location.y / sender.view.h;
    self.filterView.alpha = alpha * 0.5;
}

- (IBAction)blurEditPan:(UIPanGestureRecognizer *)sender {
    if (!self.imageView.image) {
        return;
    }
    CGPoint location = [sender locationInView:sender.view];
    CGFloat alpha = location.y / sender.view.h;
    self.visualEffectView.alpha = alpha;
}



#pragma mark - Function: 代理
//TextView代理
- (void)textViewDidChange:(UITextView *)textView {
    self.textView.h = self.textView.contentSize.height;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"写在这里"]) {
        textView.text = @"";
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [self refreshToolView];
    return YES;
}

//AlertView代理
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex) {
        NSURL * setting = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication]canOpenURL:setting]) {
            [[UIApplication sharedApplication]openURL:setting];
        }
    }
}

#pragma mark - Function: Getter/Setter
//模糊
- (UIVisualEffectView *)visualEffectView {
    if (!_visualEffectView) {
        UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        _visualEffectView.frame = self.filterView.bounds;
        [self.imageView addSubview:_visualEffectView];
    }
    return _visualEffectView;
}

//颜色
- (NSArray *)colorArray {
    if (!_colorArray) {
        _colorArray = @[Color_White, Color_Freshgreen, Color_Vanilla, Color_Midnight, Color_Sunshine, Color_Lavender, Color_Orange, Color_Peach, Color_Rose, Color_Darkcloud, Color_Coffee];
    }
    return _colorArray;
}

- (NSArray *)colorNameArray {
    if (!_colorNameArray) {
        _colorNameArray = @[@"纯白", @"青葱", @"香草", @"午夜", @"晴天", @"薰衣草", @"鲜橙", @"蜜桃", @"玫瑰", @"乌云", @"咖啡"];
    }
    return _colorNameArray;
}

@end
