//
//  GDBaseTableViewController.h
//
//  Created by taotao Virlet on 7/20/12.
//
//  Copyright (c) 2012 1000memories


#import <UIKit/UIKit.h>
#import "MORefreshTableHeaderView.h"


@interface GDBaseTableViewController : UIViewController
{
    UITableView              *mainTableView;

    MORefreshTableHeaderView *refreshHeaderView;
    
    UIView                   *getMoreview;
    UIActivityIndicatorView  *indicator;

	BOOL     reloading;
	BOOL     checkForRefresh;
    
    UIView	 *_noNetworkView;
    UIView	 *_noDataView;
    UIView	 *_noDeliverView;
    
    BOOL     netWorkError;
}

-(void)reLoadView;
-(void)loadMoreView;

-(void)stopLoad;
-(void)addRefreshUI;

-(UIView *)noDataView;
-(UIView *)noNetworkView;
-(UIView *)noDeliveryView;


@end
