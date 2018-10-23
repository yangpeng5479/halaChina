//
//  UICharCountingTextView.h
//  Mozat
//
//  Created by taotao on 8/4/13.
//  Copyright (c) 2012 MOZAT Pte Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UICharCountingTextView;
@protocol UICharCountingTextViewDelegate <NSObject>
@optional
- (void)textViewDidBeginEditing:(UICharCountingTextView *)textView;
- (void)textViewDidEndEditing:(UICharCountingTextView *)textView;

- (BOOL)textView:(UICharCountingTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)textViewDidChange:(UICharCountingTextView *)textView;
@end

@interface UICharCountingTextView : UIView <UITextViewDelegate>

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, assign) NSUInteger maxNumberOfCharacter;
@property (nonatomic, assign) id<UICharCountingTextViewDelegate> delegate;



- (void)setText:(NSString *)text;
- (NSString *)text;

- (void)setSelectedRange:(NSRange)range;
- (NSRange)selectedRange;
@end
