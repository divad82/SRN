//
//  MyViewController.h
//  PUREGOLDRocknRoll
//
//  Created by pritam on 05/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Reachability.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "StationPickerView.h"

#if 0
#define SUPPORT_STATION_PICKER
#endif
#define SUPPORT_CUSTOM_STATION_PICKER

#if 0
#define SUPPORT_SETTING
#else
#define SUPPORT_HELP
#endif

#define SUPPORT_RUN_BACKGROUND
#define SUPPORT_MULTIPLE_STATION
#define SUPPORT_SAFARI
//#define SUPPORT_128KBPS

@class AudioStreamer;

#ifdef SUPPORT_STATION_PICKER
@interface MyViewController : UIViewController <MFMailComposeViewControllerDelegate,UIActionSheetDelegate,UIWebViewDelegate,UITextFieldDelegate,UITextViewDelegate,UIAlertViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate> {
#endif
	
#ifdef SUPPORT_CUSTOM_STATION_PICKER	
@interface MyViewController : UIViewController <MFMailComposeViewControllerDelegate,UIActionSheetDelegate,UIWebViewDelegate,UITextFieldDelegate,UITextViewDelegate,UIAlertViewDelegate,StationPickerViewDataSource> {
#endif
	UIActivityIndicatorView *loadingIndicatorView;
	AudioStreamer           *streamer;
	
	UIImageView*			imgv3;
	UIImageView				*containview/*,*imgvlogo*/;
	UIImageView				*imgvtextviewbg;
	UIButton				*btnplay,*btnpause,*btnmute,*btninfo,*btncontact,*btnsend;

	UIImageView				*imgvheading;
	UILabel					*metaDataLabel1,*metaDataLabel2;
	UISlider				*slid;
	NSArray					*arr;
#ifndef SUPPORT_SAFARI	
	UIWebView				*myWebView;
	UIButton				*btninfolink1,*btninfolink2;
#endif	
	NSMutableData			*d2;

	NSMutableArray			*m_arrayStations;
	NSMutableArray			*m_arrayStationsImage;	
	
#ifdef SUPPORT_CUSTOM_STATION_PICKER	
    StationPickerView		*m_pStationPickerView;
#endif	
		
#ifdef SUPPORT_SETTING	
	UIButton				*btnplus,*btnminus,*btnsettings,*btndone,*btndoneinfo,*doneButton,*btndiscard;
	IBOutlet UIPickerView	*m_djbStationPicker;
	UIImageView				*infoview,*mailview,*settingsview;
	UIActionSheet			*DateActionSheet,*infoActionSheet,*contactActionsheet;
#endif
	
#ifdef SUPPORT_HELP	
	UIButton				*btnplus,*btnminus,*btnhelp,*btndonehelp,*btndoneinfo,*doneButton,*btndiscard;
	UIImageView				*helpView,*infoview,*mailview;
	UIActionSheet			*helpActionSheet,*infoActionSheet,*contactActionsheet;
	UITextView				*textView;
#endif
		
	UISegmentedControl		*styleSegmentedControl;
	
#ifdef SUPPORT_128KBPS
	int						streamBandwidthSelection;
#endif
	
	UITextField				*txtaddress,*txttitle;
	UITextView				*txtviewcontent;
	BOOL					stop;
	BOOL					mute;
	
	NSInteger				index;
	char					ch;
	
	NSString				*actmeta;
	
#ifdef SUPPORT_RUN_BACKGROUND
#ifdef SUPPORT_SETTING	
	UISwitch*				m_backGndRunSwitchCtl;
#endif	
	BOOL					m_backgroundRunDevEnabled;	
	BOOL					m_backgroundRunEnabled;
	BOOL					m_prevBackgroundRunEnabled;
#endif
	
	UIButton				*djbLink, *facebookLink, *myspaceLink, *youtubeLink, *twitterLink, *stationLink;
	
	int						m_curBroadcastStationID;
	int						m_prevBroadcastStationID;
	
	NetworkStatus			remoteHostStatus;
	NetworkStatus			internetConnectionStatus;
	NetworkStatus			localWiFiConnectionStatus;
	
	NSTimer *				timer;
	
	NSDictionary *			customStringDict;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicatorView;
@property (nonatomic, retain) UIButton *btnplay;
@property (nonatomic, retain) UIButton *btnpause;

@property (nonatomic, retain)  UILabel *metaDataLabel1;
@property (nonatomic, retain)  UILabel *metaDataLabel2;

@property (nonatomic, retain) NSTimer *timer;

@property NetworkStatus remoteHostStatus;
@property NetworkStatus internetConnectionStatus;
@property NetworkStatus localWiFiConnectionStatus;

-(UIButton *)CreateButtonWithFrame:(CGRect)Frame ;
- (void) startStopStream;
- (void)updateStatus;
- (BOOL)verifyConnection;
- (void)reconnectStream;
-(void)makeGUI;
-(void)startStream:(id)sender;
-(void)stopStream:(id)sender;

#ifdef SUPPORT_SETTING
-(void)createSegmentControllerInitWithItem:(NSArray *)items 
								   ofFrame:(CGRect )Frame 
								  Selected:(NSInteger)selected 
							   ContainedIn:(UIView *)view
									Target:(id)object
								 AddAction:(SEL)Action;
#endif

-(void)makeTextField;

-(void)noEmailWarning;
-(void)displayEmailComposer;

// INFO Page
#define kStdInfoButtonWidth			34
#define kStdInfoButtonHeight		34

- (void)		SetupInfoPageRes;
- (void)		ReleaseInfoPageRes;
- (void)		OpenLink:(NSString *)pLinkKey;

#ifdef SUPPORT_RUN_BACKGROUND
// BACKGROUND RUN
- (void)		BackGroundEnabled:(BOOL)bEnabled;
- (void)		CheckBackGroundEnabled;	
- (void)		EnterBackground;
#endif

// DJB CONFIGURATION SUPPORT C WRAPPER
- (void)		LoadDJBConfig;
- (void)		BackUpConfig;

- (int)			GetSelectedPickerRowFromConfig;

- (void)		InitStationInfo;
- (NSString*)	GetStationRefKey:(NSString *)pStation;

// HELP
#ifdef SUPPORT_HELP
- (void)		SetupHelpPageRes;
- (void)		ReleaseHelpPageRes;
#endif
	
// CUSTOME Station Picker	
#ifdef SUPPORT_CUSTOM_STATION_PICKER	
- (void)		SetupCustomStationPicker;
- (void)		ReleaseCustomStationPicker;
#endif
	
// COMMON HELPER
- (NSString *)	GetCustomDicKey:(NSString *)key order:(int)order;		
- (NSString *)	GetCustomDicValue:(NSString *)key;		
	
@end

