//
//  SuDefine.h
//  NewsReader
//
//  Created by KevinSu on 15/10/15.
//  Copyright (c) 2015年 KevinSu. All rights reserved.
//

#ifndef SuDefine_h
#define SuDefine_h

#if DEBUG
#define WZLog(format, ...) NSLog(@"INFO:[%@ %@] " format, NSStringFromClass([self class]), NSStringFromSelector(_cmd), ## __VA_ARGS__)
#define WZLog_INFO(info)   NSLog(@"INFO:[%@ %@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), info)
#define WZLog_ERROR(err)   NSLog(@"ERROR:[%@ %@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), err)
#else
#define WZLog(format, ...)
#define WZLog_INFO(info)
#define WZLog_ERROR(error)
#endif

//弱引用的创建
#define WEAKSELF __weak __typeof(&*self)weakSelf = self;

// 设备类型判断
#define ScreenW    ([[UIScreen mainScreen] bounds].size.width)
#define ScreenH    ([[UIScreen mainScreen] bounds].size.height)
#define ScreenMaxL (MAX(ScreenW, ScreenH))
#define ScreenMinL (MIN(ScreenW, ScreenH))
#define ScreenB    [[UIScreen mainScreen] bounds]

#define IsiPhone4   (IsiPhone && ScreenMaxL < 568.0)
#define IsiPhone5   (IsiPhone && ScreenMaxL == 568.0)
#define IsiPhone6   (IsiPhone && ScreenMaxL == 667.0)
#define IsiPhone6P  (IsiPhone && ScreenMaxL == 736.0)

// 消息通知
#define RegisterNotify(_name, _selector)                    \
[[NSNotificationCenter defaultCenter] addObserver:self  \
selector:_selector name:_name object:nil];

#define RemoveNofify            \
[[NSNotificationCenter defaultCenter] removeObserver:self];

#define SendNotify(_name, _object)  \
[[NSNotificationCenter defaultCenter] postNotificationName:_name object:_object];

// 设置颜色值
#define RGBColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define ClearColor      [UIColor clearColor]
#define Color_Black       [UIColor blackColor]
#define Color_White      RGBColor(255,255,255)
#define Color_Coffee     RGBColor(203,182,177)
#define Color_Darkcloud  RGBColor(196,201,204)
#define Color_Rose       RGBColor(242,92,81)
#define Color_Peach      RGBColor(253,126,159)
#define Color_Orange     RGBColor(241,155,44)
#define Color_Lavender   RGBColor(186,103,219)
#define Color_Sunshine   RGBColor(96,191,245)
#define Color_Midnight   RGBColor(42,55,80)
#define Color_Vanilla    RGBColor(246,238,218)
#define Color_Freshgreen RGBColor(82,202,178)

// 文件缓存路径
#define RootPath        @"Library/.JianTu"
#define CacheFontsPath  @"CacheFonts"

//公共值
#define WZNavHeight    64.0
#define WZTabbarHeight 49.0

#endif
