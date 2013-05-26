//
//  RMTableViewController.m
//  SwipeProject
//
//  Created by ramonqlee on 5/4/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import "RMTableViewController.h"
#import "PullingRefreshTableView.h"
#import "FileModel.h"
#import "CommonHelper.h"
#import "HTTPHelper.h"
#import "RMCollectJson.h"
#import "CIALBrowserViewController.h"
#import "RMTabbedViewController.h"

//url and related file name on local machine
//url is pulled from server and others are derived from this url
#define kDefaultResouceUrl @"http://www.idreems.com/openapi/collect_api.php?type=image"

#define kInitItemCount 20
#define kIncrementItemCount 10
#define kLoadMoreFakeDelay 0.5f
#define kDefaultFilePath @"cache"

#define kRefreshFileName(url) [NSString stringWithFormat:@"%@%@",@"Refresh_",[CommonHelper cachePathForKey:url] ]

#define kLoadMoreFileNamePrefix @"More_"

#define kTimelineJsonRefreshChanged(url)  [NSString stringWithFormat:@"%@%@",@"kRefreshNotification_",[CommonHelper cachePathForKey:url] ]

#define kTimelineJsonLoadMoreChanged(url)  [NSString stringWithFormat:@"%@%@",@"kLoadMoreNotification_",[CommonHelper cachePathForKey:url] ]//reserved,right now load more local data

#define kItemPerPage 20
#define kData @"data"

//#define kMainBackgound @"main_background.png"


@interface RMTableViewController ()<
PullingRefreshTableViewDelegate,
UITableViewDataSource,
UITableViewDelegate
>
{
    FileModel* fileModel;
    PullingRefreshTableView *tableView;
    NSMutableArray *items;
    BOOL refreshing;
    CGRect frame;
    NSUInteger tableViewItemCount;
}
@property(nonatomic,assign)FileModel* fileModel;
@property(nonatomic,assign)NSMutableArray *items;
@property(nonatomic,copy)NSString* resourceUrl;
@end

