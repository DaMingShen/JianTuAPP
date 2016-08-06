//
//  FontManager.m
//  JianTu
//
//  Created by 万众科技 on 16/8/3.
//  Copyright © 2016年 KevinSu. All rights reserved.
//
//http://www.thinksaas.cn/topics/0/452/452171.html
//http://blog.devtang.com/2013/08/11/ios-asian-font-download-introduction/
//http://nonomori.farbox.com/post/zi-ti-jia-zai-san-chong-fang-shi

#import "FontManager.h"
#import <CoreText/CoreText.h>

@implementation FontManager

+ (instancetype)manager {
    static FontManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FontManager alloc]init];
    });
    return manager;
}

#pragma mark - 字体是否存在
+ (BOOL)fontExist:(NSString *)fontName {
    UIFont * font = [UIFont fontWithName:fontName size:12];
    if (font && ([font.fontName compare:fontName] == NSOrderedSame || [font.familyName compare:fontName] == NSOrderedSame)) {
        return YES;
    }else {
        return NO;
    }
}

#pragma mark - 字体列表
- (NSMutableArray *)fontList {
    if (!_fontList) {
        _fontList = [NSMutableArray array];
        NSArray * fontNameArray = @[@"STHeitiSC-Medium", @"STSongti-SC-Regular", @"STHeitiSC-Medium", @"DFWaWaSC-W5", @"STXingkai-SC-Light", @"STBaoli-SC-Regular", @"HiraginoSansGB-W3", @"FZLTXHK--GBK1-0"];
        NSArray * fontImageArray = @[@"font_default", @"font_songti", @"font_houzhong", @"font_keai", @"font_gangbi", @"font_lishu", @"font_dongqing", @"font_lanting"];
        for (NSInteger i = 0; i < fontNameArray.count; i ++) {
            FontInfo * info = [[FontInfo alloc]init];
            info.fontName = fontNameArray[i];
            info.fontImage = fontImageArray[i];
            info.isLoaded = NO;
            info.fontNo = i;
            [_fontList addObject:info];
        }
    }
    return _fontList;
}

#pragma mark - 加载字体
- (void)loadFont {
    static NSInteger index = 0;
    if (index >= self.fontList.count) {
        return;
    }
    WEAKSELF
    FontInfo * fontInfo = self.fontList[index];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:fontInfo.fontName]) {
        self.currentTask = fontInfo;
        [self downloadFont:fontInfo complete:^{
            index ++;
            [weakSelf loadFont];
        }];
    }else {
        self.currentTask = fontInfo;
        [self willChangeValueForKey:@"currentTask"];
        self.currentTask.isLoaded = YES;
        self.currentTask.isCached = [FontManager fontExist:fontInfo.fontName];
        self.currentTask.isDownloading = NO;
        [self didChangeValueForKey:@"currentTask"];
        index ++;
        [weakSelf loadFont];
    }
}

- (void)downloadFont:(FontInfo *)fontInfo {
    self.currentTask = fontInfo;
    [self willChangeValueForKey:@"currentTask"];
    self.currentTask.isDownloading = YES;
    [self didChangeValueForKey:@"currentTask"];
    [self downloadFont:fontInfo complete:nil];
}


- (void)downloadFont:(FontInfo *)fontInfo complete:(void(^)())completeBlock {
    NSMutableDictionary * attrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:fontInfo.fontName, kCTFontNameAttribute, nil];
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attrs);
    NSMutableArray * descs = [NSMutableArray arrayWithCapacity:0];
    [descs addObject:(__bridge id)desc];
    CFRelease(desc);
    
    __block BOOL errorDuringDownload = NO;
    CTFontDescriptorMatchFontDescriptorsWithProgressHandler((__bridge CFArrayRef)descs, NULL, ^bool(CTFontDescriptorMatchingState state, CFDictionaryRef  _Nonnull progressParameter) {
        double progressValue = [[(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingPercentage] doubleValue];
        if (state == kCTFontDescriptorMatchingDidBegin) {
            NSLog(@"字体下载：开始匹配 ");
        } else if (state == kCTFontDescriptorMatchingDidFinish) {
            if (!errorDuringDownload) {
                NSLog(@"字体下载：匹配完成");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:fontInfo.fontName];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    [self willChangeValueForKey:@"currentTask"];
                    self.currentTask.isLoaded = YES;
                    self.currentTask.isCached = YES;
                    self.currentTask.isDownloading = NO;
                    [self didChangeValueForKey:@"currentTask"];
                    if (completeBlock) {
                        completeBlock();
                    }
                });
            }
        } else if (state == kCTFontDescriptorMatchingWillBeginDownloading) {
            NSLog(@"字体下载：开始下载 ");
        } else if (state == kCTFontDescriptorMatchingDidFinishDownloading) {
            NSLog(@"字体下载：下载完成");
        } else if (state == kCTFontDescriptorMatchingDownloading) {
            NSLog(@"字体下载：下载进度 %.0f%%", progressValue);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self willChangeValueForKey:@"currentTask"];
                self.currentTask.progress = progressValue / 100;
                [self didChangeValueForKey:@"currentTask"];
            });
        } else if (state == kCTFontDescriptorMatchingDidFailWithError) {
            NSLog(@"字体下载：下载错误");
            errorDuringDownload = YES;
        }
        return YES;
    });
}

@end

@implementation FontInfo
@end

