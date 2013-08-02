//
//  RMDailySentenceViewController.m
//  SwipeProject
//
//  Created by Ramonqlee on 6/3/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import "RMDailySentenceViewController.h"
#import "RMAppDelegate.h"
#import "FileModel.h"
#import "CommonHelper.h"
#import "HTTPHelper.h"
#import "RMDailySentenceJson.h"
#import "AudioPlayer.h"
#import "UIViewController+MMDrawerController.h"
#import "AudioButton.h"
#import "PMCalendar.h"
#import "SettingsViewController.h"

//TODO::url TBC
#define kDefaultResourceUrl @"http://y1.eoews.com/assets/ringtones/2012/5/18/34045/hi4dwfmrxm2citwjcc5841z3tiqaeeoczhbtfoex.mp3"
#define kDailySentenceUrl @"http://www.idreems.com/openapi/easyenglish.php?type=sen&date=%@"

@interface RMDailySentenceViewController ()<PMCalendarControllerDelegate>
{
    FileModel* fileModel;
    NSString* resourceUrl;
    AudioPlayer *_audioPlayer;
    PMCalendarController *pmCC;
    NSString* date;
    BOOL shouldRefreshData;
}
@property(nonatomic,assign)FileModel* fileModel;
@property(nonatomic,assign)NSString* resourceUrl;
@property(nonatomic,copy)NSString* audioUrl;
@property (nonatomic, assign) PMCalendarController *pmCC;
@property(nonatomic,copy)NSString* date;

- (IBAction)showCalendar:(id)sender;
@end

@implementation RMDailySentenceViewController
@synthesize fileModel;
@synthesize resourceUrl;
@synthesize audioUrl;
@synthesize pmCC;
@synthesize date;

