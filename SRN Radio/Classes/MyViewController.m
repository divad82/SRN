
#import "MyViewController.h"

#import "AudioStreamer.h"

#include "DJBConfig.h"

#define DJB_CONFIG	(char *)"DJB_CONFIG"

@interface MyViewController()
- (NSString *)hostName;
@end

@implementation MyViewController

@synthesize loadingIndicatorView;
@synthesize btnplay;
@synthesize btnpause;

@synthesize metaDataLabel1;
@synthesize metaDataLabel2;

@synthesize timer;

@synthesize remoteHostStatus;
@synthesize internetConnectionStatus;
@synthesize localWiFiConnectionStatus;


//@synthesize volumeSlider;

/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	// load configuration data
	[self LoadDJBConfig];
	
	// check if the multi tasking is supported
	[self CheckBackGroundEnabled];
	
	// load DJB data property
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Customization" ofType:@"plist"];
	customStringDict = (path != nil ? [NSDictionary dictionaryWithContentsOfFile:path] : nil);
	[customStringDict retain];

	// init station info 
	[self InitStationInfo];
		
	stop=NO;
	
	[[Reachability sharedReachability] setHostName:[self hostName]];//this function will find the host address
	[[Reachability sharedReachability] setNetworkStatusNotificationsEnabled:YES];
	[self updateStatus];//this will check the state of the network connection
	
	// Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
	// method "reachabilityChanged" will be called. 
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:@"kNetworkReachabilityChangedNotification" object:nil];
	
	//containview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    containview =  [[UIImageView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	containview.backgroundColor = [UIColor blackColor];						// make background Transparent
	containview.autoresizesSubviews = YES;									// Subview of main Frame can be auto resizable
	
	//determines how the receiver resizes its subviews when its bounds change
	containview.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	
	[self.view addSubview:containview];	
	//[containview setUserInteractionEnabled:NO];
		
	imgvheading = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
	
	/*imgvtemp=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
	 imgvtemp.image=[UIImage imageNamed:@"320x460 Puregold Logo iPhone Player.jpg"];
	 [containview addSubview:imgvtemp];*/
	imgv3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 90, 320,290 )];
	
	btnplay=[self  CreateButtonWithFrame:CGRectMake(0, 380, 35, 35)];
	btnpause=[self  CreateButtonWithFrame:CGRectMake(0, 380, 35, 35)];	
	btnminus=[self  CreateButtonWithFrame:CGRectMake(35, 380, 35, 35)];
#ifdef SUPPORT_SETTING	
	btnplus=[self  CreateButtonWithFrame:CGRectMake(250, 380, 35, 35)];
	btnsettings=[self  CreateButtonWithFrame:CGRectMake(285, 380, 35, 35)];
	btndone=[self  CreateButtonWithFrame:CGRectMake(267, 0, 53, 32)];
#endif
#ifdef SUPPORT_HELP
	btnplus=[self  CreateButtonWithFrame:CGRectMake(250, 380, 35, 35)];
	btnhelp=[self  CreateButtonWithFrame:CGRectMake(285, 380, 35, 35)];
	btndonehelp=[self  CreateButtonWithFrame:CGRectMake(267, 0, 53, 32)];
#endif	
	btndoneinfo=[self  CreateButtonWithFrame:CGRectMake(267, 0, 53, 32)];
	
	
	btnmute=[self  CreateButtonWithFrame:CGRectMake(0, 420, 106, 40)];
	btninfo=[self  CreateButtonWithFrame:CGRectMake(107, 420, 106, 40)];
	btncontact=[self  CreateButtonWithFrame:CGRectMake(214, 420, 106, 40)];
	btnsend=[self  CreateButtonWithFrame:CGRectMake(60, 270, 70, 40)];
	
	btndiscard=[self  CreateButtonWithFrame:CGRectMake(190, 270, 70, 40)];
	
	metaDataLabel1=[[UILabel alloc] init];
	metaDataLabel1.frame=CGRectMake(0, 30, 320, 30);
	metaDataLabel1.backgroundColor=[UIColor clearColor];
	metaDataLabel1.text = @"";
	[containview addSubview:metaDataLabel1];
	
	metaDataLabel2=[[UILabel alloc] init];
	metaDataLabel2.frame=CGRectMake(0, 60, 320, 30);
	metaDataLabel2.backgroundColor=[UIColor clearColor];
	metaDataLabel2.text = @"";
	[containview addSubview:metaDataLabel2];
	
	slid = [[UISlider alloc] initWithFrame:CGRectMake(70, 385, 180, 10)];
	
#ifdef SUPPORT_SETTING	
	//DateActionSheet = [[UIActionSheet alloc] initWithTitle:@"SETTINGS\n\n\n\n\n\n\n\n"
	//											  delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	DateActionSheet = [[UIActionSheet alloc] initWithTitle:@"SETTINGS\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
												  delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	DateActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque; //UIActionSheetStyleBlackTranslucent;
	
	settingsview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 30, 320, 140)];
	settingsview.image=[UIImage imageNamed:@"setting-screen1.png"];
	[DateActionSheet addSubview:settingsview];
#endif	

	// help page
#ifdef SUPPORT_HELP	
	helpActionSheet = [[UIActionSheet alloc] initWithTitle:@"Help \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
												  delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	helpActionSheet.actionSheetStyle =UIActionSheetStyleBlackOpaque;
#endif
	
	// info page
	infoActionSheet = [[UIActionSheet alloc] initWithTitle:@"Info\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
												  delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	infoActionSheet.actionSheetStyle =UIActionSheetStyleBlackOpaque;
	
	// contact page
	contactActionsheet = [[UIActionSheet alloc] initWithTitle:@"Contact\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
													 delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	contactActionsheet.actionSheetStyle =UIActionSheetStyleBlackOpaque;
		
	arr=[[[NSArray alloc]initWithObjects:[customStringDict objectForKey:@"highBandwidth"],[customStringDict objectForKey:@"lowBandwidth"],nil]retain];
	
	doneButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	
	[doneButton setBackgroundImage:[UIImage imageNamed:@"done1.png"] forState:UIControlStateNormal];
	
	doneButton.frame = CGRectMake(260, 215, 62, 30);
	
	doneButton.hidden=YES;
	
	[doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	doneButton.backgroundColor = [UIColor clearColor];
	
	[doneButton setTitle:@"" forState:UIControlStateNormal];
	
	txtaddress=[[UITextField alloc] init ];
	txtaddress.frame=CGRectMake(30,50,250 ,30);
	
	txttitle=[[UITextField alloc] init ];
	txttitle.frame=CGRectMake(30,100,250 ,30);
	
	imgvtextviewbg = [[UIImageView alloc] initWithFrame:CGRectMake(35, 135, 245, 75)];
	
	CGRect frame = CGRectMake(40, 140, 235, 65);
	txtviewcontent=[[UITextView alloc] initWithFrame:frame ];

#ifdef SUPPORT_CUSTOM_STATION_PICKER
	[self SetupCustomStationPicker];
#endif
	
#ifdef SUPPORT_SETTING	
	//scott: this needs to be altered to show the correct intial bandwidth setting
	[self createSegmentControllerInitWithItem:arr ofFrame:CGRectMake(35, 70, 250, 50) Selected:streamBandwidthSelection ContainedIn:DateActionSheet Target:self AddAction:@selector(conformation:)];
		
#ifdef SUPPORT_STATION_PICKER		
	// station picker	
	m_djbStationPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 180, 320, 100)];
	m_djbStationPicker.delegate = self;
	m_djbStationPicker.dataSource = self;
	m_djbStationPicker.showsSelectionIndicator = YES;
	[m_djbStationPicker selectRow:(m_curBroadcastStationID=[self GetSelectedPickerRowFromConfig]) inComponent:0 animated:YES];
	//m_djbStationPicker.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
	  	
	// add station picker into the DateActionSheet
	[DateActionSheet addSubview:m_djbStationPicker];
	
	// background label
	UILabel * backGndRunLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 408.0, 200.0, 20.0)] autorelease];
	backGndRunLabel.text = @"Background Run on Exit";
	backGndRunLabel.textColor = [UIColor whiteColor];
	backGndRunLabel.backgroundColor = [UIColor clearColor];
	[DateActionSheet addSubview:backGndRunLabel];	
	
	// background switch
	m_backGndRunSwitchCtl = [[UISwitch alloc] initWithFrame:CGRectMake(210.0, 405.0, 94.0, 27.0)];
	[m_backGndRunSwitchCtl addTarget:self action:@selector(BackGroundSwitchAction:) forControlEvents:UIControlEventValueChanged];
	[m_backGndRunSwitchCtl setOn:(GetBackGndEnabled() ? YES : NO) animated:NO];
	//[m_backGndRunSwitchCtl setAccessibilityLabel:NSLocalizedString(@"Background Run on Exit", @"Test")];
	
	// in case the parent view draws with a custom color or gradient, use a transparent color
	m_backGndRunSwitchCtl.backgroundColor = [UIColor clearColor];
	 
	[DateActionSheet addSubview:m_backGndRunSwitchCtl];	
