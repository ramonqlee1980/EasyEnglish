//
//  RMDailyArticlesViewController.m
//  SwipeProject
//
//  Created by Ramonqlee on 7/22/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import "RMDailyArticlesViewController.h"
#import "RMAppDelegate.h"
#import "FileModel.h"
#import "CommonHelper.h"
#import "HTTPHelper.h"
#import "RMArticle.h"
#import "AudioPlayer.h"
#import "UIViewController+MMDrawerController.h"
#import "AudioButton.h"
#import "PMCalendar.h"
#import "RMArticleCell.h"
#import "RMTextViewController.h"
#import "RMNavigationController.h"
#import "RMWebViewController.h"
#import "SettingsViewController.h"
#import "NSString+HTML.h"

#define kArticleCell @"RMArticleCell"
#define KReusableCellIdentifier kArticleCell

#define kMaxContentHeight 150.0f //this value can be disabled by a large value
#define kBottomMargin 15.0f
#define kTopMargin 15.0f

//TODO::url TBC
#define kDefaultResourceUrl @"http://y1.eoews.com/assets/ringtones/2012/5/18/34045/hi4dwfmrxm2citwjcc5841z3tiqaeeoczhbtfoex.mp3"
#define kDailySentenceUrl @"http://www.idreems.com/openapi/easyenglish.php?type=jokes&date=%@"

@interface RMDailyArticlesViewController ()<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate>
{
    FileModel* _fileModel;
    NSString* _resourceUrl;
    //    AudioPlayer *_audioPlayer;
    //    PMCalendarController *_pmCC;
    NSString* _date;
    BOOL shouldRefreshData;
    NSMutableArray* _dataArray;
    UITableView * _mTableView;
}
@property(nonatomic,assign)FileModel* fileModel;
@property(nonatomic,copy)NSString* resourceUrl;
//@property(nonatomic,copy)NSString* audioUrl;
//@property (nonatomic, assign) PMCalendarController *pmCC;
@property(nonatomic,copy)NSString* date;
@property(nonatomic,retain)NSMutableArray* dataArray;
@property(nonatomic,retain)UITableView * mTableView;
@end

@implementation RMDailyArticlesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc
{
    self.fileModel = nil;
    self.resourceUrl = nil;
    self.date = nil;
    self.dataArray = nil;
    self.mTableView = nil;
    [super dealloc];
}
//-(void)setFrame:(CGRect)rc
//{
//    self.view.frame = rc;
//}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if(!_mTableView)
    {
        _mTableView = [[UITableView  alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    }
    self.mTableView.delegate = self;
    self.mTableView.dataSource = self;
    [self.view addSubview:self.mTableView];
    
    //start to load data
    _fileModel = [[FileModel alloc]init];
    
    NSString* path = [self startNetworkRequest];
    [self updateViews:path];
    
    [self.mTableView registerNib:[UINib nibWithNibName:kArticleCell bundle:nil] forCellReuseIdentifier:KReusableCellIdentifier];
    [self.mTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.mTableView setContentInset:UIEdgeInsetsMake(0, 0, kNavigationBarHeight, 0)];
    
    
    UIButton* drawerBtm = [UIButton buttonWithType:UIButtonTypeCustom];
    [drawerBtm setFrame:CGRectMake(kMarginToBoundaryX,kMarginToTopBoundary,kDefaultButtonSize,kDefaultButtonSize)];
    [drawerBtm setBackgroundImage:[UIImage imageNamed:kLeftSideBarButtonBackground] forState:UIControlStateNormal];
    [drawerBtm addTarget:self action:@selector(leftDrawerButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithCustomView:drawerBtm];
    [[self navigationItem] setLeftBarButtonItem:leftButton];
    [leftButton release];
    
    
    UIButton* settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingBtn setFrame:CGRectMake(0,0,kDefaultButtonSize,kDefaultButtonSize)];
    [settingBtn setImage:[UIImage imageNamed:kRightSideBarButtonBackground] forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(settingClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithCustomView:settingBtn];
    [[self navigationItem] setRightBarButtonItem:rightButton];
    [rightButton release];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"head_background.png"] forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setUrl:(NSString*)url
{
    if(url)
    {
        self.resourceUrl = url;
    }
}
#pragma network utils
-(NSString*)startNetworkRequest
{
    //start request for data
    FileModel* model = [self fileModel];
    
    if(!_date)
    {
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        self.date = [formatter stringFromDate:[NSDate date]];
    }
    if(!self.resourceUrl)
    {
        self.resourceUrl = [NSString stringWithFormat:kDailySentenceUrl,_date];
    }
    
    model.fileURL = self.resourceUrl;//[NSString stringWithFormat:kDefaultResouceUrl,kInitPage];//for the latest page
    model.notificationName = kTimelineJsonRefreshChanged(self.resourceUrl);
    model.fileName =kRefreshFileName(self.resourceUrl);
    model.destPath = kDefaultFilePath;
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetServerData:)    name:kTimelineJsonRefreshChanged(self.resourceUrl)          object:nil];
    
    [[HTTPHelper sharedInstance] beginRequest:model isBeginDown:YES setAllowResumeForFileDownloads:NO];
    
    return [[CommonHelper getTargetBookPath:model.destPath] stringByAppendingPathComponent:model.fileName];
}
-(void)didGetServerData:(NSNotification*)notification
{
    if(notification)
    {
        if([notification.object isKindOfClass:[NSString class]])
        {
            [self updateViews:(NSString*)notification.object];
        }
        else if([notification.object isKindOfClass:[NSError class]])//error
        {
            //fail to load data
            [self GetErr:nil];
        }
    }
}

