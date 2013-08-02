//
//  NSString+StringThatFits.m
//  SwipeProject
//
//  Created by Ramonqlee on 7/23/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import "NSString+StringThatFits.h"

@implementation NSString (StringThatFits)
- (NSString *)stringByDeletingWordsFromStringToFit:(CGRect)rect
                                         withInset:(CGFloat)inset
                                         usingFont:(UIFont *)font
{
    NSString *result = [self copy];
    CGSize maxSize = CGSizeMake(rect.size.width  - (inset * 2), FLT_MAX);
    CGSize size = [result sizeWithFont:font
                     constrainedToSize:maxSize
                         lineBreakMode:UILineBreakModeWordWrap];
    NSRange range;
    
    if (rect.size.height < size.height)
        while (rect.size.height < size.height) {
            
            range = [result rangeOfString:@" "
                                  options:NSBackwardsSearch];
            
            if (range.location != NSNotFound && range.location > 0 ) {
                result = [result substringToIndex:range.location];
            } else {
                result = [result substringToIndex:result.length - 1];
            }
            
            size = [result sizeWithFont:font
                      constrainedToSize:maxSize
                          lineBreakMode:UILineBreakModeWordWrap];
        }
    
    return result;
}
@end
