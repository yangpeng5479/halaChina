//
//  UILabel+Addtional.m
//  WristCentralPos
//
//  Created by tao tao on 29/8/14.
//  Copyright (c) 2014 tao tao. All rights reserved.
//

#import "UILabel+Addtional.h"

@implementation UILabel (Addtional)

-(void)setTextColor:(UIColor *)textColor range:(NSRange)range
{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:self.text];
    NSMutableAttributedString * text = [[NSMutableAttributedString alloc] initWithAttributedString:str];
    [text addAttribute:NSForegroundColorAttributeName value:textColor range:range];
    [self setAttributedText:text];
}

-(void)setFont:(UIFont *)font range:(NSRange)range
{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:self.text];
    NSMutableAttributedString * text = [[NSMutableAttributedString alloc] initWithAttributedString:str];
    [text addAttribute:NSFontAttributeName value:font range:range];
    [self setAttributedText:text];
}

-(void)findCurrency:(int)nSize
{
    NSRange findrange = [self.text rangeOfString:[GDPublicManager instance].currency];
    if (findrange.location != NSNotFound && findrange.length!=0)
    {
        NSRange reage = NSMakeRange(findrange.location,[GDPublicManager instance].currency.length);
        UIFont *smallFont = MOLightFont(nSize);
        [self setFont:smallFont range:reage];
    }
}

-(void)findOff
{
    NSString* str = @"OFF";
    
    NSRange findrange = [self.text rangeOfString:@"OFF"];
    if (findrange.location != NSNotFound && findrange.length!=0)
    {
        NSRange reage = NSMakeRange(findrange.location,str.length);
        UIFont *smallFont = MOLightFont(12);
        [self setFont:smallFont range:reage];
    }

}

@end
