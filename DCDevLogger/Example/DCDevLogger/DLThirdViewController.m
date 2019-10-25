//
//  DLThirdViewController.m
//  DCDevLogger_Example
//
//  Created by miaoy on 2019/10/24.
//  Copyright © 2019 StrongMetal. All rights reserved.
//

#import "DLThirdViewController.h"
#import "DLSecondViewController.h"

@interface DLThirdViewController ()

@end

@implementation DLThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    DLSecondViewController *vc = [[DLSecondViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