#endif	
#endif	
	
	[self makeGUI];
	
#ifdef SUPPORT_RUN_BACKGROUND
	// Handle Audio Remote Control events (only available under iOS 4
	if (m_backgroundRunDevEnabled==YES && m_backgroundRunEnabled==YES) {
		if ([[UIApplication sharedApplication] respondsToSelector:@selector(beginReceivingRemoteControlEvents)]){
			[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
		}
	}
#endif
	
	loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(140,260,30,30)];
	loadingIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	loadingIndicatorView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
											 UIViewAutoresizingFlexibleRightMargin |
											 UIViewAutoresizingFlexibleTopMargin |
											 UIViewAutoresizingFlexibleBottomMargin);
	[containview addSubview:loadingIndicatorView];

#ifdef SUPPORT_128KBPS	
	//scott: before we start the stream, we need to identify bandwidth and choose low/high
	if ([self localWiFiConnectionStatus] !=0) {
		streamBandwidthSelection = 0;
	}else{
		streamBandwidthSelection = 1;
	}
#endif	
	
	[self startStream:nil];
	
	[super viewDidLoad];	
}

-(void)makeGUI
{
	imgvheading.image=[UIImage imageNamed:@"Now-Playing.png"];
	[containview addSubview:imgvheading];
	
	imgv3.image=[UIImage imageNamed:@"MainScreen.png"];
	[containview addSubview:imgv3];
	[imgv3 setUserInteractionEnabled:YES];
	
//	imgvlogo.image=[UIImage imageNamed:@"MainScreen.png"];
//	[containview addSubview:imgvlogo];
	
	[btnplay setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
	[btnplay setBackgroundImage:[UIImage imageNamed:@"play2.png"] forState:UIControlStateHighlighted];
	[btnplay addTarget:self action:@selector(startStream:) forControlEvents:UIControlEventTouchUpInside];
	[containview addSubview:btnplay];
	[btnplay setUserInteractionEnabled:NO];
	btnplay.hidden=YES;
	
	[btnpause setBackgroundImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateNormal];
	[btnpause setBackgroundImage:[UIImage imageNamed:@"stop2.png"] forState:UIControlStateHighlighted];
	[btnpause addTarget:self action:@selector(stopStream:) forControlEvents:UIControlEventTouchUpInside];
	[containview addSubview:btnpause];
	[btnpause setUserInteractionEnabled:YES];
	btnpause.hidden=NO;
	
	[btnplus setBackgroundImage:[UIImage imageNamed:@"volume-increase.png"] forState:UIControlStateNormal];
	[btnplus setBackgroundImage:[UIImage imageNamed:@"volume-increase2.png"] forState:UIControlStateHighlighted];
	[btnplus addTarget:self action:@selector(btnplusTouched) forControlEvents:UIControlEventTouchUpInside];
	[containview addSubview:btnplus];
	[btnplus setUserInteractionEnabled:YES];
	btnplus.hidden=NO;
	
	[btnminus setBackgroundImage:[UIImage imageNamed:@"volume-decrease.png"] forState:UIControlStateNormal];
	[btnminus setBackgroundImage:[UIImage imageNamed:@"volume-decrease2.png"] forState:UIControlStateHighlighted];
	[btnminus addTarget:self action:@selector(btnminusTouched) forControlEvents:UIControlEventTouchUpInside];
	[containview addSubview:btnminus];
	[btnminus setUserInteractionEnabled:YES];
	btnminus.hidden=NO;
	
#ifdef SUPPORT_SETTING	
	[btnsettings setBackgroundImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
	[btnsettings setBackgroundImage:[UIImage imageNamed:@"settings2.png"] forState:UIControlStateHighlighted];
	[btnsettings addTarget:self action:@selector(btnsettingsTouched) forControlEvents:UIControlEventTouchUpInside];
	[containview addSubview:btnsettings];
	[btnsettings setUserInteractionEnabled:YES];
	btnsettings.hidden=NO;
#endif	
#ifdef SUPPORT_HELP	
	[btnhelp setBackgroundImage:[UIImage imageNamed:@"HelpButton.png"] forState:UIControlStateNormal];
	[btnhelp setBackgroundImage:[UIImage imageNamed:@"HelpButton2.png"] forState:UIControlStateHighlighted];
	[btnhelp addTarget:self action:@selector(btnhelpTouched) forControlEvents:UIControlEventTouchUpInside];
	[containview addSubview:btnhelp];
	[btnhelp setUserInteractionEnabled:YES];
	btnhelp.hidden=NO;
#endif

	slid.backgroundColor = [UIColor clearColor];
	
	slid.minimumValue = 0.0f;
	slid.maximumValue = 1.0f;
	slid.continuous = YES;
	slid.alpha = 1.0f;
	slid.value = 0.5f;
	
	float value = slid.value;
	[streamer volumeControl:value];
	
	slid.userInteractionEnabled=YES;
	[slid addTarget:self action:@selector(sliderTouched:) forControlEvents:UIControlEventValueChanged];
	[containview addSubview:slid];
	
	[btnmute setBackgroundImage:[UIImage imageNamed:@"sound.png"] forState:UIControlStateNormal];
	[btnmute addTarget:self action:@selector(btnmuteTouched) forControlEvents:UIControlEventTouchUpInside];
	[containview addSubview:btnmute];
	[btnmute setUserInteractionEnabled:YES];
	
	[btninfo setBackgroundImage:[UIImage imageNamed:@"info-button2.png"] forState:UIControlStateNormal];
	[btninfo setBackgroundImage:[UIImage imageNamed:@"info-button.png"] forState:UIControlStateHighlighted];
	[btninfo addTarget:self action:@selector(btninfoTouched) forControlEvents:UIControlEventTouchUpInside];
	[containview addSubview:btninfo];
	[btninfo setUserInteractionEnabled:YES];
	
	[btncontact setBackgroundImage:[UIImage imageNamed:@"mail-1.png"] forState:UIControlStateNormal];
	[btncontact setBackgroundImage:[UIImage imageNamed:@"mail-2.png"] forState:UIControlStateHighlighted];
	[btncontact addTarget:self action:@selector(btncontactTouched) forControlEvents:UIControlEventTouchUpInside];
	[containview addSubview:btncontact];
	[btncontact setUserInteractionEnabled:YES];
}

-(void)sliderTouched:(id)sender{
	
	float value = slid.value;
	//NSLog(@"slid=%f",value);
	[streamer volumeControl:value];
	[btnmute setBackgroundImage:[UIImage imageNamed:@"sound.png"] forState:UIControlStateNormal];
	mute=NO;
}

-(void)btnplusTouched{
	slid.value=slid.value+0.1;
	[streamer volumeControl:slid.value];
	//NSLog(@"slid=..............%f",slid.value);
	[btnmute setBackgroundImage:[UIImage imageNamed:@"sound.png"] forState:UIControlStateNormal];
	mute=NO;
}

-(void)btnminusTouched{
	slid.value=slid.value-0.1;
	[streamer volumeControl:slid.value];
	//NSLog(@"slid=..............%f",slid.value);
	[btnmute setBackgroundImage:[UIImage imageNamed:@"sound.png"] forState:UIControlStateNormal];
	mute=NO;
}

#ifdef SUPPORT_SETTING
-(void)btnsettingsTouched{
	
#ifdef SUPPORT_RUN_BACKGROUND
	// save the m_backgroundRunEnabled flag
	m_prevBackgroundRunEnabled = m_backgroundRunEnabled;
#endif
	
	// save the current broadcasting station id
	m_prevBroadcastStationID = m_curBroadcastStationID;
	
	// open setting window
	[DateActionSheet  showInView:containview];
	
	[btndone setBackgroundImage:[UIImage imageNamed:@"done1.png"] forState:UIControlStateNormal];
	[btndone setBackgroundImage:[UIImage imageNamed:@"done2.png"] forState:UIControlStateHighlighted];
	[btndone addTarget:self action:@selector(btndoneTouched:) forControlEvents:UIControlEventTouchUpInside];
	[DateActionSheet addSubview:btndone];
	
}
#endif

#ifdef SUPPORT_HELP
-(void)btnhelpTouched{
	// setup info page resource
	[self SetupHelpPageRes];
}
#endif

-(void)btnmuteTouched{
	
	if(mute==YES)
	{
		if(stop==YES)
		{
			[self startStream:nil];
			[streamer volumeControl:slid.value];
			[btnmute setBackgroundImage:[UIImage imageNamed:@"sound.png"] forState:UIControlStateNormal];
		}
		else
		{
		    [streamer volumeControl:slid.value];
		    [btnmute setBackgroundImage:[UIImage imageNamed:@"sound.png"] forState:UIControlStateNormal];
		}
		
		mute=NO;
	}
	else
	{
		[streamer volumeControl:0.0f];
		[btnmute setBackgroundImage:[UIImage imageNamed:@"mute1.png"] forState:UIControlStateNormal];
		mute=YES;
	}
	
}

-(void)btninfoTouched{
	
	[infoActionSheet  showInView:containview];
	[btndoneinfo setBackgroundImage:[UIImage imageNamed:@"done1.png"] forState:UIControlStateNormal];
	[btndoneinfo setBackgroundImage:[UIImage imageNamed:@"done2.png"] forState:UIControlStateHighlighted];
	[btndoneinfo addTarget:self action:@selector(btndoneinfoTouched:) forControlEvents:UIControlEventTouchUpInside];
	[infoActionSheet addSubview:btndoneinfo];
	
	/*UIView *contentView1 = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	 contentView1.backgroundColor = [UIColor whiteColor];
	 contentView1.autoresizesSubviews = YES;
	 contentView1.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	 [infoActionSheet addSubview:contentView1];
	 [contentView1 release];*/
	
	infoview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 32, 320, 430)];
	infoview.backgroundColor = [UIColor whiteColor];
	infoview.image=[UIImage imageNamed:@"Info.png"];
	[infoActionSheet addSubview:infoview];	
	
	// setup info page resource
	[self SetupInfoPageRes];
	
#ifndef SUPPORT_SAFARI	
	myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,33,320,460)];
	myWebView.backgroundColor = [UIColor whiteColor];
	myWebView.scalesPageToFit = YES;
	myWebView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	myWebView.delegate = self;
	
	btninfolink1=[self  CreateButtonWithFrame:CGRectMake(10, 180, 300, 40)];
	[btninfolink1 addTarget:self action:@selector(btninfolink1Touched) forControlEvents:UIControlEventTouchUpInside];
	[infoActionSheet addSubview:btninfolink1];
	[btninfolink1 setUserInteractionEnabled:YES];
	
	btninfolink2=[self  CreateButtonWithFrame:CGRectMake(10, 260, 300, 40)];
	[btninfolink2 addTarget:self action:@selector(btninfolink2Touched) forControlEvents:UIControlEventTouchUpInside];
	[infoActionSheet addSubview:btninfolink2];
	[btninfolink2 setUserInteractionEnabled:YES];
	
	UILabel *line1 = [[[UILabel alloc] initWithFrame:CGRectMake(10, 140, 300, 40)] retain];
	line1.backgroundColor = [UIColor clearColor];
	line1.opaque = NO;
	line1.textColor = [UIColor blackColor];
	line1.font = [UIFont boldSystemFontOfSize:22];
	line1.adjustsFontSizeToFitWidth = YES;
	line1.numberOfLines=1;
	line1.textAlignment = UITextAlignmentCenter;
	line1.minimumFontSize=18;
	line1.text = [customStringDict objectForKey:@"InfoPageLine1Text"]; //@"This App is Created by:";
	[infoActionSheet addSubview:line1];
	
	UILabel *line2 = [[[UILabel alloc] initWithFrame:CGRectMake(10, 180, 300, 40)] retain];
	line2.backgroundColor = [UIColor clearColor];
	line2.opaque = NO;
	line2.textColor = [UIColor blackColor];
	line2.font = [UIFont boldSystemFontOfSize:22];
	line2.adjustsFontSizeToFitWidth = YES;
	line2.numberOfLines=1;
	line2.textAlignment = UITextAlignmentCenter;
	line2.minimumFontSize=18;
	line2.text = [customStringDict objectForKey:@"InfoPageLine2Text"]; //@"DJBApps.com";
	[infoActionSheet addSubview:line2];
	
	UILabel *line3 = [[[UILabel alloc] initWithFrame:CGRectMake(10, 220, 300, 40)] retain];
	line3.backgroundColor = [UIColor clearColor];
	line3.opaque = NO;
	line3.textColor = [UIColor blackColor];
	line3.font = [UIFont boldSystemFontOfSize:22];
	line3.adjustsFontSizeToFitWidth = YES;
	line3.numberOfLines=1;
	line3.textAlignment = UITextAlignmentCenter;
	line3.minimumFontSize=18;
	line3.text = [customStringDict objectForKey:@"InfoPageLine3Text"]; //@"for";
	[infoActionSheet addSubview:line3];
	
	UILabel *line4 = [[[UILabel alloc] initWithFrame:CGRectMake(10, 260, 300, 40)] retain];
	line4.backgroundColor = [UIColor clearColor];
	line4.opaque = NO;
	line4.textColor = [UIColor blackColor];
	line4.font = [UIFont boldSystemFontOfSize:22];
	line4.adjustsFontSizeToFitWidth = YES;
	line4.numberOfLines=1;
	line4.textAlignment = UITextAlignmentCenter;
	line4.minimumFontSize=18;
	line4.text = [customStringDict objectForKey:@"InfoPageLine4Text"]; //@"American Family Radio";
	[infoActionSheet addSubview:line4];		
