//
//  JCTopic.m
//  PSCollectionViewDemo
//
//  Created by taotao on 14-1-7.
//
//

#import "JCTopic.h"

#define preDotWidth  15
#define timeInterval 4

@implementation JCTopic
@synthesize JCdelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
      
        cycleView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:cycleView];
        
        cycleView.pagingEnabled = YES;
        cycleView.scrollEnabled = YES;
        cycleView.delegate = self;
        cycleView.showsHorizontalScrollIndicator = NO;
        cycleView.showsVerticalScrollIndicator = NO;
        cycleView.backgroundColor = MOColorAppBackgroundColor();
        
        pageControl = [[UIPageControl alloc] init];
        pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        pageControl.currentPageIndicatorTintColor = MOAppTextBackColor();
        pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        [self addSubview:pageControl];
    
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
}

-(void)upDate:(NSString*)defaultPng
{
    CGRect selfRect = self.bounds;
    float  offsetX  = 5;
    pageControl.numberOfPages = self.pics.count;
    pageControl.currentPage = 0;
    
    if ([GDSettingManager instance].isRightToLeft)
    {
        pageControl.frame = CGRectMake(offsetX, selfRect.size.height-pageControlHeight, preDotWidth*self.pics.count,pageControlHeight);
    }
    else
    {
        pageControl.frame = CGRectMake(selfRect.size.width-offsetX-preDotWidth*self.pics.count, selfRect.size.height-pageControlHeight, preDotWidth*self.pics.count,pageControlHeight);
    }
    
    MODebugLayer(pageControl, 1.f, [UIColor redColor].CGColor);
    if (self.pics.count>0)
    {
    NSMutableArray * tempImageArray = [[NSMutableArray alloc]init];
    
    [tempImageArray addObject:[self.pics lastObject]];
    for (id obj in self.pics) {
        [tempImageArray addObject:obj];
    }
    [tempImageArray addObject:[self.pics objectAtIndex:0]];
    self.pics = Nil;
    self.pics = tempImageArray;
    
    int i = 0;
    for (NSString* obj in self.pics) {
       
        UIImageView * tempImage = [[UIImageView alloc]initWithFrame:CGRectMake(i*self.frame.size.width,0, self.frame.size.width, self.frame.size.height)];
        tempImage.contentMode = UIViewContentModeScaleAspectFill;
        [tempImage setClipsToBounds:YES];
        tempImage.userInteractionEnabled = YES;
        [tempImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
        tempImage.tag = i;
      
        [tempImage sd_setImageWithURL: [NSURL URLWithString:[obj encodeUTF]] placeholderImage:[UIImage imageNamed:defaultPng]];
        [cycleView addSubview:tempImage];

         i++;
    }
    [cycleView setContentSize:CGSizeMake(self.frame.size.width*[self.pics count], self.frame.size.height)];
    [cycleView setContentOffset:CGPointMake(self.frame.size.width, 0) animated:NO];
    
    if (scrollTimer) {
        [scrollTimer invalidate];
        scrollTimer = nil;
        
    }
    if ([self.pics count]>3) {
        scrollTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(scrollTopic) userInfo:nil repeats:YES];
    }
    }
}

- (void)handleTapGesture:(UIGestureRecognizer *)tapGesture
{
    //UIImageView *imageView = (UIImageView *)tapGesture.view;
   // int index = (int)imageView.tag;
    [JCdelegate didClick:(int)pageControl.currentPage];
}

-(void)click:(id)sender
{
    //[JCdelegate didClick:[sender tag]];
    //[JCdelegate didClick:[self.pics objectAtIndex:[sender tag]]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat Width=self.frame.size.width;
    if (scrollView.contentOffset.x == self.frame.size.width) {
        flag = YES;
    }
    if (flag) {
        if (scrollView.contentOffset.x <= 0) {
            [cycleView setContentOffset:CGPointMake(Width*([self.pics count]-2), 0) animated:NO];
        }else if (scrollView.contentOffset.x >= Width*([self.pics count]-1)) {
            [cycleView setContentOffset:CGPointMake(self.frame.size.width, 0) animated:NO];
        }
    }
    currentPage = scrollView.contentOffset.x/self.frame.size.width-1;
    //[JCdelegate currentPage:currentPage total:[self.pics count]-2];
    scrollTopicFlag = currentPage+2==2?2:currentPage+2;
    
    pageControl.numberOfPages = [self.pics count]-2;
    pageControl.currentPage = currentPage;
}

-(void)scrollTopic
{
    [cycleView setContentOffset:CGPointMake(self.frame.size.width*scrollTopicFlag, 0) animated:YES];
    
    if (scrollTopicFlag > [self.pics count]) {
        scrollTopicFlag = 1;
    }else {
        scrollTopicFlag++;
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    scrollTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(scrollTopic) userInfo:nil repeats:YES];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollTimer) {
        [scrollTimer invalidate];
        scrollTimer = nil;
    }
}

-(void)releaseTimer{
    if (scrollTimer) {
        [scrollTimer invalidate];
        scrollTimer = nil;
    }
}

@end
