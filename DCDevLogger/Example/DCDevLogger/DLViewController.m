//
//  DLViewController.m
//  DCDevLogger
//
//  Created by StrongMetal on 10/24/2019.
//  Copyright (c) 2019 StrongMetal. All rights reserved.
//

#import "DLViewController.h"
#import "DLSecondViewController.h"
#import "DLThirdViewController.h"

@interface DLViewController ()

@end

@implementation DLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action

- (IBAction)secondAction:(id)sender {
    DLSecondViewController *vc = [DLSecondViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)thirdAction:(id)sender {
    DLThirdViewController *vc = [DLThirdViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
