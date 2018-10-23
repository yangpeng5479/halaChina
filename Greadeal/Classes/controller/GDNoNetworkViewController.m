//
//  GDNoNetworkViewController.m
//  Greadeal
//
//  Created by Elsa on 15/9/2.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDNoNetworkViewController.h"

@interface GDNoNetworkViewController ()

@end

@implementation GDNoNetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    reloading = YES;
    netWorkError = NO;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)noNetworkView
{
    if (!_noNetworkView) {
        
        _noNetworkView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        _noNetworkView.backgroundColor = [UIColor whiteColor];
        int offsety = self.view.bounds.size.height / 3.0 ;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 50 + offsety, self.view.bounds.size.width-20, 50)];
        
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"Network error, click here to try again.", @"网络错误,请单击重连接");
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        
        label.font = MOLightFont(14);
        [_noNetworkView addSubview:label];
        
        UIImageView *imgV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_blank_network.png"]];
        imgV.center = CGPointMake(self.view.frame.size.width / 2.0, 10 + offsety);
        [_noNetworkView addSubview:imgV];
        
        _noNetworkView.userInteractionEnabled=YES;
        MODebugLayer(_noNetworkView, 1.f, [UIColor redColor].CGColor);
    }
    return _noNetworkView;
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
