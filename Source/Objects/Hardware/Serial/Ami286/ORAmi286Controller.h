//--------------------------------------------------------
// ORAmi286Controller
// Created by Mark  A. Howe on Fri Sept 14, 2007
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2005 CENPA, University of Washington. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//Washington at the Center for Experimental Nuclear Physics and 
//Astrophysics (CENPA) sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//Washington reserve all rights in the program. Neither the authors,
//University of Washington, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this software.
//-------------------------------------------------------------

#pragma mark ***Imported Files

@class ORPlotter1D;
@class ORLevelMonitor;

@interface ORAmi286Controller : OrcaObjectController
{
	IBOutlet NSButton*			sendOnAlarmCB;
	IBOutlet NSTextField*		expiredTimeField;
	IBOutlet NSButton*			sendOnExpiredCB;
	IBOutlet NSButton*			sendOnValveChangeCB;
	IBOutlet NSMatrix*			enabledMaskMatrix;
    IBOutlet ORLevelMonitor*	monitor0;
    IBOutlet ORLevelMonitor*	monitor1;
    IBOutlet ORLevelMonitor*	monitor2;
    IBOutlet ORLevelMonitor*	monitor3;
	IBOutlet NSButton*			shipLevelsButton;
    IBOutlet NSButton*			lockButton;
    IBOutlet NSTextField*		portStateField;
    IBOutlet NSPopUpButton*		portListPopup;
    IBOutlet NSPopUpButton*		pollTimePopup;
    IBOutlet NSButton*			openPortButton;
    IBOutlet NSButton*			readLevelsButton;
    IBOutlet NSMatrix*			levelMatrix;
    IBOutlet NSMatrix*			fillStatusMatrix;
    IBOutlet NSMatrix*			level1Matrix;
    IBOutlet NSMatrix*			hiAlarmMatrix;
    IBOutlet NSMatrix*			lowAlarmMatrix;
    IBOutlet NSMatrix*			hiFillPointMatrix;
    IBOutlet NSMatrix*			lowFillPointMatrix;
    IBOutlet NSMatrix*			timeMatrix;
	IBOutlet ORPlotter1D*		plotter0;
	IBOutlet NSPopUpButton*		fillStatePU0;
	IBOutlet NSPopUpButton*		fillStatePU1;
	IBOutlet NSTextField*		alarmStatus0;
	IBOutlet NSTextField*		alarmStatus1;
	IBOutlet NSTextField*		alarmStatus2;
	IBOutlet NSTextField*		alarmStatus3;
	IBOutlet NSTextField*		emailEnabledField;
	IBOutlet NSTableView*		addressList;
	IBOutlet NSButton*			removeAddressButton;
	IBOutlet NSButton*			eMailEnabledButton;
	
	BOOL updateScheduled;
}

#pragma mark ***Initialization
- (id)	 init;
- (void) dealloc;
- (void) awakeFromNib;

#pragma mark ***Notifications
- (void) registerNotificationObservers;
- (void) updateWindow;

#pragma mark ***Interface Management
- (void) sendOnAlarmChanged:(NSNotification*)aNote;
- (void) expiredTimeChanged:(NSNotification*)aNote;
- (void) sendOnExpiredChanged:(NSNotification*)aNote;
- (void) sendOnValveChangeChanged:(NSNotification*)aNote;
- (void) enabledMaskChanged:(NSNotification*)aNote;
- (void) updateTimePlot:(NSNotification*)aNotification;
- (void) shipLevelsChanged:(NSNotification*)aNotification;
- (void) stateChanged:(NSNotification*)aNotification;
- (void) portNameChanged:(NSNotification*)aNotification;
- (void) portStateChanged:(NSNotification*)aNotification;
- (void) updateMonitor:(NSNotification*)aNotification;
- (void) pollTimeChanged:(NSNotification*)aNotification;
- (void) loadLevelTimeValuesForIndex:(int)index;
- (void) loadFillStatusForIndex:(int)index;
- (void) loadAlarmStatusForIndex:(int)index;
- (void) scheduledUpdate;
- (void) updateTank:(int)index;
- (void) fillStateChanged:(NSNotification*)aNote;
- (void) alarmLevelChanged:(NSNotification*)aNote;
- (void) miscAttributesChanged:(NSNotification*)aNote;
- (void) scaleAction:(NSNotification*)aNote;
- (void) eMailEnabledChanged:(NSNotification*)aNote;
- (void) tableViewSelectionDidChange:(NSNotification*)aNote;
- (void) fillPointChanged:(NSNotification*)aNote;

#pragma mark ***Actions
- (IBAction) sendOnAlarmAction:(id)sender;
- (IBAction) expiredTimeAction:(id)sender;
- (IBAction) sendOnExpiredAction:(id)sender;
- (IBAction) sendOnValveChangeAction:(id)sender;
- (IBAction) enabledMaskAction:(id)sender;
- (IBAction) shipLevelsAction:(id)sender;
- (IBAction) lockAction:(id) sender;
- (IBAction) portListAction:(id) sender;
- (IBAction) openPortAction:(id)sender;
- (IBAction) readLevelsAction:(id)sender;
- (IBAction) pollTimeAction:(id)sender;
- (IBAction) hiAlarmAction:(id)sender;
- (IBAction) lowAlarmAction:(id)sender;
- (IBAction) fillStateAction:(id)sender;
- (IBAction) loadHardwareAction:(id)sender;
- (IBAction) addAddress:(id)sender;
- (IBAction) removeAddress:(id)sender;
- (IBAction) eMailEnabledAction:(id)sender;
- (IBAction) hiFillPointAction:(id)sender;
- (IBAction) lowFillPointAction:(id)sender;

#pragma mark ***DataSource
- (float) levelMonitorLevel:(id)aLevelMonitor;
- (void)  setLevelMonitor:(ORLevelMonitor*)aMonitor lowAlarm:(float)aValue;
- (void)  setLevelMonitor:(ORLevelMonitor*)aMonitor hiAlarm:(float)aValue;
- (float) levelMonitorHiAlarmLevel:(id)aLevelMonitor;
- (float) levelMonitorLowAlarmLevel:(id)aLevelMonitor;
- (void) setLevelMonitor:(ORLevelMonitor*)aMonitor lowFillPoint:(float)aValue;
- (void) setLevelMonitor:(ORLevelMonitor*)aMonitor hiFillPoint:(float)aValue;
- (float) levelMonitorHiFillPoint:(id)aLevelMonitor;
- (float) levelMonitorLowFillPoint:(id)aLevelMonitor;

@end

