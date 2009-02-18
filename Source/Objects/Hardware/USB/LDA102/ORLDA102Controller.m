//
//  ORHPLDA102Controller.m
//  Orca
//
//  Created by Mark Howe on Thurs Jan 26 2007.
//  Copyright (c) 2003 CENPA, University of Washington. All rights reserved.
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

#import "ORLDA102Controller.h"
#import "ORLDA102Model.h"
#import "ORUSB.h"
#import "ORUSBInterface.h"
#import "ORSerialPortList.h"

@implementation ORLDA102Controller
- (id) init
{
    self = [ super initWithWindowNibName: @"LDA102" ];
    return self;
}

- (void) registerNotificationObservers
{
    NSNotificationCenter* notifyCenter = [ NSNotificationCenter defaultCenter ];    
    [ super registerNotificationObservers ];
    
    [notifyCenter addObserver : self
                     selector : @selector(interfacesChanged:)
                         name : ORUSBInterfaceAdded
						object: nil];
	
    [notifyCenter addObserver : self
                     selector : @selector(interfacesChanged:)
                         name : ORUSBInterfaceRemoved
						object: nil];
	
    [notifyCenter addObserver : self
                     selector : @selector(serialNumberChanged:)
                         name : ORLDA102ModelSerialNumberChanged
						object: nil];
	
    [notifyCenter addObserver : self
                     selector : @selector(serialNumberChanged:)
                         name : ORLDA102ModelUSBInterfaceChanged
						object: nil];
		
	[notifyCenter addObserver : self
					 selector : @selector(lockChanged:)
						 name : ORRunStatusChangedNotification
					   object : nil];
	
    [notifyCenter addObserver : self
					 selector : @selector(lockChanged:)
						 name : ORLDA102ModelLock
						object: nil];
    [notifyCenter addObserver : self
                     selector : @selector(attenuationChanged:)
                         name : ORLDA102ModelAttenuationChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(stepSizeChanged:)
                         name : ORLDA102ModelStepSizeChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(rampStartChanged:)
                         name : ORLDA102ModelRampStartChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(rampEndChanged:)
                         name : ORLDA102ModelRampEndChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(dwellTimeChanged:)
                         name : ORLDA102ModelDwellTimeChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(idleTimeChanged:)
                         name : ORLDA102ModelIdleTimeChanged
						object: model];

}

- (void) awakeFromNib
{
	[self populateInterfacePopup:[model getUSBController]];
	[super awakeFromNib];
}

- (void) updateWindow
{
    [ super updateWindow ];
	[self serialNumberChanged:nil];
    [self lockChanged:nil];
	[self attenuationChanged:nil];
	[self stepSizeChanged:nil];
	[self rampStartChanged:nil];
	[self rampEndChanged:nil];
	[self dwellTimeChanged:nil];
	[self idleTimeChanged:nil];
}

- (void) idleTimeChanged:(NSNotification*)aNote
{
	[idleTimeTextField setIntValue: [model idleTime]];
}

- (void) dwellTimeChanged:(NSNotification*)aNote
{
	[dwellTimeTextField setIntValue: [model dwellTime]];
}

- (void) rampEndChanged:(NSNotification*)aNote
{
	[rampEndTextField setFloatValue: [model rampEnd]];
}

- (void) rampStartChanged:(NSNotification*)aNote
{
	[rampStartTextField setFloatValue: [model rampStart]];
}

- (void) stepSizeChanged:(NSNotification*)aNote
{
	[stepSizeTextField setFloatValue: [model stepSize]];
}

- (void) attenuationChanged:(NSNotification*)aNote
{
	[attenuationTextField setFloatValue: [model attenuation]];
}

- (void) checkGlobalSecurity
{
    BOOL secure = [[[NSUserDefaults standardUserDefaults] objectForKey:OROrcaSecurityEnabled] boolValue];
    [gSecurity setLock:ORLDA102ModelLock to:secure];
    [lockButton setEnabled:secure];
}

