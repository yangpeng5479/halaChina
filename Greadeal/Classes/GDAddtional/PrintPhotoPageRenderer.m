
#import "PrintPhotoPageRenderer.h"
#define LineSpace 40
@implementation PrintPhotoPageRenderer

@synthesize dictToPrint;

// This code always draws one image at print time.
-(NSInteger)numberOfPages
{
  return 1;
}

/*  When using this UIPrintPageRenderer subclass to draw a photo at print
    time, the app explicitly draws all the content and need only override
    the drawPageAtIndex:inRect: to accomplish that.
 
    The following scaling algorithm is implemented here:
    1) On borderless paper, users expect to see their content scaled so that there is
	no whitespace at the edge of the paper. So this code scales the content to
	fill the paper at the expense of clipping any content that lies off the paper.
    2) On paper which is not borderless, this code scales the content so that it fills
	the paper. This reduces the size of the photo but does not clip any content.
*/
- (void)drawPageAtIndex:(NSInteger)pageIndex inRect:(CGRect)printableRect
{
  if(self.dictToPrint!=nil)
  {
    // When drawPageAtIndex:inRect: paperRect reflects the size of
    // the paper we are printing on and printableRect reflects the rectangle
    // describing the imageable area of the page, that is the portion of the page
    // that the printer can mark without clipping.
      CGSize paperSize = self.paperRect.size;
      
//    @"billRecord"
//    @"totalprice"
//    @"tax"
//    @"cash"
//    @"paymenttype"
      float offsetX = 60;
      float offsetY = 60;
      float cellWidth = paperSize.width-offsetX*2;
      
      UIFont* titleFont =   [UIFont boldSystemFontOfSize:18];
      UIFont* contextFont = [UIFont systemFontOfSize:16];
      
      NSString* strTitle = @"JUMPSTAR";
      CGSize titleSize = [strTitle moSizeWithFont:titleFont withWidth:320];
      
      [strTitle moDrawInRect:CGRectMake((paperSize.width-titleSize.width-offsetX)/2+30, offsetY,titleSize.width, 30) withFont:titleFont textColor:[UIColor blackColor]];

      float dx=offsetX;
      offsetY+=LineSpace;
      
      NSArray* billTitle = dictToPrint[@"billTitle"];
      for (int i = 0; i<billTitle.count;i++)//0.4,0.15
      {
          float colWidth;
          if (i==0)
              colWidth = cellWidth *0.4;
          else
              colWidth = cellWidth *0.15;
          
          NSString* col1 = [billTitle objectAtIndex:i];
          
          [col1 moDrawInRect:CGRectMake(dx, offsetY,colWidth, LineSpace) withFont:contextFont textColor:[UIColor blackColor]];
          
          dx += colWidth;

      }
      
      NSMutableArray* billRecord = dictToPrint[@"billRecord"];
      
      for (NSDictionary* obj in billRecord)
      {
          NSString*  post_name = obj[@"post_name"];
          double     price = [obj[@"price"] doubleValue];
          NSString*  qty = obj[@"qty"];
          NSString*  disc = obj[@"disc"];
          
          float dx=offsetX;
          offsetY+=LineSpace;
          
          for (int i = 0; i<billTitle.count;i++)
          {
              float colWidth;
              if (i==0)
                  colWidth = cellWidth *0.4;
              else
                  colWidth = cellWidth *0.15;
              
              NSString* col1;

              switch (i) {
                  case 0:
                      col1 = post_name;
                      break;
                  case 1:
                      col1=[NSString stringWithFormat:@"s$%.2f",price];
                      break;
                  case 2:
                      col1=[NSString stringWithFormat:@"   %@",disc];
                      break;
                  case 3:
                      col1=qty;
                      break;
                  case 4:
                      col1=[NSString stringWithFormat:@"s$%.2f",price*[qty intValue]*(1.0-[disc floatValue])];
                    }
               [col1 moDrawInRect:CGRectMake(dx, offsetY,colWidth, LineSpace) withFont:contextFont textColor:[UIColor blackColor]];
             
               dx += colWidth;
          }
         
      }
      offsetY+=LineSpace;
      //print Subtotal:s$  Tax:s$  Total:s$
      float subtotal = [dictToPrint[@"subtotal"] floatValue];
      float tax = [dictToPrint[@"tax"] floatValue];
     
      float total = subtotal+tax;
      
      dx=offsetX;
      NSString* col1;
      col1 = [NSString stringWithFormat:@"Subtotal:s$%.2f              Tax:s$%.2f                Total:s$%.2f ",subtotal,tax,total];
      [col1 moDrawInRect:CGRectMake(dx, offsetY,cellWidth, LineSpace) withFont:contextFont textColor:[UIColor blackColor]];
      
      offsetY+=LineSpace;
  }
  
}

@end
