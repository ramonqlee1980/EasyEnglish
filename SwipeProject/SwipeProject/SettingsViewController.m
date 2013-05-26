//
//  SettingsViewController.m
//  SettingsExample
//
//  Created by Jake Marsh on 10/8/11.
//  Copyright (c) 2011 Rubber Duck Software. All rights reserved.
//

#import "SettingsViewController.h"

NSString* reuseIdentifier = @"UITableViewCellStyleDefault";
#define kAboutRow 0
#define kFeedbackRow 1

@interface SettingsViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation SettingsViewController

#pragma mark - View lifecycle
- (void) viewDidLoad {
    [super viewDidLoad];
    self.view.frame = [[UIScreen mainScreen]applicationFrame];
    [self.navigationController.navigationBar
     setBackgroundImage:[UIImage imageNamed:kNavigationBarBackground]
     forBarMetrics:UIBarMetricsDefault];
    
    //添加headbar
    UIImageView *headView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kNavigationBarBackground]];
    [headView setFrame:CGRectMake(0, 0, kDeviceWidth, kNavigationBarHeight)];
    [self.view addSubview:headView];
    [headView release];
    
    //topbar 的按钮
    UIButton* photobtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [photobtn setFrame:CGRectMake(kMarginToBoundaryX,kMarginToTopBoundary,kDefaultButtonSize,kDefaultButtonSize)];
    [photobtn setBackgroundImage:[UIImage imageNamed:kLeftSideBarButtonBackground] forState:UIControlStateNormal];
    [photobtn addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    //    [photobtn setTag:FPhoto];
    [photobtn setHidden:NO];
    [self.view addSubview:photobtn];
    
    
    //add tableview
    CGRect rc = [[UIScreen mainScreen]applicationFrame];
    rc.origin.y = kNavigationBarHeight;
    rc.origin.x = 0;
    rc.size.height = rc.size.height-kNavigationBarHeight;
    //rc.size.width = kDeviceWidth-kSideBarMargin;
    UITableView* tableView = [[[UITableView alloc]initWithFrame:rc style:UITableViewStyleGrouped]autorelease];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    switch (indexPath.row) {
        case kAboutRow:
            cell.textLabel.text = @"关于";//NSLocalizedString(@"AboutTitle", @"");
            break;
        case kFeedbackRow:
            cell.textLabel.text = @"建议";//NSLocalizedString(@"kMoreFeedBackKey", @"");
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case kAboutRow:
            [self modalViewAction:nil]; 
            break;
        case kFeedbackRow:
            [self feedback:nil];
        default:
            break;
    }
    
    [tView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    //    [self dismissModalViewControllerAnimated:YES];
}

- (void) viewDidUnload {
    [super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark Workaround

- (void)mailComposeController:(MFMailComposeViewController*)controller             didFinishWithResult:(MFMailComposeResult)result                          error:(NSError*)error;
{
    if (result == MFMailComposeResultSent)
    {
        UIAlertView* alert = [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"EmailAlertViewTitle", @"") message:NSLocalizedString(@"EmailAlertViewMsg", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"") otherButtonTitles:nil]autorelease];
        [alert show];
    }
    [self dismissModalViewControllerAnimated:YES];
}

#define kEmailFeedbackBody @"kEmailFeedbackBody"
// Launches the Mail application on the device.
-(void)launchMailAppOnDevice:(BOOL)feeback
{
    //    NSString *recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
    //    NSString *body = @"&body=It is raining in sunny California!";
    
    NSString * email = [NSString stringWithFormat:@"mailto:&subject=%@&body=%@", NSLocalizedString(@"Title", @""), NSLocalizedString(kEmailFeedbackBody, @"")];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}


#pragma mark -
#pragma mark Compose Mail

// Displays an email composition interface inside the application. Populates all the Mail fields.
-(void)displayComposerSheet:(BOOL)feedback
{
    MFMailComposeViewController *picker = [[[MFMailComposeViewController alloc] init]autorelease];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:NSLocalizedString(@"Title", @"")];
    [picker setMessageBody:NSLocalizedString(kEmailFeedbackBody, @"") isHTML:NO];
    
    // Set up recipients
    //    NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"];
    //    NSArray *bccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
    NSArray *recipients = [NSArray arrayWithObject:@"feedback4iosapp@gmail.com"];
    
    //
    //    [picker setToRecipients:toRecipients];
    [picker setToRecipients:recipients];
    
    [self presentViewController:picker animated:YES completion:nil];
}
-(IBAction)feedback:(id)sender
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet:YES];
        }
        else
        {
            [self launchMailAppOnDevice:YES];
        }
    }
    else
    {
        [self launchMailAppOnDevice:YES];
    }
}
#pragma mark about
- (IBAction)modalViewAction:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"AboutTitle", @"") message:NSLocalizedString(@"About", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"") otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
}

-(void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK","") otherButtonTitles:nil]autorelease];
    [alert show];
}

@end