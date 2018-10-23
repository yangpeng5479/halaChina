
#import <UIKit/UIKit.h>
#import "NSString+Addtional.h"

@interface PrintPhotoPageRenderer : UIPrintPageRenderer {
        NSMutableDictionary *dictToPrint;
}

@property (readwrite, retain) NSMutableDictionary *dictToPrint;

@end
