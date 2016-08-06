//
//  FontManager.h
//  JianTu
//
//  Created by 万众科技 on 16/8/3.
//  Copyright © 2016年 KevinSu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FontInfo;
@interface FontManager : NSObject

@property (nonatomic, strong) NSMutableArray * fontList;
@property (nonatomic, strong) FontInfo * currentTask;

+ (instancetype)manager;

//判断某个字体是否存在（可判断系统自带的 & 已匹配的）
+ (BOOL)fontExist:(NSString *)fontName;
//加载字体（用于启动APP后加载已缓存的字体）
- (void)loadFont;
//下载字体
- (void)downloadFont:(FontInfo *)fontInfo;

@end


@interface FontInfo : NSObject

@property (nonatomic, assign) NSInteger fontNo;    //字体编号
@property (nonatomic, strong) NSString * fontName; //字体名字
@property (nonatomic, strong) NSString * fontImage; //字体图片
@property (nonatomic, assign) BOOL isLoaded;       //是否已加载
@property (nonatomic, assign) BOOL isCached;       //是否已下载
@property (nonatomic, assign) BOOL isDownloading;  //是否正在下载
@property (nonatomic, assign) CGFloat progress;    //下载进度

@end
