//
//  GDMessageViewController.h
//  Mozat
//
//  Created by taotao on 7/13/13.
//  Copyright (c) 2013 MOZAT Pte Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICharCountingTextView.h"

@interface GDMessageViewController : UIViewController <UICharCountingTextViewDelegate>
{
	id			 target;
	SEL			 callback;

	UICharCountingTextView *inputTextView;
}
- (id)init:(id)aTarget action:(SEL)action;
@end
