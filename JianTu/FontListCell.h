//
//  FontListCell.h
//  JianTu
//
//  Created by KevinSu on 16/8/2.
//  Copyright © 2016年 KevinSu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FontListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIImageView *fontTypeImg;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *loadingHint;
@property (nonatomic, copy) void(^downloadAction)(UIButton * downloadBtn);

@end