#endif	
}

#ifdef SUPPORT_SETTING
-(void)btndoneTouched:(id)sender{
	
#ifdef SUPPORT_RUN_BACKGROUND
	if( m_prevBackgroundRunEnabled != m_backgroundRunEnabled ) {
		// Handle Audio Remote Control events (only available under iOS 4
		if (m_backgroundRunDevEnabled==YES) {
			if (m_prevBackgroundRunEnabled) { 
				// switch off
				if ([[UIApplication sharedApplication] respondsToSelector:@selector(endReceivingRemoteControlEvents)]){
					[[UIApplication sharedApplication] endReceivingRemoteControlEvents];
				}
			} else {
				// switch on
				if ([[UIApplication sharedApplication] respondsToSelector:@selector(beginReceivingRemoteControlEvents)]){
					[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
				}
			}
		}
	}
#endif	
	
	// check if teh broadcasting station changed
	if( m_prevBroadcastStationID != (m_curBroadcastStationID=[self GetSelectedPickerRowFromConfig]) ) {
		// stop current stream
		[self stopStream:nil];
		// start new stream
		[self startStream:nil];
	}
	
	[(UIActionSheet *)[sender superview] dismissWithClickedButtonIndex:0 animated:YES];
}
#endif

#ifdef SUPPORT_HELP
-(void)btndonehelpTouched:(id)sender{
	// release resource
	[self ReleaseHelpPageRes];
	
	[(UIActionSheet *)[sender superview] dismissWithClickedButtonIndex:0 animated:YES];
}
#endif

#ifdef SUPPORT_SETTING
-(void)createSegmentControllerInitWithItem:(NSArray *)items 
								   ofFrame:(CGRect )Frame
								  Selected:(NSInteger)selected 
							   ContainedIn:(UIActionSheet *)view
									Target:(id)object
								 AddAction:(SEL)Action{
	styleSegmentedControl = [[UISegmentedControl alloc] initWithItems:items];
	[styleSegmentedControl addTarget:object action:Action forControlEvents:UIControlEventValueChanged];
	styleSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	styleSegmentedControl.tintColor=[UIColor lightGrayColor];
	styleSegmentedControl.backgroundColor = [UIColor clearColor];
	[styleSegmentedControl sizeToFit];
    styleSegmentedControl.frame = Frame;
	styleSegmentedControl.selectedSegmentIndex=selected;
	[view addSubview:styleSegmentedControl];
	
	//return styleSegmentedControl;
}
#endif

#ifdef SUPPORT_SETTING
-(void)conformation:(id)sender{
	UISegmentedControl *s= (UISegmentedControl *)sender;
	//scott: test if the selected choice is different than the currently active choice. if it's the same, dont bother
	if(streamBandwidthSelection==s.selectedSegmentIndex)return;
	
	
	if(mute==YES)
	{
		//nothing
	}
	else
	{
		//scott: high bandwidth is index 0, so if the choice is index 0 then we need to test if wifi is available
		//scott: if wifi is not available, then we should alert the user that they need wifi
		if (s.selectedSegmentIndex==0) {
			if ([self localWiFiConnectionStatus] ==0) {
				//scott: no wifi available
				//scott: show alert and return without doing anything
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Wi-Fi connection" message:@"Please connect to a Wi-Fi netowrk to use the high bandwidth stream."
															   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];	
				[alert release];
				return;
				
			}
		}
		streamBandwidthSelection=s.selectedSegmentIndex;
		
		[streamer stop];
		stop=YES;
		[self startStream:nil];
		stop=NO;
	}
}
#endif

