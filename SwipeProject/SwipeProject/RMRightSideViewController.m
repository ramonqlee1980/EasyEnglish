//
//  RMRightSideViewController.m
//  SwipeProject
//
//  Created by ramonqlee on 5/4/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import "RMRightSideViewController.h"
#import "RMTabbedViewController.h"
#import "SideBarViewController.h"
//const
static NSString* reuseIdentifier = @"UITableViewCellStyleDefault";

//index for controller construction
#define kPopularMakeupIndex 0
#define kCityBeautyMakeup 1

@interface RMRightSideViewController ()

@end

@implementation RMRightSideViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //set current view's width to accord with sideview
    CGRect rc = self.view.frame;
    rc.size.width = kDeviceWidth-kSideBarMargin;
    self.view.frame = rc;
    
	// Do any additional setup after loading the view.
    //TODO::load needed views
    //1.header view on top navigation level
    // icon
    //2.body view with a tableview
    [self addSections];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark add diffrent sections

-(void)addTopSection
{
    //TODO:: popular channels
    //localizedstring to be added
    //respond to whenSelected
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        //时尚妆容
		[section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
			staticContentCell.reuseIdentifier =reuseIdentifier;
			cell.selectionStyle = UITableViewCellStyleValue1;
            cell.accessoryType = UITableViewCellAccessoryNone;
            
			cell.textLabel.text = NSLocalizedString(@"PopularMakeup", @"");
            cell.textLabel.textAlignment = NSTextAlignmentRight;
		} whenSelected:^(NSIndexPath *indexPath) {
			if (delegate && [delegate respondsToSelector:@selector(leftSideBarSelectWithController:)])
            {
                [delegate rightSideBarSelectWithController:[self subController:kPopularMakeupIndex]];
            }
		}];
        
        //都市丽人
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
			staticContentCell.reuseIdentifier =reuseIdentifier;
			cell.selectionStyle = UITableViewCellStyleValue1;
            cell.accessoryType = UITableViewCellAccessoryNone;
            
			cell.textLabel.text = NSLocalizedString(@"CityBeautyMakeup", @"");
            cell.textLabel.textAlignment = NSTextAlignmentRight;            
		} whenSelected:^(NSIndexPath *indexPath) {
			if (delegate && [delegate respondsToSelector:@selector(leftSideBarSelectWithController:)])
            {
                [delegate rightSideBarSelectWithController:[self subController:kCityBeautyMakeup]];
            }
		}];
        
	}];
}

-(void)addBodySection
{
    //TODO::my favorite
}
-(void)addSections
{
    [self addTopSection];
    [self addBodySection];
    [self.tableView reloadData];
}
#pragma mark viewcontrollers
-(UIViewController*)subController:(NSInteger)index
{
    //kPopularMakeupIndex
    return [[[RMTabbedViewController alloc]init]autorelease];
}

@end
