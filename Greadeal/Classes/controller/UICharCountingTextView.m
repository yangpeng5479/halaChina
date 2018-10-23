//
//  UICharCountingTextView.m
//  Mozat
//
//  Created by taotao on 8/4/13.
//  Copyright (c) 2012 MOZAT Pte Ltd. All rights reserved.
//

#import "UICharCountingTextView.h"
#import <QuartzCore/CALayer.h>

#define kLeftMargin			8
#define kTopMargin			8
#define kCountLabelHeight	16
#define kCountMarginTop     -3
#define kCornerRadius		8
#define kFontSize			16
#define kCountFontSize		14
#define kClearButtonWidth   (19 + 8)

@interface UICharCountingTextView ()
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UILabel *placeHolderLabel;
@property (nonatomic, retain) UILabel *countLabel;
@end

@implementation UICharCountingTextView
{
	UIButton *_btnClear;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	self.placeholder = nil;
	self.textView = nil;
    self.placeHolderLabel = nil;
	self.countLabel = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.placeholder = @"";
	[self addSubview:self.textView];
	self.backgroundColor = [UIColor whiteColor];
	self.layer.masksToBounds = YES;
	self.layer.cornerRadius = kCornerRadius;
}

- (id)initWithFrame:(CGRect)frame {
    if( (self = [super initWithFrame:frame])) {
		self.placeholder = @"";
		
		UIView *textContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - kCountLabelHeight)];
		textContainer.backgroundColor = [UIColor whiteColor];
		textContainer.layer.masksToBounds = YES;
		textContainer.layer.cornerRadius = kCornerRadius;
		textContainer.layer.borderColor = [UIColor grayColor].CGColor;
		textContainer.layer.borderWidth = 1.0;
		[textContainer addSubview:self.textView];
		[self addSubview:textContainer];
		self.backgroundColor = [UIColor clearColor];
//		[self addSubview:self.textView];
//		self.backgroundColor = [UIColor whiteColor];
//		self.layer.masksToBounds = YES;
//		self.layer.cornerRadius = kCornerRadius;
		
		UIImage *image = [UIImage imageNamed:@"clear.png"];
		const int SPACING = 8;
		_btnClear = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - image.size.width - SPACING * 2, textContainer.frame.size.height - image.size.height - SPACING * 2, image.size.width + SPACING * 2, image.size.height + SPACING * 2)];
		[_btnClear setImage:image forState:UIControlStateNormal];
		[_btnClear addTarget:self action:@selector(clearText) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_btnClear];
        
    }
    return self;
}

#pragma mark - Property Getter

