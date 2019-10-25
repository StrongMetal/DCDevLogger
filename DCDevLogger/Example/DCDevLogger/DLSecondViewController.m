//
//  DLSecondViewController.m
//  DCDevLogger_Example
//
//  Created by miaoy on 2019/10/24.
//  Copyright © 2019 StrongMetal. All rights reserved.
//

#import "DLSecondViewController.h"
#import "DLThirdViewController.h"


@implementation DLSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    DLThirdViewController *thirdVc = [[DLThirdViewController alloc] init];
    [self.navigationController pushViewController:thirdVc animated:YES];
}

@end
