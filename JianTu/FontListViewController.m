//
//  FontListViewController.m
//  JianTu
//
//  Created by KevinSu on 16/8/2.
//  Copyright © 2016年 KevinSu. All rights reserved.
//

#import "FontListViewController.h"
#import "FontListCell.h"
#import "WZNetworkMonitor.h"

static NSString * cellID = @"fontListCell";

@interface FontListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FontListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"字体下载";
    [self.tableView registerNib:[UINib nibWithNibName:@"FontListCell" bundle:nil] forCellReuseIdentifier:cellID];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    self.tableView.tableFooterView = [UIView new];
    
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    [[FontManager manager]addObserver:self forKeyPath:@"currentTask" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    [[FontManager manager]removeObserver:self forKeyPath:@"currentTask"];
}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [FontManager manager].fontList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FontListCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    FontInfo * fontInfo = [FontManager manager].fontList[indexPath.row];
    cell.fontTypeImg.image = [UIImage imageNamed:fontInfo.fontImage];
    [self relateFontInfo:fontInfo cell:cell];
    [cell setDownloadAction:^(UIButton * downloadBtn) {
        if ([WZNetworkMonitor wifiEnable]) {
            [[FontManager manager]downloadFont:fontInfo];
            [tableView reloadData];
        }else {
            [[[UIAlertView alloc]initWithTitle:@"当前处于非WiFi网络" message:@"字体文件较大，可能会导致消耗大量流量，请在WiFi环境下下载" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil]show];
        }
    }];
    return cell;
}

#pragma mark - Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    FontInfo * fontInfo = [FontManager manager].fontList[indexPath.row];
    if (self.changeFontBlock) {
        if (fontInfo.isCached) {
            self.changeFontBlock(fontInfo.fontName);
            [self dismissViewControllerAnimated:YES completion:nil];
        }else {
            [[[UIAlertView alloc]initWithTitle:nil message:@"该字体尚未下载" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil]show];
        }
    }
}


#pragma mark - Observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    FontInfo * fontInfo = [FontManager manager].currentTask;
    if (fontInfo) {
        FontListCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:fontInfo.fontNo inSection:0]];
        [self relateFontInfo:fontInfo cell:cell];
        if (fontInfo.isCached) {
            [self.tableView reloadData];
        }
    }
}

- (void)relateFontInfo:(FontInfo *)fontInfo cell:(FontListCell *)cell {
    if (fontInfo.isLoaded) {
        if (fontInfo.isCached) {
            cell.loadingHint.hidden = YES;
            cell.progressView.hidden = YES;
            cell.downloadBtn.hidden = NO;
            cell.downloadBtn.selected = YES;
            cell.downloadBtn.userInteractionEnabled = NO;
        }
        else {
            if (fontInfo.isDownloading) {
                cell.downloadBtn.hidden = YES;
                cell.loadingHint.hidden = NO;
                cell.loadingHint.text = @"正在下载...";
                cell.progressView.hidden = NO;
                cell.progressView.w = fontInfo.progress * ScreenW;
            }
            else {
                cell.downloadBtn.hidden = NO;
                cell.downloadBtn.selected = NO;
                cell.downloadBtn.userInteractionEnabled = YES;
                cell.loadingHint.hidden = YES;
                if ([FontManager manager].currentTask.isDownloading && [FontManager manager].currentTask != fontInfo) {
                    cell.downloadBtn.enabled = NO;
                }else {
                    cell.downloadBtn.enabled = YES;
                }
            }
        }
    }
    //未加载完成
    else {
        cell.downloadBtn.hidden = YES;
        cell.loadingHint.hidden = NO;
        cell.loadingHint.text = @"正在读取...";
    }
}



@end