-(void)clearText
{
	self.textView.text = @"";
	[self setNeedsDisplay];
	if ([self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
		[self.delegate textViewDidChange:self];
	}
}

- (void)setText:(NSString *)text {
	self.textView.text = text;
	[self setNeedsDisplay];
	if ([self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
		[self.delegate textViewDidChange:self];
	}
}

- (NSString *)text {
	return self.textView.text;
}

- (void)setSelectedRange:(NSRange)range {
	self.textView.selectedRange = range;
}

- (NSRange)selectedRange {
	return self.textView.selectedRange;
}

- (UITextView *)textView {
	if (_textView == nil) {
		_textView = [[UITextView alloc] initWithFrame:
					 CGRectMake(0,
								0,
								self.bounds.size.width - kClearButtonWidth,
								self.bounds.size.height - kCountLabelHeight)];
		_textView.delegate = self;
        [_textView setFont:MOLightFont(kFontSize)];
		_textView.backgroundColor = [UIColor clearColor];
		_textView.showsVerticalScrollIndicator = YES;
	}
	return _textView;
}

- (UILabel *)placeHolderLabel {
	if (_placeHolderLabel == nil) {
		_placeHolderLabel = [[UILabel alloc] initWithFrame:
							 CGRectMake(kLeftMargin,
										kTopMargin,
										self.bounds.size.width - 2 * kLeftMargin,
										0)];
		_placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
		_placeHolderLabel.numberOfLines = 0;
		_placeHolderLabel.backgroundColor = [UIColor clearColor];
		_placeHolderLabel.textColor = [UIColor lightGrayColor];
        _placeHolderLabel.textAlignment = [GDSettingManager instance].isRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
		_placeHolderLabel.font = [self.textView.font fontWithSize:kFontSize];
        MODebugLayer(_placeHolderLabel, 1.f, [UIColor redColor].CGColor);
		_placeHolderLabel.alpha = 0;
	}
	return _placeHolderLabel;
}

- (UILabel *)countLabel {
	if (_countLabel == nil) {
		_countLabel = [[UILabel alloc] initWithFrame:
							   CGRectMake(kLeftMargin,
										  //self.textView.frame.origin.y + self.textView.frame.size.height + kCountMarginTop,
										  self.frame.size.height - kCountLabelHeight,
										  self.bounds.size.width - 2 * kLeftMargin,
										  kCountLabelHeight)];
		_countLabel.backgroundColor = [UIColor clearColor];
		_countLabel.font = [self.textView.font fontWithSize:kCountFontSize];
		_countLabel.alpha = 0.6;
		_countLabel.textAlignment = NSTextAlignmentRight;
		_countLabel.text = [NSString stringWithFormat:@"%lu",
							(unsigned long)(self.maxNumberOfCharacter-self.textView.text.length)];
	}
	return _countLabel;
}

- (void)drawRect:(CGRect)rect {
    if (self.placeholder.length > 0 ) {
        if (self.placeHolderLabel.superview == nil) {
            [self.textView addSubview:self.placeHolderLabel];
        }
		
        self.placeHolderLabel.text = self.placeholder;
        [self.placeHolderLabel sizeToFit];
        CGRect frame = self.placeHolderLabel.frame;
        frame.size.width = self.textView.bounds.size.width - 2 * kLeftMargin;
        self.placeHolderLabel.frame = frame;
        [self.textView sendSubviewToBack:self.placeHolderLabel];
		
		if(self.textView.text.length == 0) {
			self.placeHolderLabel.alpha = 1.f;
		} else {
			self.placeHolderLabel.alpha = 0.f;
		}
    } else {
		if (self.placeHolderLabel.superview != nil) {
			[self.placeHolderLabel removeFromSuperview];
		}
	}
	
	if (self.countLabel.superview == nil) {
		[self addSubview:self.countLabel];
	}
	
	if (self.textView.isFirstResponder) {
		self.countLabel.text = [NSString stringWithFormat:@"%lu",
								(unsigned long)(self.maxNumberOfCharacter-self.textView.text.length)];
		self.countLabel.hidden = NO;
	} else {
		self.countLabel.hidden = YES;
	}
	
	_btnClear.hidden = (isEmptyString(self.textView.text));
	
    [super drawRect:rect];
}


#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
	[self setNeedsDisplay];
	if ([self.delegate respondsToSelector:@selector(textViewDidBeginEditing:)]) {
		[self.delegate textViewDidBeginEditing:self];
	}
}

- (void)textViewDidChange:(UITextView *)textView {
	[self setNeedsDisplay];
	if ([self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
		[self.delegate textViewDidChange:self];
	}
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	[self setNeedsDisplay];
	if ([self.delegate respondsToSelector:@selector(textViewDidEndEditing:)]) {
		[self.delegate textViewDidEndEditing:self];
	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
	BOOL flag = YES;
	if ([self.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
		flag = [self.delegate textView:self shouldChangeTextInRange:range replacementText:text];
	}
	if(!flag) return flag;
	
	NSUInteger newLength = textView.text.length + text.length - range.length;
	if (newLength <= self.maxNumberOfCharacter)
	{
		return YES;
	}
	//Trim text manually.
	//!!!Note: Selection is not supported yet.
	else
	{
		textView.text = [[textView.text stringByAppendingString:text] substringToIndex:self.maxNumberOfCharacter];
		[self setNeedsDisplay];
		return NO;
	}
	
//	return (self.maxNumberOfCharacter >= newLen) && flag;
}

#pragma mark - Override methods

- (BOOL)canBecomeFirstResponder {
	return [self.textView canBecomeFirstResponder];
}

- (BOOL)canResignFirstResponder {
	return [self.textView canResignFirstResponder];
}

- (BOOL)becomeFirstResponder {
	if ([self.textView becomeFirstResponder]) {
		[self setNeedsDisplay];
		return YES;
	}
	return NO;
}

- (BOOL)resignFirstResponder {
	if ([self.textView resignFirstResponder]) {
		[self setNeedsDisplay];
		return YES;
	}
	return NO;
}

@end
