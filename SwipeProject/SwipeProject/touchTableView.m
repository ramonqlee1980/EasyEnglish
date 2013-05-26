//
//  touchTableView.m
//  SwipeToTransferDemo
//
//  Created by lijiangang on 13-4-17.
//  Copyright (c) 2013年 lijiangang. All rights reserved.
//

#import "touchTableView.h"

@implementation touchTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
	{
    	    [super touchesBegan:touches withEvent:event];
    
    	    if (_touchDelegate && [_touchDelegate respondsToSelector:@selector(tableView:touchesBegan:withEvent:)])
        	    {
            	        [_touchDelegate tableView:self touchesBegan:touches withEvent:event];
            	}
    	}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
   	    [super touchesCancelled:touches withEvent:event];
    
   	    if (_touchDelegate &&[_touchDelegate respondsToSelector:@selector(tableView:touchesCancelled:withEvent:)])
        	    {
           	        [_touchDelegate tableView:self touchesCancelled:touches withEvent:event];
            	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    	    [super touchesEnded:touches withEvent:event];
   
    	    if (_touchDelegate &&[_touchDelegate respondsToSelector:@selector(tableView:touchesEnded:withEvent:)])
        	    {
            	        [_touchDelegate tableView:self touchesEnded:touches withEvent:event];
            	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    	    [super touchesMoved:touches withEvent:event];
    
   	    if (_touchDelegate && [_touchDelegate respondsToSelector:@selector(tableView:touchesMoved:withEvent:)])
        	    {
           	        [_touchDelegate tableView:self touchesMoved:touches withEvent:event];
            	}
}

@end