#ifndef SUPPORT_SAFARI	
- (void)btninfolink1Touched{
		
	NSString *openURL = [customStringDict objectForKey:@"InfoPageLine2Link"];
	if (openURL!=nil) {
		[infoActionSheet addSubview: myWebView];
		[myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:openURL]]];
	}	
	
}

- (void)btninfolink2Touched{
	
	NSString *openURL = [customStringDict objectForKey:@"InfoPageLine4Link"];
	if (openURL!=nil) {
		if (![@"" isEqualToString:openURL]) {
			[infoActionSheet addSubview: myWebView];
			[myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:openURL]]];
		}
		
	}
}
#endif

-(void)btndoneinfoTouched:(id)sender{
	// release resource
	[self ReleaseInfoPageRes];
	
	[(UIActionSheet *)[sender superview] dismissWithClickedButtonIndex:0 animated:YES];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


#ifndef SUPPORT_SAFARI
- (void)webViewDidStartLoad:(UIWebView *)webView{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	NSString* errorString = [NSString stringWithFormat:
							 @"<html><center><font size=+15 color='red'>This page can't be displayed:<br>%@</font></center></html>",
							 nil];
	[myWebView loadHTMLString:errorString baseURL:nil];
}
#endif

#pragma mark -
#pragma mark Email stuff

-(void)btncontactTouched{
	//[contactActionsheet  showInView:containview];
	//[self makeTextField];
	
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
			[self displayEmailComposer];
		}
		else
		{
			[self noEmailWarning];
		}
	}
	else
	{
		[self noEmailWarning];
	}
	
}

-(void)noEmailWarning{
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"No email account is setup on this device." message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
	[errorAlert release];
}

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayEmailComposer
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	[picker setSubject:[customStringDict objectForKey:@"RequestEmailSubject"]];
	
	// Set up recipients
	NSString * email = [NSString stringWithFormat:@"RequestEmail%d", m_curBroadcastStationID+1];
	NSArray *toRecipients = [NSArray arrayWithObject:[customStringDict objectForKey:email]]; 
	[picker setToRecipients:toRecipients];
	
	[self presentModalViewController:picker animated:YES];
    [picker release];
}


// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -

-(void)makeTextField{
	
	
	mailview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 32, 320, 430)];
	mailview.backgroundColor = [UIColor whiteColor];
	mailview.image=[UIImage imageNamed:@"song-request2.png"];
	[contactActionsheet addSubview:mailview];	
	
	NSString * email = [NSString stringWithFormat:@"RequestEmail%d", m_curBroadcastStationID+1];
	txtaddress.borderStyle=UITextBorderStyleRoundedRect;
	txtaddress.text=[customStringDict objectForKey:email];
	txtaddress.delegate=self;
	txtaddress.userInteractionEnabled=NO;
	txtaddress.keyboardType=UIKeyboardTypeEmailAddress;
	txtaddress.returnKeyType=UIReturnKeyDone; 
	//[contactActionsheet addSubview:txtaddress];
	
	
	
	txttitle.borderStyle=UITextBorderStyleRoundedRect;
	txttitle.text=@"Song Request";
	txttitle.delegate=self;
	txttitle.userInteractionEnabled=NO;
	txttitle.keyboardType=UIKeyboardTypeAlphabet;
	txttitle.returnKeyType=UIReturnKeyDone; 
	//[contactActionsheet addSubview:txttitle];
	
	
	
	imgvtextviewbg.image=[UIImage imageNamed:@"Picture1.png"];
	[contactActionsheet addSubview:imgvtextviewbg];
	
	
	txtviewcontent.textColor = [UIColor blackColor];
    txtviewcontent.font = [UIFont fontWithName:@"Times New Roman" size:20];
	txtviewcontent.backgroundColor = [UIColor clearColor];
	txtviewcontent.delegate=self;
	txtviewcontent.keyboardType=UIKeyboardTypeAlphabet;
	txtviewcontent.returnKeyType=UIReturnKeyDefault; 
	[contactActionsheet addSubview:txtviewcontent];
	
	/*txttemp=[[UITextField alloc] init ];
	 txttemp.frame=CGRectMake(30, 135, 250, 80);
	 txttemp.borderStyle=UITextBorderStyleRoundedRect;
	 txttemp.placeholder=@"Message";
	 txttemp.secureTextEntry=YES;
	 txttemp.delegate=self;
	 txttemp.keyboardType=UIKeyboardTypeAlphabet;
	 txttemp.returnKeyType=UIReturnKeyDone;*/ 
	//[contactActionsheet addSubview:txttemp];
	
	[contactActionsheet addSubview:doneButton];
	
	[btnsend setBackgroundImage:[UIImage imageNamed:@"send_1.png"] forState:UIControlStateNormal];
	[btnsend setBackgroundImage:[UIImage imageNamed:@"send_2.png"] forState:UIControlStateHighlighted];
	[btnsend addTarget:self action:@selector(btnsendtouched:) forControlEvents:UIControlEventTouchUpInside];
	[contactActionsheet addSubview:btnsend];
	
	[btndiscard setBackgroundImage:[UIImage imageNamed:@"discard1.png"] forState:UIControlStateNormal];
	[btndiscard setBackgroundImage:[UIImage imageNamed:@"discard2.png"] forState:UIControlStateHighlighted];
	[btndiscard addTarget:self action:@selector(btndiscardtouched:) forControlEvents:UIControlEventTouchUpInside];
	[contactActionsheet addSubview:btndiscard];
	
}

