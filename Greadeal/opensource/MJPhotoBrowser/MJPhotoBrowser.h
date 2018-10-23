//
//  MJPhotoBrowser.h
//
//  Created by tao on 15-3-4.
//  Copyright (c) 2015年

#import <UIKit/UIKit.h>

@protocol MJPhotoBrowserDelegate;

@interface MJPhotoBrowser : UIViewController <UIScrollViewDelegate>
{
    UILabel          *pageLabel;
    UIPageControl    *pageControl;
    BOOL             isDelete;
}
// 代理
@property (nonatomic, weak) id<MJPhotoBrowserDelegate> delegate;
// 所有的图片对象
@property (nonatomic, strong) NSMutableArray * photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;

// 显示
- (void)show;
- (id)init:(BOOL)showDelete;

@end

@protocol MJPhotoBrowserDelegate <NSObject>

-(void)CellPhotoImageReload;

-(void)deleteImage:(NSInteger)ImageIndex;

@optional

- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index;

@end