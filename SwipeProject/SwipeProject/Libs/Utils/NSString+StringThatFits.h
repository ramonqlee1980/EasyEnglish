//
//  NSString+StringThatFits.h
//  SwipeProject
//
//  Created by Ramonqlee on 7/23/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (StringThatFits)
- (NSString *)stringByDeletingWordsFromStringToFit:(CGRect)rect
                                         withInset:(CGFloat)inset
                                         usingFont:(UIFont *)font;
@end
