//
//  TMQuiltViewController.m
//  TMQuiltView
//
//  Created by Bruno Virlet on 7/20/12.
//
//  Copyright (c) 2012 1000memories

//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
//  EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
//  THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "TMQuiltViewController.h"
#import "TMQuiltView.h"
#import "TMQuiltViewCell.h"
#import "ProgressHUD.h"

#define kAdvertisingResponse    10

@interface TMQuiltViewController () <TMQuiltViewDataSource, TMQuiltViewDelegate>

@end

@implementation TMQuiltViewController

@synthesize quiltView = _quiltView;

- (id)init:(BOOL)haveRefreshView
{
    self = [super init];
    if (self)
    {
        showHeaderView = haveRefreshView;
        reloading = YES;
        netWorkError = NO;
    }
    return self;
}

-(void)loadMainView:(CGRect)r
{
    _quiltView = [[TMQuiltView alloc] initWithFrame:r];
    _quiltView.delegate = self;
    _quiltView.dataSource = self;
    _quiltView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view = _quiltView;
    _quiltView.backgroundColor = MOColorAppBackgroundColor();
    
    if (showHeaderView)
    {
        CGRect viewRect = self.view.bounds;
        refreshHeaderView = [[MORefreshTableHeaderView alloc] initWithFrame:
                             CGRectMake(0.0f,0.0-viewRect.size.height,
                                        viewRect.size.width, viewRect.size.height)];
        [refreshHeaderView setLastUpdatedDate:[NSDate date]];
        [_quiltView addSubview:refreshHeaderView];
        
        CGRect barRect = self.view.bounds;
        barRect.size.height = kThumbsViewMoreHeight;
        
        barRect.origin.y = _quiltView.contentSize.height;
        
        getMoreview= [[UIView alloc] initWithFrame:barRect];
        getMoreview.backgroundColor=[UIColor clearColor];
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicator.center = CGPointMake(barRect.size.width/2, kThumbsViewMoreHeight/2);
        indicator.hidesWhenStopped = YES;
        indicator.color = HUD_SPINNER_COLOR;
        
        [getMoreview addSubview:indicator];
        
        [_quiltView addSubview:getMoreview];
    }
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
        
        MODebugLayer(_noDataView, 1.f, [UIColor redColor].CGColor);
    }
    return _noDataView;
}

- (UIView *)noNetworkView
{
    if (!_noNetworkView) {
        _noNetworkView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        int offsety = self.view.bounds.size.height / 3.0 ;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 60 + offsety, self.view.bounds.size.width-20, 50)];
        
        label.backgroundColor = [UIColor clearColor];
         label.text = NSLocalizedString(@"Network error, Pull down to refresh.", @"网络错误,请单击重连接");
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


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.quiltView = nil;
}

-(void)reLoadView
{
    [self.quiltView reloadData];
    
    CGRect barRect = self.view.bounds;
    barRect.origin.y = _quiltView.contentSize.height;
    getMoreview.frame = barRect;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - TMQuiltViewDataSource

- (NSInteger)quiltViewNumberOfCells:(TMQuiltView *)quiltView {
    return 0;
}

- (TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    TMQuiltViewCell *cell = [self.quiltView dequeueReusableCellWithReuseIdentifier:nil];
    if (!cell) {
        cell = [[TMQuiltViewCell alloc] initWithReuseIdentifier:nil];
    }
    return cell;
}


#pragma mark UIScrollViewDelegate
-(void)loadMoreView
{
    reloading = YES;
    
    [getMoreview setUserInteractionEnabled:NO];
    [indicator startAnimating];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    _quiltView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, kThumbsViewMoreHeight,0.0f);
    [UIView commitAnimations];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
//    if (currentOffset <= kAdvertisingResponse)
//        [_quiltView.delegate maybeShowAdvertising];
//    else if (currentOffset >= kAdvertisingResponse)
//        [_quiltView.delegate maybeHideAdvertising];
//    
    // Change 20.0 to adjust the distance from bottom

	if (reloading) return;
    
    if (currentOffset>0 && currentOffset - maximumOffset >= kThumbsViewMoreHeight)
    {
        [_quiltView.delegate nextPage];
    }

	if (checkForRefresh)
	{
		if (refreshHeaderView.isFlipped
			&& scrollView.contentOffset.y > -kRefreshkShowAll-5
			&& scrollView.contentOffset.y < 0.0f
			&& !reloading) {
			[refreshHeaderView flipImageAnimated:YES];
			[refreshHeaderView setStatus:kMOPullToReloadStatus];
			
		} else if (!refreshHeaderView.isFlipped
				   && scrollView.contentOffset.y < -kRefreshkShowAll-5) {
			[refreshHeaderView flipImageAnimated:YES];
			[refreshHeaderView setStatus:kMOReleaseToReloadStatus];
			
		}
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	if (!reloading)
	{
		checkForRefresh = YES;  //only check offset when dragging
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (showHeaderView && !reloading)
	{
		if (scrollView.contentOffset.y <= -kRefreshkShowAll + 10)
		{
			[refreshHeaderView toggleActivityView:YES];
			
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.2];
			_quiltView.contentInset = UIEdgeInsetsMake(kRefreshkShowAll, 0.0f, 0.0f,0.0f);
			[UIView commitAnimations];
			
			_quiltView.contentOffset=scrollView.contentOffset;
            
            reloading = YES;
            [_quiltView.delegate refreshData];
			
		}
		checkForRefresh = NO;
	}
}

@end
