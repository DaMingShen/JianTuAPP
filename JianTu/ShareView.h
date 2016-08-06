//
//  ShareView.h
//  SUMusic
//
//  Created by 万众科技 on 16/2/1.
//  Copyright © 2016年 KevinSu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ShareType) {
    ShareTypeSina = 0,
    ShareTypeWeChat,
    ShareTypeTimeLine,
    ShareTypeSaveToAlbum
};

@interface ShareView : UIView

@property (nonatomic, copy) void(^shareBlock)(ShareType shareType);

//显示
- (void)showInView:(UIView *)view;
//隐藏
- (IBAction)dismiss:(id)sender;

@end