-(void)btndiscardtouched:(id)sender{
	
	txtaddress.text=nil;
	txttitle.text=nil;
	txtviewcontent.text=nil;
	[(UIActionSheet *)[sender superview] dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)btnsendtouched:(id)sender{
	
	if(txtaddress.text==nil)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please specify at least one recipient." 
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		
		//[contactActionsheet setAlpha:0.0];
		[(UIActionSheet *)[sender superview] dismissWithClickedButtonIndex:0 animated:YES];
		
	    alert.tag=1;
		[alert show];
		[alert release];
		
	}
	else
	{
		
		NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
		NSMutableString *str=[[NSMutableString alloc]init];
		[str appendString:@"http://216.154.210.170/mail/mail.php?"];
		[str appendString:@"&msg="];
		[str appendString:txtviewcontent.text];
		[str retain];
		//NSLog(@"str :: %@",str);
		
		[request setURL:[NSURL URLWithString:str]];
		
		NSURLConnection *conn=[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
		if(conn)
			NSLog(@"Connected");
		else
			NSLog(@"Not Connected");
		
		txtaddress.text=nil;
		txttitle.text=nil;
		txtviewcontent.text=nil;
		
		[(UIActionSheet *)[sender superview] dismissWithClickedButtonIndex:0 animated:YES];
	}
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(actionSheet.tag==1)
	{
		if(buttonIndex==0)
		{
			[contactActionsheet  showInView:containview];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	NSLog(@"HERE RESPONSE: %d",[(NSHTTPURLResponse*) response statusCode]);
	if(d2)
		[d2 release];
	d2=[[NSMutableData alloc]init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[d2 appendData:data];	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	NSString *data_Response = [[NSString alloc] initWithData:d2 encoding: kCFStringEncodingUTF8];
	NSLog(@"Responsexxxxxxxxxxxxxxxxxxxxxxxxxxxxx=%@",data_Response);
	
}

/*- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
 return YES;
 }
 
 - (BOOL)textFieldShouldReturn:(UITextField *)textField{
 [textField resignFirstResponder];
 return YES;
 }
 
 - (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
 
 return YES;
 }*/


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
	doneButton.hidden=NO;
	[doneButton addTarget:self action:@selector(keyDown:) forControlEvents:UIControlEventTouchUpInside ];
	txtviewcontent.backgroundColor = [UIColor whiteColor];
	return YES;
}

/*Keyboard down after editing the email template*/

- (void)keyDown:(id)sender{
	doneButton.hidden=YES;
	[txtviewcontent resignFirstResponder];
	if(txtviewcontent.text.length==0 )
		txtviewcontent.backgroundColor=[UIColor clearColor];
	
}

/*// Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }*/


//code to create a button
-(UIButton *)CreateButtonWithFrame:(CGRect)Frame {
	
	UIButton *button=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
	button.frame =Frame;
	return button;
	
}

- (void)metaDataUpdated:(NSString *)metaData{
	// for now just hack the metadata so it looks ok.
	NSString *tmp = [metaData stringByReplacingOccurrencesOfString:@"StreamTitle='" withString:@"StreamTitle"];
	NSString *tmp2 = [tmp stringByReplacingOccurrencesOfString:@"';" withString:@""];
	// NSLog(@"%@",tmp2);
	NSArray	*arrtemp=[tmp2 componentsSeparatedByString:@"StreamUrl"];
	NSArray *arrTemp1=[[arrtemp objectAtIndex:0] componentsSeparatedByString:@"StreamTitle"];
	NSLog(@"%@",[arrTemp1 objectAtIndex:1]);
	NSString *meta=[arrTemp1 objectAtIndex:1];

#if 1	
	NSArray *arractmetadata = nil;
	
	if([arrtemp count]==1) 
		arractmetadata=[meta componentsSeparatedByString:@" - "];
	
	if(arractmetadata != nil || [arrtemp count]==2)
	{
		//NSString *strtemp2=[arrtemp objectAtIndex:0];
		//NSLog(@"%@",strtemp2);
		//actmeta=[[strtemp2 componentsSeparatedByString:@"StreamTitle"] objectAtIndex:1];
        [metaDataLabel1 setTextAlignment:NSTextAlignmentCenter]; //deprecated text alignment UITextAlignmentCenter];
		[metaDataLabel2 setTextAlignment:NSTextAlignmentCenter]; //deprecated text alignment UITextAlignmentCenter];
		
		if (arractmetadata==nil)
			arractmetadata=[meta componentsSeparatedByString:@" - "];
		
		if([arractmetadata count]==1)
		{
			metaDataLabel1.text = [arractmetadata objectAtIndex:0];
			metaDataLabel1.textColor=[UIColor whiteColor];
			metaDataLabel2.text = @"";
		}
		
		else
		{
			NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxxenterxxxxxxxxxxxxxxxxxxxxxxxxxx");
			metaDataLabel1.text = [arractmetadata objectAtIndex:0];
			metaDataLabel1.textColor=[UIColor whiteColor];
			
			metaDataLabel2.text = [arractmetadata objectAtIndex:1];
		    metaDataLabel2.textColor=[UIColor whiteColor];
		}
		
	}
#else	
	if([arrtemp count]==2)
	{
		//NSString *strtemp2=[arrtemp objectAtIndex:0];
		//NSLog(@"%@",strtemp2);
		//actmeta=[[strtemp2 componentsSeparatedByString:@"StreamTitle"] objectAtIndex:1];
		[metaDataLabel1 setTextAlignment:UITextAlignmentCenter];
		[metaDataLabel2 setTextAlignment:UITextAlignmentCenter];
		
		NSArray *arractmetadata=[meta componentsSeparatedByString:@" - "];
		if([arractmetadata count]==1)
		{
		metaDataLabel1.text = [arractmetadata objectAtIndex:0];
		metaDataLabel1.textColor=[UIColor whiteColor];
		}
		
		else
		{
			NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxxenterxxxxxxxxxxxxxxxxxxxxxxxxxx");
			metaDataLabel1.text = [arractmetadata objectAtIndex:0];
			metaDataLabel1.textColor=[UIColor whiteColor];
		
			metaDataLabel2.text = [arractmetadata objectAtIndex:1];
		    metaDataLabel2.textColor=[UIColor whiteColor];
		}
		
	}
#endif	
}

//this code will try to reconnect the url by calling reconnectStream through a timer
- (void)streamError {
	//NSLog(@"Stream Error");
	metaDataLabel1.text = @"";
	metaDataLabel2.text = @"";
	
	// We can try to reconnect...
	[loadingIndicatorView startAnimating];
	timer = [NSTimer scheduledTimerWithTimeInterval: 3.0
											 target: self
										   selector: @selector(reconnectStream)
										   userInfo: nil
											repeats: YES];	
}

- (void)reconnectStream{
	/*this code will check that the conection reachable or not,if reachable then reachability via 
	 ReachableViaCarrierDataNetwork or ReachableViaWiFiNetwork */
	if ([self verifyConnection])
	{
		//[containview setUserInteractionEnabled:YES];
		[timer invalidate];
		timer = nil;
		[loadingIndicatorView stopAnimating];
		//if reachable then it will stop animating
		//NSLog(@"Restarting the stream...");
		[self startStream:nil];
	}
	else
	{
		NSLog(@"Connection is not available, sleep 3 seconds.");
	}
}

- (void)reachabilityChanged:(NSNotification *)note{
	[self updateStatus];
	
	//NSLog(@"rechabilityChanged");
}

//this will check the status of the network connection
- (void)updateStatus{
	// Query the SystemConfiguration framework for the state of the device's network connections.
	self.remoteHostStatus           = [[Reachability sharedReachability] remoteHostStatus];
	self.internetConnectionStatus	= [[Reachability sharedReachability] internetConnectionStatus];
	self.localWiFiConnectionStatus	= [[Reachability sharedReachability] localWiFiConnectionStatus];
}

/*this code will check that the conection reachable or not,if reachable then reachability via 
 ReachableViaCarrierDataNetwork or ReachableViaWiFiNetwork */
- (BOOL)verifyConnection{
	if (self.internetConnectionStatus == NotReachable) {
		NSLog(@"NotReachable");
		return NO;
	}
	else if (self.internetConnectionStatus == ReachableViaCarrierDataNetwork) {
		NSLog(@"ReachableViaCarrierDataNetwork");
	}
	else if (self.internetConnectionStatus == ReachableViaWiFiNetwork) {
		NSLog(@"ReachableViaWiFiNetwork");
	}
	
	return YES;
}

//code to find the host address
- (NSString *)hostName{
	// Don't include a scheme. 'http://' will break the reachability checking.
	// Change this value to test the reachability of a different host.
	return @"http://www.StreamGeeks.com";
}


- (void)startStream:(id)sender {
	
	[btnplay setUserInteractionEnabled:NO];
	btnplay.hidden=YES;
	[btnpause setUserInteractionEnabled:YES];
	btnpause.hidden=NO;
	//slid.value = 1.0f;
	
	//this code will  execute when the connection is establish
	if ([self verifyConnection]) {
		
		//[containview setUserInteractionEnabled:YES];
		[self startStopStream];
		
	}
	
	//this code will  execute when the connection doesn't be found
	else {
		
		[loadingIndicatorView stopAnimating];
		/*
         vUIAlertController *alert = [[UIAlertController alloc] initWithTitle:@"Connection Error" , preferredStyle: .alert
         message:@"An Internet
         */
		// open an alert with just an OK button
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"An Internet connection could not be found. Please check your connection and try again."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        //[alert preferredStyle]:UIAlertControllerStyleAlert;
		[alert show];	
		[alert release];	
	}
	
	// enable background
	[self BackGroundEnabled:YES];
}

//this function will call the startStopStream function to generate the url
- (void)stopStream:(id)sender{ 
	
	mute=NO;
	[btnmute setBackgroundImage:[UIImage imageNamed:@"sound.png"] forState:UIControlStateNormal];
	[btnplay setUserInteractionEnabled:YES];
	btnplay.hidden=NO;
	[btnpause setUserInteractionEnabled:NO];
	btnpause.hidden=YES;
	
	if (streamer!=nil)
		[self startStopStream];
	
	// disable background
	[self BackGroundEnabled:NO];
}

//this function will generate the url and will asign it to streamer
- (void)startStopStream{
	NSString *escapedValue;
	
	if (!streamer)
	{
		NSString * streamURL;
		
#ifdef SUPPORT_128KBPS	
		
		if(streamBandwidthSelection==0)
		{
			streamURL = [NSString stringWithFormat:@"streamWiFiURL%d", m_curBroadcastStationID+1];
			
			NSLog(@"streamURL=%d",m_curBroadcastStationID);
			NSLog(@"temp=%d",streamBandwidthSelection);
			
			escapedValue =
			[(NSString *)CFURLCreateStringByAddingPercentEscapes(
																 nil,
																 (CFStringRef)[customStringDict objectForKey:streamURL],
																 NULL,
																 NULL,
																 kCFStringEncodingUTF8)
			 autorelease];
			
		}
		else
		{
			if(streamBandwidthSelection==1)
			{
				streamURL = [NSString stringWithFormat:@"stream3gURL%d", m_curBroadcastStationID+1];
				
				NSLog(@"streamURL=%d",m_curBroadcastStationID);
				NSLog(@"temp=%d",streamBandwidthSelection);		
				escapedValue =
				[(NSString *)CFURLCreateStringByAddingPercentEscapes(
																	 nil,
																	 (CFStringRef)[customStringDict objectForKey:streamURL],
																	 NULL,
																	 NULL,
																	 kCFStringEncodingUTF8)
				 autorelease];
				
			}
		}    
#else
        streamURL = @"www.sunshineradionetwork.com/play/listen.pls";
        //[NSString stringWithFormat:@"streamURL%d", m_curBroadcastStationID+1];
        NSLog(@"%@", streamURL );
		NSLog(@"streamURL=%d",m_curBroadcastStationID);
		//NSLog(@"temp=%d",streamBandwidthSelection);
        /*
         CFURLCreateStringByAddingPercentEscapes' is deprecated: first deprecated in iOS 9.0 - Use [NSString stringByAddingPercentEncodingWithAllowedCharacters:] instead, which always uses the recommended UTF-8 encoding, and which encodes for a specific URL component or subcomponent (since each URL component or subcomponent has different rules for what characters are valid).
         
         */
        
        NSCharacterSet *allowedCharacters = [NSCharacterSet URLFragmentAllowedCharacterSet];
        escapedValue = [streamURL stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
		/*escapedValue =
		[(NSString *)CFURLCreateStringByAddingPercentEscapes(
															 nil,
															 (CFStringRef)[customStringDict objectForKey:streamURL],
															 NULL,
															 NULL,
															 kCFStringEncodingUTF8)
		 autorelease];*/
#endif
		
		NSURL *url = [NSURL URLWithString:escapedValue];            
		streamer = [[AudioStreamer alloc] initWithURL:url];
		[streamer
		 addObserver:self
		 forKeyPath:@"isPlaying"
		 options:0
		 context:nil];
		
		[streamer setDelegate:self];
		[streamer setDidUpdateMetaDataSelector:@selector(metaDataUpdated:)];//code to replace string by space
		[streamer setDidErrorSelector:@selector(streamError)];//this code will execute if any error occured during URL selection 
		
		[streamer start];//this will start a new thread to run the URL
		
		[loadingIndicatorView startAnimating];//this will show a loading animation
	}
	else
	{
		[streamer stop];
		metaDataLabel1.text = @"";
		metaDataLabel2.text = @"";
		[loadingIndicatorView stopAnimating];
		[streamer release];
		streamer = 0;
	}
	
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change context:(void *)context{
	if ([keyPath isEqual:@"isPlaying"])
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		if ([(AudioStreamer *)object isPlaying])
		{
			[loadingIndicatorView stopAnimating];
		}
		else
		{
			[streamer removeObserver:self forKeyPath:@"isPlaying"];
			[streamer release];
			streamer = nil;
			
			[loadingIndicatorView stopAnimating];
		}
		
		[pool release];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change
						  context:context];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	
	
	if(imgv3)
		[imgv3    release];
	
	//if(imgvlogo)
	//	[imgvlogo release];
	
	if(slid)
		[slid     release];
	
	if(imgvtextviewbg)
		[imgvtextviewbg release];

	if (m_arrayStations)
		[m_arrayStations release];

#ifdef SUPPORT_CUSTOM_STATION_PICKER
	[self ReleaseCustomStationPicker];
#endif
	
#ifdef SUPPORT_STATION_PICKER	
	if (m_djbStationPicker)
		[m_djbStationPicker release];
	
	if (m_arrayStationsKey)
		[m_arrayStationsKey release];
#endif		

	if(imgvheading)
		[imgvheading release];
	
	if(metaDataLabel1)
		[metaDataLabel1 release];
	
	if(metaDataLabel2)
	 [metaDataLabel2 release];
	
#ifdef SUPPORT_SETTING	
#ifdef SUPPORT_RUN_BACKGROUND
	if (m_backGndRunSwitchCtl)
		[m_backGndRunSwitchCtl release];
#endif	
#endif
	
#ifdef SUPPORT_SETTING	
	if(settingsview)
		[settingsview release];
	
	if(DateActionSheet)
		[DateActionSheet release];
#endif	
	
#ifndef SUPPORT_SAFARI	
	if(myWebView)
	    [myWebView release];
#endif
	
	if(infoview)
		[infoview release];

#ifdef SUPPORT_HELP	
	if(helpActionSheet) {
		// release help resource
		[self ReleaseHelpPageRes];
		// release help sheet
		[helpActionSheet release];
	}
#endif	
	
	if(infoActionSheet) {
		// release info resource
		[self ReleaseInfoPageRes];
		// release info sheet
		[infoActionSheet release];
	}
	
	if(txtaddress)
		[txtaddress release];
	
	if(txttitle)
		[txttitle release];
	
	if(streamer)
		[streamer release];
	
	if(txtviewcontent)
		[txtviewcontent release];
	
	if(txtaddress)
		[txtaddress release];
	
	if(txttitle)
		[txttitle release];
	
	if(txtviewcontent)
		[txtviewcontent release];
	
	if(mailview)
		[mailview release];
	
	if(contactActionsheet)
		[contactActionsheet release];
	
	if(d2)
	    [d2 release];
	
	if(styleSegmentedControl)
		[styleSegmentedControl release];
	
	//[request release];
	if(arr)
		[arr release];
	
	if(loadingIndicatorView)
		[loadingIndicatorView dealloc];
	
	[containview removeFromSuperview];
	
	if(containview)
		[containview release];
	if (customStringDict)
		[customStringDict release];
	
	[super dealloc];
}

// INFO Page
- (void) SetupInfoPageRes
{
	if( (stationLink = [self CreateButtonWithFrame:CGRectMake(10, 250, 300, 40)]) != 0 ) {
		[stationLink setBackgroundImage:[UIImage imageNamed:@"WHITE.png"] forState:UIControlStateNormal];
		[stationLink setBackgroundImage:[UIImage imageNamed:@"WHITE.png"] forState:UIControlStateHighlighted];
		[stationLink addTarget:self action:@selector(openStationLink:) forControlEvents:UIControlEventTouchUpInside];
		[infoActionSheet addSubview:stationLink];
	}
	
	UILabel *stationLinkLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 250, 300, 40)] retain];
	stationLinkLabel.backgroundColor = [UIColor clearColor];
	stationLinkLabel.opaque = NO;
	stationLinkLabel.textColor = [UIColor blueColor];
	stationLinkLabel.font = [UIFont boldSystemFontOfSize:22];
	stationLinkLabel.adjustsFontSizeToFitWidth = YES;
	stationLinkLabel.numberOfLines=1;
    stationLinkLabel.textAlignment = NSTextAlignmentCenter;  // update this is dep UITextAlignmentCenter;
	stationLinkLabel.minimumFontSize=18;  // docs say to use minimumScaleFactor but i don't understand

	// get station name
	if( (stationLinkLabel.text = [self GetCustomDicValue:[self GetCustomDicKey:@"WebSiteName" order:m_curBroadcastStationID]]) == 0 ) {
		stationLinkLabel.textColor = [UIColor redColor];
		stationLinkLabel.text = @"No Station Name";
	}
	
	[infoActionSheet addSubview:stationLinkLabel];
	
	if( (djbLink = [self CreateButtonWithFrame:CGRectMake(80, 150, 160, 50)]) != 0 ) {
		[djbLink setBackgroundImage:[UIImage imageNamed:@"DJB.png"] forState:UIControlStateNormal];
		[djbLink setBackgroundImage:[UIImage imageNamed:@"DJB2.png"] forState:UIControlStateHighlighted];
		[djbLink addTarget:self action:@selector(openDJBLink:) forControlEvents:UIControlEventTouchUpInside];
		[infoActionSheet addSubview:djbLink];
	}
	
	if( (facebookLink= [self CreateButtonWithFrame:CGRectMake(62, 380, kStdInfoButtonWidth, kStdInfoButtonHeight)]) != 0 ) {
		[facebookLink setBackgroundImage:[UIImage imageNamed:@"Facebook.png"] forState:UIControlStateNormal];
		[facebookLink setBackgroundImage:[UIImage imageNamed:@"Facebook2.png"] forState:UIControlStateHighlighted];
		[facebookLink addTarget:self action:@selector(openFacebookLink:) forControlEvents:UIControlEventTouchUpInside];
		[infoActionSheet addSubview:facebookLink];
	}
	
	if( (twitterLink = [self CreateButtonWithFrame:CGRectMake(116, 380, kStdInfoButtonWidth, kStdInfoButtonHeight)]) != 0 ) {
		[twitterLink setBackgroundImage:[UIImage imageNamed:@"Twitter.png"] forState:UIControlStateNormal];
		[twitterLink setBackgroundImage:[UIImage imageNamed:@"Twitter2.png"] forState:UIControlStateHighlighted];
		[twitterLink addTarget:self action:@selector(openTwitterLink:) forControlEvents:UIControlEventTouchUpInside];
		[infoActionSheet addSubview:twitterLink];
	}

	if( (myspaceLink = [self CreateButtonWithFrame:CGRectMake(170, 380, kStdInfoButtonWidth, kStdInfoButtonHeight)]) != 0 ) {
		[myspaceLink setBackgroundImage:[UIImage imageNamed:@"MySpace.png"] forState:UIControlStateNormal];
		[myspaceLink setBackgroundImage:[UIImage imageNamed:@"MySpace2.png"] forState:UIControlStateHighlighted];
		[myspaceLink addTarget:self action:@selector(openMyspaceLink:) forControlEvents:UIControlEventTouchUpInside];
		[infoActionSheet addSubview:myspaceLink];
	}

	if( (youtubeLink = [self CreateButtonWithFrame:CGRectMake(224, 380, kStdInfoButtonWidth, kStdInfoButtonHeight)]) != 0 ) {
		[youtubeLink setBackgroundImage:[UIImage imageNamed:@"YouTube.png"] forState:UIControlStateNormal];
		[youtubeLink setBackgroundImage:[UIImage imageNamed:@"YouTube2.png"] forState:UIControlStateHighlighted];
		[youtubeLink addTarget:self action:@selector(openYoutubeLink:) forControlEvents:UIControlEventTouchUpInside];
		[infoActionSheet addSubview:youtubeLink];
	}
}

-(void)openStationLink:(id)sender{
	[self OpenLink:[self GetCustomDicKey:@"WebSiteURL" order:m_curBroadcastStationID]];
}

-(void)openDJBLink:(id)sender{
	[self OpenLink:@"InfoPageURL"];
}

-(void)openFacebookLink:(id)sender{
	[self OpenLink:@"FacebookURL"];
}

-(void)openTwitterLink:(id)sender{
	[self OpenLink:@"TwitterURL"];
}

-(void)openMyspaceLink:(id)sender{
	[self OpenLink:@"MySpaceURL"];
}

-(void)openYoutubeLink:(id)sender{
	[self OpenLink:@"YoutubeURL"];
}

- (void) OpenLink:(NSString *)pLinkKey
{
	NSString * pLink = [customStringDict objectForKey:pLinkKey];
	
	if (pLink == nil || [pLink length] == 0) {
		// release info resource
		[self ReleaseInfoPageRes];
		// close info
		[(UIActionSheet *)infoActionSheet dismissWithClickedButtonIndex:0 animated:YES];
		
		// open an alert with just an OK button
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Link Open Error" message:@"Sorry, no link defined."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		//[infoActionSheet bringSubviewToFront:alert];
		[alert release];	
		return;
	}
	
	// open link
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:pLink]];
}

