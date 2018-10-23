//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//

#import "MORefreshTableHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "MOColor.h"

//#define TEXT_COLOR [UIColor colorWithRed:0.341 green:0.737 blue:0.537 alpha:1.0]
//#define BORDER_COLOR [UIColor colorWithRed:0.341 green:0.737 blue:0.537 alpha:1.0]

@implementation MORefreshTableHeaderView

@synthesize isFlipped, lastUpdatedDate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame]; if(self)
	{
        self.backgroundColor = [UIColor colorWithRed:242/255.0 green:244/255.0 blue:245/255.0 alpha:1.0];
    
		titleLabel= [[UILabel alloc] initWithFrame:
					 CGRectMake(0.0f, frame.size.height - 20.0f, frame.size.width, 20.0f)];
		titleLabel.font = MOBlodFont(16);
		titleLabel.textColor = [UIColor blackColor];
		titleLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		titleLabel.backgroundColor = self.backgroundColor;
		titleLabel.opaque = YES;
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		[self addSubview:titleLabel];

		
		lastUpdatedLabel = [[UILabel alloc] initWithFrame:
							CGRectMake(0.0f, frame.size.height - 50.0f, frame.size.width, 20.0f)];
		lastUpdatedLabel.font = MOLightFont(14);
		lastUpdatedLabel.textColor = [UIColor grayColor];
		lastUpdatedLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		lastUpdatedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		lastUpdatedLabel.backgroundColor = self.backgroundColor;
		lastUpdatedLabel.opaque = YES;
		lastUpdatedLabel.textAlignment = NSTextAlignmentCenter;
		lastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		[self addSubview:lastUpdatedLabel];
		
		statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, frame.size.width, 20.0f)];
		statusLabel.font = MOBlodFont(16);
		statusLabel.textColor = [UIColor grayColor];
		statusLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		statusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		statusLabel.backgroundColor = self.backgroundColor;
		statusLabel.opaque = YES;
		statusLabel.textAlignment = NSTextAlignmentCenter;
		statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		[self setStatus:kMOPullToReloadStatus];
		[self addSubview:statusLabel];
		
		arrowImage = [[UIImageView alloc] initWithFrame:
					  CGRectMake(25.0f, frame.size.height
								 - 60.0f, 30.0f, 55.0f)];
		arrowImage.contentMode = UIViewContentModeScaleAspectFit;
		arrowImage.image = [UIImage imageNamed:@"blueArrow.png"];
		[arrowImage layer].transform =
		CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
		//[self addSubview:arrowImage];
		
		activityView = [[UIActivityIndicatorView alloc]
						initWithActivityIndicatorStyle:
						UIActivityIndicatorViewStyleGray];
		activityView.frame = CGRectMake(60, frame.size.height
										- 30.0f, 20.0f, 20.0f);
		activityView.hidesWhenStopped = YES;
		[self addSubview:activityView];
		activityView.color = HUD_SPINNER_COLOR;
		isFlipped = NO;
		
    }
    return self;
}


- (void)flipImageAnimated:(BOOL)animated
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:animated ? .18 : 0.0];
	[arrowImage layer].transform = isFlipped ?
	CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f) :
	CATransform3DMakeRotation(M_PI * 2, 0.0f, 0.0f, 1.0f);
	[UIView commitAnimations];
	
	isFlipped = !isFlipped;
}

- (void)setTitle:(NSString*)aTitle
{
	titleLabel.text=aTitle;
}

- (void)setLastUpdatedDate:(NSDate *)newDate
{
	if (newDate)
	{
		if (lastUpdatedDate != newDate)
		{
			lastUpdatedDate = newDate;
		}
		
		NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:NSDateFormatterShortStyle];
		[formatter setTimeStyle:NSDateFormatterShortStyle];
		lastUpdatedLabel.text = [NSString stringWithFormat:
								 @"Last Updated: %@", [formatter stringFromDate:lastUpdatedDate]];
	}
	else
	{
		lastUpdatedDate = nil;
		lastUpdatedLabel.text = @"Last Updated: Unknown";
	}
}

- (void)setStatus:(int)status
{
	arrowImage.hidden=NO;
	switch (status) {
		case kMOReleaseToReloadStatus:
			statusLabel.text = @"Release to refresh";
			break;
		case kMOPullToReloadStatus:
			statusLabel.text = @"Pull down to refresh";
			break;
		case kMOLoadingStatus:
			statusLabel.text = @"Loading...";
			break;
		case kMOShowName:
			statusLabel.text = @"";
			arrowImage.hidden=YES;
			break;
		default:
			break;
	}
}

- (void)toggleActivityView:(BOOL)isON
{
	if (!isON)
	{
		[activityView stopAnimating];
		arrowImage.hidden = NO;
	}
	else
	{
		[activityView startAnimating];
		arrowImage.hidden = YES;
		[self setStatus:kMOLoadingStatus];
	}
}


@end