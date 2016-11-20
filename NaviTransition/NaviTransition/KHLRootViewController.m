//
//  KHLRootViewController.m
//  NaviTransition
//
//  Created by khl on 2016/11/20.
//  Copyright © 2016年 khl. All rights reserved.
//

#import "KHLRootViewController.h"

@interface KHLRootViewController ()

@end

@implementation KHLRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)push:(id)sender {
    KHLRootViewController *vc = [KHLRootViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