- (void) ReleaseInfoPageRes
{
	if (stationLink) {
		[stationLink release];
		stationLink = 0;
	}
	if (djbLink) {
		[djbLink release];
		djbLink = 0;
	}
	if (facebookLink) {
		[facebookLink release];
		facebookLink = 0;
	}
	if (myspaceLink) {
		[myspaceLink release];
		myspaceLink = 0;
	}
	if (youtubeLink) {
		[youtubeLink release];
		youtubeLink = 0;
	}
	if (twitterLink) {
		[twitterLink release];
		twitterLink = 0;
	}
}

// load configuration data
- (void) LoadDJBConfig
{
	// get the documents directory, where we will write configs and save games
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	[documentsDirectory getCString: g_iphoneDocDirectory 
						 maxLength: sizeof( g_iphoneDocDirectory ) - 1
						  encoding: NSASCIIStringEncoding ];
	
	// get the app directory, where our data files live
	[[[NSBundle mainBundle] bundlePath] getCString: g_iphoneAppDirectory 
										 maxLength: sizeof( g_iphoneAppDirectory ) - 1 
										  encoding: NSASCIIStringEncoding];
	
	// init game config
	InitDJBConfig(DJB_CONFIG);
}

- (void) BackUpConfig
{
	// save data
	SaveDJBData();	
}