-(void) GetErr:(ASIHTTPRequest *)request
{
    if([self.view respondsToSelector:@selector(makeToast:)])
    {
        [self.view performSelectorOnMainThread:@selector(makeToast:) withObject:@"连接网络失败，请检查是否开启移动数据" waitUntilDone:YES];
    }
}
-(void)updateViews:(NSString*)fileName
{
    //FIXME::load data on background thread
    NSArray* data = [self loadContent:fileName];
    if(!_dataArray && data && data.count>0)
    {
        _dataArray = [[NSMutableArray alloc]initWithCapacity:data.count];
    }
    [_dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:data];
    
    if (data && data.count) {
        [self performSelectorOnMainThread:@selector(updateViewsOnMainThread) withObject:nil waitUntilDone:YES];
    }
}
-(void)updateViewsOnMainThread
{
    [self.mTableView reloadData];
}
//FIXME:load cache data within timeout
-(NSMutableArray*)loadContent:(NSString*)fileName
{
    NSMutableArray  *dataArray = [[[NSMutableArray alloc]initWithCapacity:0]autorelease];
    NSData* data = [NSData dataWithContentsOfFile:fileName];
    if (data) {
        NSError* error;
        id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (res && [res isKindOfClass:[NSArray class]]) {
            for (NSDictionary* item in (NSArray*)res) {
                RMArticle* sts = [RMArticle statusWithJsonDictionary:item];
                
                [dataArray addObject:sts];
            }
        } else {
            //NSLog(@"arr dataSourceDidError == %@",arrayData);
        }
    }
    return dataArray;
    
}

#pragma mark tableview datasource & delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray?self.dataArray.count:0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
#define kArticleHMargin 10
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RMArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:KReusableCellIdentifier];
    
    // Configure the cell...
    if (!cell) {
        cell = [[[RMArticleCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:KReusableCellIdentifier]autorelease];
    }
    UIImage *backgroundImage = [UIImage imageNamed:@"block_background.png"];
    backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 320, 14, 0)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:backgroundImage];
    [cell setBackgroundView:imageView];
    [imageView release];
    
    //
    RMArticle* data = [self.dataArray objectAtIndex:indexPath.row];
    [cell.title setBackgroundColor:[UIColor clearColor]];
    
    cell.title.text = data.title;
    cell.title.font = kUIFont4Title;
    cell.title.lineBreakMode = NSLineBreakByTruncatingTail;
    
    UIFont* contentFont = kUIFont4Content;
    CGSize max = CGSizeMake(kDeviceWidth-2*kArticleHMargin, kMaxContentHeight);
    NSString* content = data.content;
    //if([NSString respondsToSelector:@selector(stringByConvertingHTMLToPlainText)])
    {
        content = [content performSelector:@selector(stringByConvertingHTMLToPlainText)];
    }
    
    CGSize expected = [content sizeWithFont:contentFont constrainedToSize:max lineBreakMode:NSLineBreakByTruncatingTail];
    expected.height = MIN(kMaxContentHeight,expected.height);
    CGRect frame = cell.title.frame;
    frame.origin.y = kTopMargin;
    frame.size.height = kTitleFontSize;
    cell.title.frame = frame;
    
    frame.origin.y += frame.size.height + kBottomMargin;
    frame.size = expected;
    
    [cell.content setBackgroundColor:[UIColor clearColor]];
    cell.content.font = kUIFont4Content;
    cell.content.frame = frame;
    cell.content.numberOfLines = 0;
    cell.content.text = content;
    cell.content.lineBreakMode = NSLineBreakByTruncatingTail;
    
    return cell;
}
/**
 margin
 title 
 margin
 content
 margin
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RMArticle* data = [self.dataArray objectAtIndex:indexPath.row];
    CGSize max = CGSizeMake(kDeviceWidth-2*kArticleHMargin, kMaxContentHeight);
    NSString* content = data.content;
//    if([NSString respondsToSelector:@selector(stringByConvertingHTMLToPlainText)])
    {
        content = [content performSelector:@selector(stringByConvertingHTMLToPlainText)];
    }
    CGFloat height = 0;
    //title height
    max.height = kTitleFontSize;
    
    height+=kTopMargin;
    height += [data.title sizeWithFont:kUIFont4Title constrainedToSize:max lineBreakMode:NSLineBreakByTruncatingTail].height;
    height += kBottomMargin;
    
    max.height = kMaxContentHeight;
    height += [content sizeWithFont:kUIFont4Content constrainedToSize:max lineBreakMode:NSLineBreakByTruncatingTail].height;
    height += kBottomMargin;
    
    return height;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RMArticle* data = [self.dataArray objectAtIndex:indexPath.row];
    UIViewController* presentController = nil;
    if ([data.content rangeOfString:@"<"].length==0) {
        RMTextViewController* innerController = [[[RMTextViewController alloc]init]autorelease];
        [innerController setText:data.content withTitle:data.title];
        presentController = innerController;
    }
    else
    {
        RMWebViewController* innerController = [[[RMWebViewController alloc]init]autorelease];
        [innerController setText:data.content withTitle:data.title];
        presentController = innerController;
    }
    
    UINavigationController* controller = [[UINavigationController alloc]initWithRootViewController:presentController];
    controller.title = data.title;
    
    [self presentViewController:controller animated:YES completion:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)settingClick:(UIView*)sender
{
    SettingsViewController* controller = [[[SettingsViewController alloc]init]autorelease];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
