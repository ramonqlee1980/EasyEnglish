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

//TODO::url TBC
#define kDefaultResourceUrl @"http://y1.eoews.com/assets/ringtones/2012/5/18/34045/hi4dwfmrxm2citwjcc5841z3tiqaeeoczhbtfoex.mp3"
#define kDailySentenceUrl @"http://www.idreems.com/openapi/easyenglish.php?type=sen"

@interface RMDailySentenceViewController ()
{
    FileModel* fileModel;
    NSString* resourceUrl;
    AudioPlayer *_audioPlayer;
}
@property(nonatomic,assign)FileModel* fileModel;
@property(nonatomic,assign)NSString* resourceUrl;
@property(nonatomic,copy)NSString* audioUrl;
@end

@implementation RMDailySentenceViewController
@synthesize fileModel;
@synthesize resourceUrl;
@synthesize audioUrl;

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
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.navigationController) {
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(kBack, kBack) style:UIBarButtonItemStyleBordered target:self action:@selector(goBack:)];
        self.navigationItem.rightBarButtonItem = backItem;
        [backItem release];
    }
    self.resourceUrl = kDailySentenceUrl;
    self.audioUrl = kDefaultResourceUrl;
    
    fileModel = [[FileModel alloc]init];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetServerData:)    name:kTimelineJsonRefreshChanged(self.resourceUrl)          object:nil];
    
    NSString* path = [self startNetworkRequest];
    [self updateViews:path];
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
    model.fileURL = self.resourceUrl;//[NSString stringWithFormat:kDefaultResouceUrl,kInitPage];//for the latest page
    model.notificationName = kTimelineJsonRefreshChanged(self.resourceUrl);
    model.fileName =kRefreshFileName(self.resourceUrl);
    model.destPath = kDefaultFilePath;
    
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

@end
