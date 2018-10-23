//
//  UACellBackgroundView.h
//  FlatUI
//
//  Created by Maciej Swic on 2013-05-30.
//  Licensed under the MIT license.

typedef enum  {
	FUICellBackgroundViewPositionSingle = 0,
	FUICellBackgroundViewPositionTop,
	FUICellBackgroundViewPositionBottom,
	UACellBackgroundViewPositionMiddle
} FUICellBackgroundViewPosition;

typedef enum {
    FUICellBackgroundViewTypeDefault,
    FUICellBackgroundViewTypeSelected
}FUICellBackgroundViewType;

@interface FUICellBackgroundView : UIView

@property (nonatomic) FUICellBackgroundViewPosition position;
@property (nonatomic) FUICellBackgroundViewType type;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic, retain) UIColor* separatorColor;
@property (nonatomic) CGFloat strokeWidth;

@end
