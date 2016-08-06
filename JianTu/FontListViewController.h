//
//  FontListViewController.h
//  JianTu
//
//  Created by KevinSu on 16/8/2.
//  Copyright © 2016年 KevinSu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FontListViewController : UIViewController

@property (nonatomic, copy) void(^changeFontBlock)(NSString * fontName);

@end