#pragma mark •••Notifications
- (void) interfacesChanged:(NSNotification*)aNote
{
	[self populateInterfacePopup:[aNote object]];
}

- (void) lockChanged:(NSNotification*)aNote
{
   // BOOL lockedOrRunningMaintenance = [gSecurity runInProgressButNotType:eMaintenanceRunType orIsLocked:ORLDA102ModelLock];
    BOOL locked = [gSecurity isLocked:ORLDA102ModelLock];
	
    [lockButton setState: locked];
	[serialNumberPopup setEnabled:!locked];
}

- (void) serialNumberChanged:(NSNotification*)aNote
{
	if(![model serialNumber] || ![model usbInterface])[serialNumberPopup selectItemAtIndex:0];
	else [serialNumberPopup selectItemWithTitle:[model serialNumber]];
	[[self window] setTitle:[model title]];
}

#pragma mark •••Actions

- (void) idleTimeTextFieldAction:(id)sender
{
	[model setIdleTime:[sender intValue]];	
}

- (void) dwellTimeTextFieldAction:(id)sender
{
	[model setDwellTime:[sender intValue]];	
}

- (void) rampEndTextFieldAction:(id)sender
{
	[model setRampEnd:[sender floatValue]];	
}

- (void) rampStartTextFieldAction:(id)sender
{
	[model setRampStart:[sender floatValue]];	
}

- (void) stepSizeTextFieldAction:(id)sender
{
	[model setStepSize:[sender floatValue]];	
}

- (void) attenuationTextFieldAction:(id)sender
{
	[model setAttenuation:[sender floatValue]];	
}
- (IBAction) settingLockAction:(id) sender
{
    [gSecurity tryToSetLock:ORLDA102ModelLock to:[sender intValue] forWindow:[self window]];
}

- (void) populateInterfacePopup:(ORUSB*)usb
{
	NSArray* interfaces = [usb interfacesForVender:[model vendorID] product:[model productID]];
	[serialNumberPopup removeAllItems];
	[serialNumberPopup addItemWithTitle:@"N/A"];
	NSEnumerator* e = [interfaces objectEnumerator];
	ORUSBInterface* anInterface;
	while(anInterface = [e nextObject]){
		NSString* serialNumber = [anInterface serialNumber];
		if([serialNumber length]){
			[serialNumberPopup addItemWithTitle:serialNumber];
		}
	}
	[self validateInterfacePopup];
	if([model serialNumber])[serialNumberPopup selectItemWithTitle:[model serialNumber]];
	else [serialNumberPopup selectItemAtIndex:0];
}

- (void) validateInterfacePopup
{
	NSArray* interfaces = [[model getUSBController] interfacesForVender:[model vendorID] product:[model productID]];
	NSEnumerator* e = [interfaces objectEnumerator];
	ORUSBInterface* anInterface;
	while(anInterface = [e nextObject]){
		NSString* serialNumber = [anInterface serialNumber];
		if([anInterface registeredObject] == nil || [serialNumber isEqualToString:[model serialNumber]]){
			[[serialNumberPopup itemWithTitle:serialNumber] setEnabled:YES];
		}
		else [[serialNumberPopup itemWithTitle:serialNumber] setEnabled:NO];
	}
}

- (IBAction) serialNumberAction:(id)sender
{
	if([serialNumberPopup indexOfSelectedItem] == 0){
		[model setSerialNumber:nil];
	}
	else {
		[model setSerialNumber:[serialNumberPopup titleOfSelectedItem]];
	}
}

- (IBAction) sendCommandAction:(id)sender
{
	@try {
		[self endEditing];
		if([commandField stringValue]){
			[model writeCommand:[commandField stringValue]];
		}
	}
	@catch(NSException* localException) {
        NSLog( [ localException reason ] );
        NSRunAlertPanel( [ localException name ], 	// Name of panel
						[ localException reason ],	// Reason for error
						@"OK",				// Okay button
						nil,				// alternate button
						nil );				// other button
	}
	
}



@end