@implementation RMTableViewController
@synthesize fileModel;
@synthesize items;
@synthesize delegate;
-(id)initWithFrame:(CGRect)rc
{
    if(self = [super init])
    {
        frame = rc;
    }
    return self;
}
-(void)dealloc
{
    [fileModel release];
    [tableView release];
    self.delegate = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!self.resourceUrl || self.resourceUrl.length==0)
    {
        [self setUrl:kDefaultResouceUrl];
    }
    [self.view setFrame:frame];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    //设置背景颜色
    //    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:kMainBackgound]]];
    
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    CGRect bounds = self.view.frame;
    bounds.origin = CGPointZero;
    //    bounds.size.height -= 44.f;
    tableView = [[PullingRefreshTableView alloc] initWithFrame:bounds pullingDelegate:self];
    //    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    tableView.backgroundColor = [UIColor clearColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    
    fileModel = [[FileModel alloc]init];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetTimeLine:)    name:kTimelineJsonRefreshChanged(self.resourceUrl)          object:nil];
    
    //pulling data;
    [tableView launchRefreshing];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //load more
    return (0==tableViewItemCount)?MIN(self.items?[self.items count]:0,kInitItemCount):tableViewItemCount;
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    //
    RMCollectJson* data = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = data.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\t%@",data.author,data.date];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    RMCollectJson* data = [self.items objectAtIndex:indexPath.row];
    NSURL *url = [NSURL URLWithString:data.url];
    CIALBrowserViewController *controller = [CIALBrowserViewController modalBrowserViewControllerWithURL:url];
    controller.enabledSafari = NO;
    controller.hideLocationBar = YES;
    
    if (delegate) {
        [delegate didSelectRow:controller];
    }
    else
    {
        //    [self presentModalViewController:controller animated:YES];
        [self presentViewController:controller animated:YES completion:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tView
{
    NSLog(@"pullingTableViewDidStartRefreshing");
    //pulling data
    NSString* path = [self startNetworkRequest];
    //time-consuming,go to background thread
    [self performSelectorInBackground:@selector(fillTableViewDataSource:) withObject:path];
}
//Implement this method if headerOnly is false
- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tView
{
    NSLog(@"pullingTableViewDidStartLoading and just return");
    // Return the number of rows in the section.
    if(tableViewItemCount < (self.items?[self.items count]:0))
    {
        tableViewItemCount +=kIncrementItemCount;
    }
    //exceed actual item count?
    if (tableViewItemCount > (self.items?[self.items count]:0)) {
        tableViewItemCount = (self.items?[self.items count]:0);
    }
    //just load more local data
    [self performSelector:@selector(tableViewDidFinishedLoading) withObject:self afterDelay:kLoadMoreFakeDelay];
    //[self tableViewDidFinishedLoading];
}
#pragma mark - Scroll

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [tableView tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [tableView tableViewDidEndDragging:scrollView];
}
#pragma mark callback
-(void)tableViewDidFinishedLoading
{
    if (refreshing) {
        refreshing = NO;
    }
    if(tableViewItemCount<=0)
    {
        tableViewItemCount = MIN(self.items?[self.items count]:0,kInitItemCount);
    }
    [tableView tableViewDidFinishedLoading];
    [self notifyDatasetChanged];
    NSLog(@"tableViewDidFinishedLoading");
}
-(NSMutableArray*)loadContent:(NSString*)fileName
{
    NSMutableArray  *dataArray = [[[NSMutableArray alloc]initWithCapacity:0]autorelease];
    NSData* data = [NSData dataWithContentsOfFile:fileName];
    if (data) {
        NSError* error;
        id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (res && [res isKindOfClass:[NSDictionary class]]) {
            NSArray* arr = [res objectForKey:kData];
            for (id item in arr) {
                RMCollectJson* sts = [RMCollectJson statusWithJsonDictionary:item];
                [dataArray addObject:sts];
            }
        } else {
            //NSLog(@"arr dataSourceDidError == %@",arrayData);
        }
    }
    return dataArray;
    
}
-(BOOL)fillTableViewDataSource:(NSString*)fileName
{
    @synchronized(self)
    {
        if(nil == self.items)
        {
            self.items = [[NSMutableArray alloc]initWithCapacity:0];
        }
        //remove duplicate one
        NSMutableArray* dataArray = [self loadContent:fileName];
        if ([self.items count]>0) {
            [self mergeArray:dataArray withObjects:self.items];
            //                [dataArray addObjectsFromArray:self.items];
            [self.items removeAllObjects];
            [self.items addObjectsFromArray:dataArray];
        }
        else
        {
            [self mergeArray:self.items withObjects:dataArray];
            //                [self.items addObjectsFromArray:dataArray];
        }
        
        BOOL r = dataArray?([dataArray count]>0):NO;
        
        if(r)
        {
            [self performSelectorOnMainThread:@selector(notifyDatasetChanged) withObject:nil waitUntilDone:NO];
        }
        
        
        return r;
    }
}
-(void)notifyDatasetChanged
{
    [tableView reloadData];
}
-(void)didGetTimeLine:(NSNotification*)notification
{
    if(notification)
    {
        if([notification.object isKindOfClass:[NSString class]])
        {
            [self fillTableViewDataSource:(NSString*)notification.object];
        }
        else if([notification.object isKindOfClass:[NSError class]])//error
        {
            //fail to load data
            [self GetErr:nil];
        }
    }
    
    
    [self performSelectorOnMainThread:@selector(tableViewDidFinishedLoading) withObject:nil waitUntilDone:TRUE];
}
//merge and remove duplicate items
-(void)mergeArray:(NSMutableArray*)desArray withObjects:(NSArray *)objects
{
    if(!desArray || !objects)
    {
        return;
    }
    
    for (NSObject* obj in objects) {
        if(NSNotFound==[desArray indexOfObject:obj])
        {
            [desArray addObject:obj];
        }
    }
}


-(void)didGetMore:(NSNotification*)notification
{
    if(notification && [notification.object isKindOfClass:[NSError class]])//error
    {
        [self GetErr:nil];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(didGetMoreOnMainThread:) withObject:notification waitUntilDone:YES];
    }
}

-(void) GetErr:(ASIHTTPRequest *)request
{
    [self tableViewDidFinishedLoading];
    
    if([self.view respondsToSelector:@selector(makeToast:)])
    {
        [self.view performSelectorOnMainThread:@selector(makeToast:) withObject:@"连接网络失败，请检查是否开启移动数据" waitUntilDone:YES];
    }
}
-(NSString*)cacheFile
{
    FileModel* model = [self fileModel];
    if (!model) {
        return @"";
    }
    
    return [[CommonHelper getTargetBookPath:model.destPath] stringByAppendingPathComponent:model.fileName];
}
-(NSString*)startNetworkRequest
{
    //start request for data
    FileModel* model = [self fileModel];
    model.fileURL = self.resourceUrl;//[NSString stringWithFormat:kDefaultResouceUrl,kInitPage];//for the latest page
    model.notificationName = kTimelineJsonRefreshChanged(self.resourceUrl);
    model.fileName =kRefreshFileName(self.resourceUrl);
    model.destPath = kDefaultFilePath;
    
    if(!refreshing)
    {
        refreshing = YES;
        [[HTTPHelper sharedInstance] beginRequest:model isBeginDown:YES setAllowResumeForFileDownloads:NO];
    }
    
    return [[CommonHelper getTargetBookPath:model.destPath] stringByAppendingPathComponent:model.fileName];
}
-(void)setUrl:(NSString*)currentUrl
{
    //remove notification observer
    [self tableViewDidFinishedLoading];
    
    self.resourceUrl = currentUrl;
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
    [notificationCenter addObserver:self selector:@selector(didGetTimeLine:)    name:kTimelineJsonRefreshChanged(self.resourceUrl)          object:nil];
    [tableView launchRefreshing];
}
@end