- (int) GetSelectedPickerRowFromConfig
{
	unsigned long count = [m_arrayStations count];  //update to x64
	char * pStation = GetStation();
	char szPickerStation[128];
	
	for(int i = 0; i < count; i++) {
		strcpy(szPickerStation, [[m_arrayStations objectAtIndex:i] UTF8String]);
		if (strcmp(pStation, szPickerStation) == 0)
			return i;
	}
	
	return 0;
}

#ifdef SUPPORT_RUN_BACKGROUND
// BACKGROUND RUN

- (void) BackGroundEnabled:(BOOL)bEnabled
{	
	// save configuration
	SetBackGndEnabled(bEnabled==YES ? 1 : 0);
	// save the m_backgroundRunEnabled flag
	m_backgroundRunEnabled = GetBackGndEnabled() ? YES : NO;
	
	if( m_prevBackgroundRunEnabled != m_backgroundRunEnabled ) {
		// Handle Audio Remote Control events (only available under iOS 4
		if (m_backgroundRunDevEnabled==YES) {
			if (m_prevBackgroundRunEnabled) { 
				// switch off
				if ([[UIApplication sharedApplication] respondsToSelector:@selector(endReceivingRemoteControlEvents)]){
					[[UIApplication sharedApplication] endReceivingRemoteControlEvents];
				}
			} else {
				// switch on
				if ([[UIApplication sharedApplication] respondsToSelector:@selector(beginReceivingRemoteControlEvents)]){
					[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
				}
			}
		}
	}
	
	m_prevBackgroundRunEnabled = m_backgroundRunEnabled;
}

- (void)BackGroundSwitchAction:(id)sender
{
	// NSLog(@"switchAction: value = %d", [sender isOn]);
	[self BackGroundEnabled:[sender isOn]];
}

- (void) CheckBackGroundEnabled
{
	// 1) Device capability
	UIDevice * device = [UIDevice currentDevice];
	
	m_backgroundRunDevEnabled = NO;
	
	if ([device respondsToSelector:@selector(isMultitaskingSupported)])
		m_backgroundRunDevEnabled = device.multitaskingSupported;
	
	// 2) User Selection
	m_prevBackgroundRunEnabled = m_backgroundRunEnabled = GetBackGndEnabled() ? YES : NO;
}

- (void) EnterBackground
{
	if( m_backgroundRunDevEnabled )	{
		if( !m_backgroundRunEnabled )
			exit(0);
	}
}

#endif

- (void) InitStationInfo
{
	NSString * key;
	NSString * info;
	
	// picker data source and reference
	m_arrayStations = [[NSMutableArray alloc] init];
	m_arrayStationsImage = [[NSMutableArray alloc] init];
	
	if (m_arrayStations==nil || m_arrayStationsImage==nil) {
		if (m_arrayStations)
			[m_arrayStations release];
			
		if (m_arrayStationsImage)
			[m_arrayStationsImage release];
		return;
	}
	
	int i = 0;
	while(true) {
		// add picker station name	
		if( (key = [self GetCustomDicKey:@"WebSiteName" order:i]) == 0 )
			break;
		
		// save key
		[m_arrayStations addObject:key];
		
		// add station image name
		if( (key = [self GetCustomDicKey:@"StationGraphics" order:i]) == 0 )
			break;
		
		if((info=[self GetCustomDicValue:key]) != 0 )
			[m_arrayStationsImage addObject:info];
		else
			[m_arrayStationsImage addObject:@"none"];
		
		i++;
	}
	
	m_prevBroadcastStationID = m_curBroadcastStationID = [self GetSelectedPickerRowFromConfig];
}
		 
- (NSString*) GetStationRefKey:(NSString *)pStation
{
	return [pStation stringByReplacingOccurrencesOfString:@" " withString:@""];
}

#ifdef SUPPORT_STATION_PICKER
#pragma mark -
#pragma mark Picker View Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	
	return [m_arrayStations count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	return [m_arrayStations objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
	SetStation((char *)[[m_arrayStations objectAtIndex:row] UTF8String]);
	NSLog(@"Selected Station: %@. Index of selected Station: %i", [m_arrayStations objectAtIndex:row], row);
}

- (CGFloat)pickerView:(UIPickerView *)thePickerView widthForComponent:(NSInteger)component {
	return 250.0;
}

#if 0
- (UIView *)pickerView:(UIPickerView *)thePickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView*)view {
	UILabel * retval = (id)view;
	
	if (!retval) {
		retval = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, [thePickerView rowSizeForComponent:component].width, [thePickerView rowSizeForComponent:component].height)] autorelease];
	}
	
	retval.text = [m_arrayStations objectAtIndex:row];
	retval.font = [UIFont systemFontOfSize:12];
	return retval;
}
#endif

