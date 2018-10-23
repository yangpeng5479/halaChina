//
//  GDBaseTableViewController.m
//
//  Created by taotao Virlet on 7/20/12.
//
//  Copyright (c) 2012 1000memories


#import "GDBaseTableViewController.h"

#define kRefreshkShowAll        60
#define kThumbsViewMoreHeight   20

@interface GDBaseTableViewController ()

@end

@implementation GDBaseTableViewController


- (id)init
{
    self = [super init];
    if (self)
    {
        reloading = YES;
        netWorkError = NO;
    }
    return self;
}

-(UIView *)noDeliveryView
{
    if (!_noDeliverView) {
        
        CGRect r = self.view.frame;
        
        int offsety = self.view.bounds.size.height / 3.0 ;
     
        _noDeliverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, r.size.width, r.size.height)];
        _noDeliverView.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, r.size.height/2-40, r.size.width - 40, 40)];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"Oops, the delivery service has not yet been launched here, it will come soon.", @"亲,您所在的城市还没开通外卖业务!");
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.numberOfLines = 0;
        label.font = MOLightFont(14);
        [_noDeliverView addSubview:label];
        
        UIImageView *imgV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"went wrong.png"]];
        imgV.center = CGPointMake(self.view.frame.size.width / 2.0, 10 + offsety);
        [_noDeliverView addSubview:imgV];
    }
    return _noDeliverView;

}

- (UIView *)noDataView
{
    if (!_noDataView) {
        
        CGRect r = self.view.frame;
        
        _noDataView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, r.size.width, r.size.height)];
        _noDataView.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, r.size.height/2-40, r.size.width, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"No Data", @"没有产品");
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.font = MOLightFont(16);
        [_noDataView addSubview:label];
    }
    return _noDataView;
}

- (UIView *)noNetworkView
{
    if (!_noNetworkView) {
        
        _noNetworkView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        int offsety = self.view.bounds.size.height / 3.0 ;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 50 + offsety, self.view.bounds.size.width-20, 50)];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"Network error, click here to try again.", @"网络错误,请单击重连接");
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        
        label.font = MOLightFont(16);
        [_noNetworkView addSubview:label];
        
        UIImageView *imgV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_blank_network.png"]];
        imgV.center = CGPointMake(self.view.frame.size.width / 2.0, 10 + offsety);
        [_noNetworkView addSubview:imgV];
        
        _noNetworkView.userInteractionEnabled=YES;
        MODebugLayer(_noNetworkView, 1.f, [UIColor redColor].CGColor);
    }
    return _noNetworkView;
}

- (void)addRefreshUI
{
    CGRect viewRect = self.view.bounds;
    refreshHeaderView = [[MORefreshTableHeaderView alloc] initWithFrame:
                         CGRectMake(0.0f,0.0-viewRect.size.height,
                                    viewRect.size.width, viewRect.size.height)];
    [refreshHeaderView setLastUpdatedDate:[NSDate date]];
    [mainTableView addSubview:refreshHeaderView];
    
    CGRect barRect = self.view.bounds;
    barRect.size.height = kThumbsViewMoreHeight;
    
    barRect.origin.y = 0;
    
    getMoreview= [[UIView alloc] initWithFrame:barRect];
    getMoreview.backgroundColor= MOColorAppBackgroundColor();
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.center = CGPointMake(barRect.size.width/2, kThumbsViewMoreHeight/2);
    indicator.hidesWhenStopped = YES;
    indicator.color = HUD_SPINNER_COLOR;
    
    [getMoreview addSubview:indicator];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)reLoadView
{
    [mainTableView reloadData];
    
    CGRect barRect = self.view.bounds;
    barRect.origin.y = mainTableView.contentSize.height;
    barRect.size.height = kThumbsViewMoreHeight;
    getMoreview.frame = barRect;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


-(void)loadMoreView
{
    reloading = YES;
    
    mainTableView.tableFooterView = getMoreview;
    
    [getMoreview setUserInteractionEnabled:NO];
    [indicator startAnimating];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    mainTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, kThumbsViewMoreHeight,0.0f);
    [UIView commitAnimations];
    
    //mainTableView.backgroundColor = MOColorAppBackgroundColor();
}

- (void)stopLoad
{
    if (reloading)
    {
        //stop refrsh
        reloading = NO;
        [refreshHeaderView  flipImageAnimated:NO];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
        [mainTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [UIView commitAnimations];
        [refreshHeaderView setStatus:kMOPullToReloadStatus];
        [refreshHeaderView toggleActivityView:NO];
        [refreshHeaderView setLastUpdatedDate:[NSDate date]];
    }
    
    //stop next page
    [getMoreview setUserInteractionEnabled:YES];
    [indicator stopAnimating];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [mainTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [UIView commitAnimations];
    
    if(mainTableView.style == UITableViewStyleGrouped)
    {
        mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,mainTableView.bounds.size.width, 5)];
    }
    else
    {
        UIView *view =[[UIView alloc]init];
        view.backgroundColor = [UIColor clearColor];
        mainTableView.tableFooterView = view;
    }
}

@end
