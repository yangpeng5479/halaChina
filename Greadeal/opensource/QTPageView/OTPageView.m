//
//  OTPageView.m
//  OTPageScrollView
//
//  Created by yechunxiao on 14-12-10.
//  Copyright (c) 2014年 Oolong Tea. All rights reserved.
//

#import "OTPageView.h"

@implementation OTPageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.pageScrollView = [[OTPageScrollView alloc] init];
        [self.pageScrollView setPagingEnabled:YES];
        [self.pageScrollView setClipsToBounds:NO];
        self.pageScrollView.pageViewWith = self.frame.size.width;
        [self addSubview:self.pageScrollView];
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height-pageControlHeight, frame.size.width, pageControlHeight)];
        self.pageControl.currentPageIndicatorTintColor = MOAppTextBackColor();
        self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
        [self addSubview:self.pageControl];
        
        self.pageLabel  = [[UILabel alloc] init];
        self.pageLabel.textAlignment = NSTextAlignmentRight;
        self.pageLabel.backgroundColor = [UIColor clearColor];
        self.pageLabel.textColor = MOAppTextBackColor();
        self.pageLabel.font = MOLightFont(16);
        self.pageLabel.numberOfLines = 0;
        self.pageLabel.frame = CGRectMake(0,frame.size.height-pageControlHeight-5, frame.size.width-20, pageControlHeight);
        [self addSubview:self.pageLabel];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(self.pageScrollView.frame, point)) {
        return self.pageScrollView;
    }
    return [super hitTest:point withEvent:event];
}

@end
