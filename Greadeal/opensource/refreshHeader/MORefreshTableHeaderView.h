//
//  EGORefreshTableHeaderView.h
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMOReleaseToReloadStatus	0
#define kMOPullToReloadStatus		1
#define kMOLoadingStatus			2
#define kMOShowName      			3

@interface MORefreshTableHeaderView : UIView {
	
	UILabel *lastUpdatedLabel;
	UILabel *statusLabel;
	UILabel *titleLabel;
	UIImageView *arrowImage;
	UIActivityIndicatorView *activityView;
	
	BOOL isFlipped;
	
	NSDate *lastUpdatedDate;
}
@property BOOL isFlipped;

@property (nonatomic, strong) NSDate *lastUpdatedDate;

- (void)flipImageAnimated:(BOOL)animated;
- (void)toggleActivityView:(BOOL)isON;
- (void)setStatus:(int)status;
- (void)setTitle:(NSString*)aTitle;

@end