#endif

// HELP
#ifdef SUPPORT_HELP
- (void) SetupHelpPageRes
{
	[helpActionSheet  showInView:containview];
	
	helpView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 32, 320, 430)];
	helpView.backgroundColor = [UIColor whiteColor];
	helpView.image=[UIImage imageNamed:@"MainScreen.png"];
	[helpActionSheet addSubview:helpView];	
	
	[btndonehelp setBackgroundImage:[UIImage imageNamed:@"done1.png"] forState:UIControlStateNormal];
	[btndonehelp setBackgroundImage:[UIImage imageNamed:@"done2.png"] forState:UIControlStateHighlighted];
	[btndonehelp addTarget:self action:@selector(btndonehelpTouched:) forControlEvents:UIControlEventTouchUpInside];
	[helpActionSheet addSubview:btndonehelp];

	// add hep tutorial
	
	textView = [[[UITextView alloc] initWithFrame:CGRectMake(0, 32, 320, 430)] autorelease];
	textView.textColor = [UIColor whiteColor];
	textView.font = [UIFont fontWithName:@"Arial" size:18];
	textView.delegate = self;
	textView.backgroundColor = [[[UIColor alloc] initWithWhite:1.0 alpha:0.0] autorelease];
	[textView setEditable:NO];
	
	// get total number of paragraphs 
	int numParagraph = atoi([NSLocalizedString(@"TotalParagraphs", @"") UTF8String]);
	NSString * helpText = @"\n";
	NSString * helpKey;
	NSString * helpData;
	NSString * helpStackedStr;
	
	for( int i = 1; i <= numParagraph; i++ ) {
		helpKey = [NSString stringWithFormat:@"P%d",i];
		helpData = NSLocalizedString(helpKey, @"");
#if 0		
		helpText = [[helpText stringByAppendingString:helpData] retain];
		helpText = [[helpText stringByAppendingString:@"\n\n"] retain];
#else
		helpStackedStr = [helpText copy];
		[helpText release];
		helpText = [NSString stringWithFormat:@"%@%@\n\n",helpStackedStr, helpData];
#endif		
	}
	textView.text = helpText;
//	[helpText release];
	
	textView.returnKeyType = UIReturnKeyDefault;
	//textView.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
	textView.scrollEnabled = YES;
	
	// this will cause automatic vertical resize when the table is resized
	textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	
	[helpActionSheet addSubview:textView];
}
					
- (void) ReleaseHelpPageRes
{
	if( helpView ) {
		[helpView release];
		helpView = 0;
	}
	
	// textView will be auto released
	textView = nil;
}							   
							   
#endif

#ifdef SUPPORT_CUSTOM_STATION_PICKER
- (void) SetupCustomStationPicker
{
    m_pStationPickerView = [[StationPickerView alloc] initWithFrame:CGRectMake((320-(DEFAULT_STATION_WIDTH))/2, (290-DEFAULT_STATION_HEIGHT)/2, DEFAULT_STATION_WIDTH, DEFAULT_STATION_HEIGHT)];
    [m_pStationPickerView setDataSource:self];
    //[[m_pStationPickerView stationContainerView] setDelegate:self];
    [m_pStationPickerView setStationSize:CGSizeMake(DEFAULT_STATION_WIDTH, DEFAULT_STATION_HEIGHT)];
    //[m_pStationPickerView setBackgroundColor:[UIColor blackColor]];
	[m_pStationPickerView setBackgroundColor:[[[UIColor alloc] initWithWhite:1.0 alpha:0.0] autorelease]];
	[m_pStationPickerView setShowsVerticalScrollIndicator:NO];
	[m_pStationPickerView setShowsHorizontalScrollIndicator:NO];
	[m_pStationPickerView setPagingEnabled:YES];
	[m_pStationPickerView setMaxStation:[m_arrayStations count]];
	[m_pStationPickerView setStation:m_curBroadcastStationID];
	 
	// add custom picker into the MainScreen view
    [imgv3 addSubview:m_pStationPickerView];
	
	[m_pStationPickerView reloadDataWithNewContentSize:CGSizeMake(DEFAULT_STATION_WIDTH*[m_pStationPickerView getMaxStation], DEFAULT_STATION_HEIGHT)];
}

- (void) ReleaseCustomStationPicker
{
	if (m_pStationPickerView) {
		[m_pStationPickerView release];
		m_pStationPickerView = 0;
	}	
}

#pragma mark StationPickerViewDataSource method

- (UIView *)stationPickerView:(StationPickerView *)scrollView row:(int)row column:(int)column {
	
    // re-use a tile rather than creating a new one, if possible
    UIImageView *station = (UIImageView *)[m_pStationPickerView dequeueReusableStation];
	
    if (!station) {
        // the scroll view will handle setting the tile's frame, so we don't have to worry about it
        station = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease]; 
		
        // Some of the tiles won't be completely filled, because they're on the right or bottom edge.
        // By default, the image would be stretched to fill the frame of the image view, but we don't
        // want this. Setting the content mode to "top left" ensures that the images around the edge are
        // positioned properly in their tiles. 
        //[station setContentMode:UIViewContentModeTopLeft]; 
        [station setContentMode:UIViewContentModeCenter]; 
    }
    
    // The resolution is stored as a power of 2, so -1 means 50%, -2 means 25%, and 0 means 100%.
    // We've named the tiles things like BlackLagoon_50_0_2.png, where the 50 represents 50% resolution.
	//NSLog(@"%d] %@", column%5, [m_arrayStationsImage objectAtIndex:column%5]);
	
    [station setImage:[UIImage imageNamed:[m_arrayStationsImage objectAtIndex:column]]];

    return station;
}

- (void)stationPickerView:(int)selStation
{
	// check if teh broadcasting station changed
	if( m_prevBroadcastStationID != (m_curBroadcastStationID=selStation) ) {
		// stop current stream
		[self stopStream:nil];
		// start new stream
		[self startStream:nil];
		// save station name
		SetStation((char *)[[m_arrayStations objectAtIndex:(m_prevBroadcastStationID = m_curBroadcastStationID)] UTF8String]);
	}
}

#endif

// COMMON HELPER
- (NSString *)	GetCustomDicKey:(NSString *)key order:(int)order
{
	NSString * dynamicKey;
	
	if( (dynamicKey = [NSString stringWithFormat:@"%@%d", key, order+1]) == nil )
		return nil;
	
	return [customStringDict objectForKey:dynamicKey] != nil ? dynamicKey : nil;
}

- (NSString *)	GetCustomDicValue:(NSString *)key
{
	NSString * value;
	
	if( (value = [customStringDict objectForKey:key]) == nil || [value length] == 0 )
		return nil;
	
	return value;
}

@end
