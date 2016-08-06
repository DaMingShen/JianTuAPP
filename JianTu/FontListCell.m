//
//  FontListCell.m
//  JianTu
//
//  Created by KevinSu on 16/8/2.
//  Copyright © 2016年 KevinSu. All rights reserved.
//

#import "FontListCell.h"

@implementation FontListCell

- (IBAction)downloadAction:(UIButton *)sender {
    if (self.downloadAction) {
        self.downloadAction(sender);
    }
}


@end
