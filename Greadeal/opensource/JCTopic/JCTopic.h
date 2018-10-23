//
//  JCTopic.h
//  PSCollectionViewDemo
//
//  Created by taotao on 14-1-7.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ICPageControlPosition)
{
    ICPageControlPosition_TopLeft,
    ICPageControlPosition_TopCenter,
    ICPageControlPosition_TopRight,
    ICPageControlPosition_BottomLeft,
    ICPageControlPosition_BottomCenter,
    ICPageControlPosition_BottomRight
};

@protocol JCTopicDelegate<NSObject>

-(void)didClick:(int)nIndex;
//-(void)currentPage:(int)page total:(NSUInteger)total;

@end

@interface JCTopic : UIView<UIScrollViewDelegate>{
    bool           flag;
    int            scrollTopicFlag;
    NSTimer        *scrollTimer;
    int            currentPage;
    CGSize         imageSize;
    UIImage        *image;
    
    UIScrollView   *cycleView;
    
    UIPageControl  *pageControl;
}

@property(nonatomic,strong)   NSArray *pics;
@property(nonatomic,strong)   id<JCTopicDelegate>JCdelegate;

-(void)releaseTimer;
-(void)upDate:(NSString*)defaultPng;

@end