-(void)dealloc
{
    self.imageView = nil;
    self.foreignTextView = nil;
    self.audioButton = nil;
    self.saveToLocalButton = nil;
    self.shareButton = nil;
    [fileModel release];
    self.audioUrl = nil;
    [_audioPlayer release];
    self.pmCC = nil;
    
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self stopAudio ];
}
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
-(void)settingClick:(UIView*)sender
{
    SettingsViewController* controller = [[[SettingsViewController alloc]init]autorelease];
    [self presentViewController:controller animated:YES completion:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    if (self.navigationController) {
//        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(kBack, kBack) style:UIBarButtonItemStyleBordered target:self action:@selector(goBack:)];
//        self.navigationItem.rightBarButtonItem = backItem;
//        [backItem release];
//    }
    
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
    
    if(!date)
    {
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        self.date = [formatter stringFromDate:[NSDate date]];
    }
    self.resourceUrl = [NSString stringWithFormat:kDailySentenceUrl,date];
    self.audioUrl = kDefaultResourceUrl;
    
    fileModel = [[FileModel alloc]init];
    
    
    NSString* path = [self startNetworkRequest];
    [self updateViews:path];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"head_background.png"] forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark util methods
-(void)goBack:(UIView*)sender
{
    //RMAppDelegate* appDelegate = (RMAppDelegate*)[[UIApplication sharedApplication] delegate];
    //[appDelegate showSideBarControllerWithDirection:SideBarShowDirectionLeft];
}
#pragma network utils
-(NSString*)startNetworkRequest
{
    //start request for data
    FileModel* model = [self fileModel];
    
    if(!date)
    {
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        self.date = [formatter stringFromDate:[NSDate date]];
    }
    self.resourceUrl = [NSString stringWithFormat:kDailySentenceUrl,date];
    
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
    NSArray* data = [self loadContent:fileName];
    if (data && data.count) {
        RMDailySentenceJson* jsonData = [data objectAtIndex:0];
        [self performSelectorOnMainThread:@selector(updateViewsOnMainThread:) withObject:jsonData waitUntilDone:YES];
    }
}
-(void)updateViewsOnMainThread:(RMDailySentenceJson*)jsonData
{
    if(!jsonData)
    {
        return;
    }
    if (jsonData.imageUrl && jsonData.imageUrl.length)
    {
        UIImage* placeHolderImage = [UIImage imageNamed:kNavigationBarBackground];
        if([self.imageView respondsToSelector:@selector(setImageWithURL:placeholderImage:)])
        {
            [self.imageView performSelector:@selector(setImageWithURL:placeholderImage:) withObject:[NSURL URLWithString:jsonData.imageUrl] withObject:placeHolderImage];
        }
        
    }
    
    self.foreignTextView.text = jsonData.foreignText;
    self.chineseTextView.text = jsonData.chineseText;
    self.foreignTextView.font = kUIFont4Content;
    self.chineseTextView.font = kUIFont4Content;
    
    //TODO::声音文件获取存在问题，需要解决
    self.audioUrl = [jsonData.audioUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
-(NSMutableArray*)loadContent:(NSString*)fileName
{
    NSMutableArray  *dataArray = [[[NSMutableArray alloc]initWithCapacity:0]autorelease];
    NSData* data = [NSData dataWithContentsOfFile:fileName];
    if (data) {
        NSError* error;
        id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (res && [res isKindOfClass:[NSDictionary class]]) {
            NSDictionary* item = [res objectForKey:kData];
            RMDailySentenceJson* sts = [RMDailySentenceJson statusWithJsonDictionary:item];
            [dataArray addObject:sts];
        } else {
            //NSLog(@"arr dataSourceDidError == %@",arrayData);
        }
    }
    return dataArray;
    
}

#pragma mark playAudio
- (IBAction)playAudio:(AudioButton *)button
{
    if (!self.audioUrl) {
        return;
    }
    if (_audioPlayer == nil) {
        _audioPlayer = [[AudioPlayer alloc] init];
    }
    
    if ([_audioPlayer.button isEqual:button]) {
        [_audioPlayer play];
    } else {
        [_audioPlayer stop];
        
        _audioPlayer.button = button;
        _audioPlayer.url = [NSURL URLWithString:self.audioUrl];
        
        [_audioPlayer play];
    }
}
-(void)stopAudio
{
    if(_audioPlayer)
    {
        [_audioPlayer stop];
    }
}
- (IBAction)showCalendar:(id)sender
{
    self.pmCC = [[PMCalendarController alloc] init];
    self.pmCC.delegate = self;
    self.pmCC.mondayFirstDayOfWeek = YES;
    self.pmCC.allowsPeriodSelection = NO;
    
    PMPeriod* peroid = [[[PMPeriod alloc]init]autorelease];
    peroid.endDate = [NSDate date];
    NSDate* todayLastYear = [NSDate date];
    todayLastYear = [todayLastYear dateByAddingMonths:-12];
    peroid.startDate = todayLastYear;
    self.pmCC.allowedPeriod = peroid;
    self.pmCC.allowsLongPressYearChange= YES;
    
    [self.pmCC presentCalendarFromView:sender
              permittedArrowDirections:PMCalendarArrowDirectionAny
                              animated:YES];
    /*    [pmCC presentCalendarFromRect:[sender frame]
     inView:[sender superview]
     permittedArrowDirections:PMCalendarArrowDirectionAny
     animated:YES];*/
    [self calendarController:self.pmCC didChangePeriod:self.pmCC.period];
    
    shouldRefreshData = NO;
}
#pragma mark PMCalendarControllerDelegate methods

- (void)calendarController:(PMCalendarController *)calendarController didChangePeriod:(PMPeriod *)newPeriod
{
    //later than today?
    NSDate* today = [NSDate date];
    //判断是否已经发布数据，如果没有的话，给出一个友好的提示
    if ([newPeriod.startDate compare:today]==NSOrderedDescending ) {
        NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                   fromDate:today
                                                     toDate:newPeriod.startDate
                                                    options:0];
        NSString* tipMessage = [NSString stringWithFormat:@"我还有%i年零%i个月%i天才出生，请耐心等待!",components.year,components.month,components.day+1];
        if(components.year==0)
        {
            tipMessage = [NSString stringWithFormat:@"我还有%i个月零%i天才出生，请耐心等待!",components.month,components.day+1];
        }
        if(components.month==0)
        {
            tipMessage = [NSString stringWithFormat:@"我还有%i天才出生，请耐心等待!",components.day+1];
        }
        
        [self.view performSelectorOnMainThread:@selector(makeToast:) withObject:tipMessage waitUntilDone:YES];
        return;
    }
    self.date = [newPeriod.startDate dateStringWithFormat:@"yyyy-MM-dd"];
    shouldRefreshData = YES;
}
/**
 * Called on the delegate right after calendar controller removes itself from a superview.
 */
- (void)calendarControllerDidDismissCalendar:(PMCalendarController *)calendarController
{
    if(!shouldRefreshData)
    {
        return;
    }
    [self.view performSelectorOnMainThread:@selector(makeToast:) withObject:@"我来啦，请稍等奥" waitUntilDone:YES];
    [self startNetworkRequest];
}
@end
