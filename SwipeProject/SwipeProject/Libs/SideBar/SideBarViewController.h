//
//  SideBarViewController.h
//  SwipeToTransferDemo
//
//  Created by lijiangang on 13-4-18.
//  Copyright (c) 2013年 lijiangang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SideBarViewControllerDelegate;

typedef enum _SideBarShowDirection
{
    SideBarShowDirectionNone = 0,
    SideBarShowDirectionLeft = 1,
    SideBarShowDirectionRight = 2
}SideBarShowDirection;

@protocol SiderBarDelegate <NSObject>
- (void)leftSideBarSelectWithController:(UIViewController *)controller;
- (void)rightSideBarSelectWithController:(UIViewController *)controller;
- (void)showSideBarControllerWithDirection:(SideBarShowDirection)direction;
@end

/**
 Delegate when SideBarViewController is initialized
 left and right view controller should be provided,nil is allowed
 */
@protocol SideBarViewControllerDelegate <NSObject>
- (UIViewController*)middleViewController;
-(UIViewController*)leftViewController:(id<SiderBarDelegate>)delegate;
-(UIViewController*)rightViewController:(id<SiderBarDelegate>)delegate;
@end

@interface SideBarViewController : UIViewController<UINavigationControllerDelegate,SiderBarDelegate>
@property (nonatomic,retain)id<SideBarViewControllerDelegate> delegate;
@property (strong,nonatomic)IBOutlet UIView *contentView;
@property (strong,nonatomic)IBOutlet UIView *navBackView;


- (void)showSideBarControllerWithDirection:(SideBarShowDirection)direction;
@end

