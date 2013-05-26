//
//  touchTableView.h
//  SwipeToTransferDemo
//
//  Created by lijiangang on 13-4-17.
//  Copyright (c) 2013年 lijiangang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TouchTableViewDelegate;

@interface touchTableView : UITableView

@property (nonatomic,assign) id<TouchTableViewDelegate> touchDelegate;

@end

@protocol TouchTableViewDelegate <NSObject>
@optional
- (void)tableView:(UITableView *)tableView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)tableView:(UITableView *)tableView touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)tableView:(UITableView *)tableView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)tableView:(UITableView *)tableView touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
@end