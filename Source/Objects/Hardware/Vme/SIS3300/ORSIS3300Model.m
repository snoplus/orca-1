//-------------------------------------------------------------------------
//  ORSIS3300Model.h
//
//  Created by Mark A. Howe on Wednesday 9/30/08.
//  Copyright (c) 2008 CENPA. University of Washington. All rights reserved.
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

//-------------------------------------------------------------------------

#pragma mark ***Imported Files
#import "ORSIS3300Model.h"
#import "ORDataTypeAssigner.h"
#import "ORHWWizParam.h"
#import "ORHWWizSelection.h"
#import "ORVmeCrateModel.h"
#import "ORRateGroup.h"
#import "ORTimer.h"
#import "VME_HW_Definitions.h"

NSString* ORSIS3300ModelCSRRegChanged		= @"ORSIS3300ModelCSRRegChanged";
NSString* ORSIS3300ModelAcqRegChanged		= @"ORSIS3300ModelAcqRegChanged";
NSString* ORSIS3300ModelEventConfigChanged	= @"ORSIS3300ModelEventConfigChanged";
NSString* ORSIS3300ModelPageSizeChanged			= @"ORSIS3300ModelPageSizeChanged";

NSString* ORSIS3300ModelClockSourceChanged		= @"ORSIS3300ModelClockSourceChanged";
NSString* ORSIS3300ModelStopDelayChanged		= @"ORSIS3300ModelStopDelayChanged";
NSString* ORSIS3300ModelStartDelayChanged		= @"ORSIS3300ModelStartDelayChanged";
NSString* ORSIS3300ModelRandomClockChanged		= @"ORSIS3300ModelRandomClockChanged";

NSString* ORSIS3300ModelStopTriggerChanged		= @"ORSIS3300ModelStopTriggerChanged";
NSString* ORSIS3300RateGroupChangedNotification	= @"ORSIS3300RateGroupChangedNotification";
NSString* ORSIS3300SettingsLock					= @"ORSIS3300SettingsLock";

NSString* ORSIS3300ModelEnabledChanged			= @"ORSIS3300ModelEnabledChanged";
NSString* ORSIS3300ModelThresholdChanged		= @"ORSIS3300ModelThresholdChanged";
NSString* ORSIS3300ModelThresholdArrayChanged	= @"ORSIS3300ModelThresholdArrayChanged";
NSString* ORSIS3300ModelLtGtChanged				= @"ORSIS3300ModelLtGtChanged";
NSString* ORSIS3300ModelSampleDone				= @"ORSIS3300ModelSampleDone";


//general register offsets
#define kControlStatus				0x00		// [] Control/Status
#define kModuleIDReg				0x04		// [] module ID
#define kAcquisitionControlReg		0x10		// [] Acquistion Control 
#define kStartDelay					0x14		// [] Start Delay Clocks
#define kStopDelay					0x18		// [] Start Delay Clocks
#define kGeneralReset				0x20		// [] General Reset
#define kStartSampling				0x30		// [] Start Sampling
#define kStopSampling				0x34		// [] Stop Sampling
#define kStartAutoBankSwitch		0x40		// [] Start Auto Bank Switching
#define kStopAutoBankSwitch			0x44		// [] Start Auto Bank Switching
#define kClearBank1FullFlag			0x48		// [] Clear Bank 1 Full Flag
#define kClearBank2FullFlag			0x4C		// [] Clear Bank 2 Full Flag
#define kEventConfigAll				0x00100000	// [] Event Config (ALL)
#define kTriggerSetupReg			0x100028
#define kTriggerSetupReg			0x100028
#define kTriggerFlagClrCounterReg	0x10001C
#define kMaxNumberEventsReg			0x10002C

// Bits in the data acquisition control register:
//defined state sets value, shift left 16 to clear
#define ACQMask(state,A) ((state)?(A):(A<<16))
#define kSISSampleBank1			0x0001L
#define kSISSampleBank2			0x0002L
#define kSISBankSwitch			0x0004L
#define kSISAutostart			0x0010L
#define kSISMultiEvent			0x0020L
#define kSISEnableStartDelay    0x0040L
#define kSISEnableStopDelay     0x0080L
#define kSISEnableLemoStartStop 0x0100L
#define kSISEnableP2StartStop   0x0200L
#define kSISEnableGateMode      0x0400L
#define kSISEnableRandomClock   0x0800L
#define kSISClockSrcBit1        0x1000L
#define kSISClockSrcBit2        0x2000L
#define kSISClockSrcBit3        0x4000L
#define kSISMultiplexerMode     0x8000L
#define kSISClockSetShiftCount  12
#define kSISBusyStatus			0x00010000
#define kSISBank1ClockStatus	0x00000001
#define kSISBank2ClockStatus	0x00000002

//Control Status Register Bits
//defined state sets value, shift left 16 to clear
#define CSRMask(state,A) ((state)?(A):(A<<16))
#define kSISLed							0x0001L
#define kSISUserOutput					0x0002L
#define kSISEnableTriggerOutput			0x0004L //Enable/Disable Trigger Output, Disable/Enable UserOutput
#define kSISInvertTrigger				0x0010L
#define kSISTriggerOnArmedAndStarted	0x0020L
#define kSISInternalTriggerRouting		0x0040L
#define kSISBankFullTo1					0x0100L
#define kSISBankFullTo2					0x0200L
#define kSISBankFullTo3					0x0400L
#define kCSRReservedMask				0xF888L //reserved bits

// Bits in event register.
#define kSISPageSizeMask       0x00000007
#define kSISWrapMask           0x00000008
#define kSISRandomClock        0x00000800
#define kSISMultiplexerMode2   0x00008000

#define  kSISEventDirEndEventMask	0x1ffff
#define  kSISEventDirWrapFlag		0x80000

//Bits and fields in the threshold register.
#define kSISTHRLt             0x8000
#define kSISTHRChannelShift    16

@implementation ORSIS3300Model

#pragma mark •••Static Declarations
static unsigned long thresholdRegOffsets[4]={
	0x00200004,
	0x00280004,
	0x00300004,
	0x00380004
};

/*static unsigned long eventRegOffsets[4]={
	0x00200008,
	0x00280008,
	0x00300008,
	0x00380008
};
 */
static unsigned long bankMemory[4][2]={
{0x00400000,0x00600000},
{0x00480000,0x00680000},
{0x00500000,0x00700000},
{0x00580000,0x00780000},
};

static unsigned long eventCountOffset[4][2]={ //group,bank
{0x00200010,0x00200014},
{0x00280010,0x00280014},
{0x00300010,0x00300014},
{0x00380010,0x00380014},
};

static unsigned long eventDirOffset[4][2]={ //group,bank
{0x00201000,0x00202000},
{0x00281000,0x00282000},
{0x00301000,0x00302000},
{0x00381000,0x00382000},
};


#define kTriggerEvent1DirOffset 0x101000
#define kTriggerEvent2DirOffset 0x102000
#pragma mark ***Initialization
- (id) init 
{
    self = [super init];
    [[self undoManager] disableUndoRegistration];
    [self initParams];
    [self setAddressModifier:0x09];
    [self setThresholds:[NSMutableArray arrayWithCapacity:kNumSIS3300Channels]];
	int i;
    for(i=0;i<kNumSIS3300Channels;i++){
        [thresholds addObject:[NSNumber numberWithInt:0]];
    }
	dataBuffer = 0;
    [[self undoManager] enableUndoRegistration];
    return self;
}

- (void) dealloc 
{
	if(dataBuffer) free(dataBuffer);
	[thresholds release];
    [waveFormRateGroup release];
    [super dealloc];
}

- (void) setUpImage
{
    [self setImage:[NSImage imageNamed:@"SIS3300Card"]];	
}

- (void) makeMainController
{
    [self linkToController:@"ORSIS3300Controller"];
}

- (NSRange)	memoryFootprint
{
	return NSMakeRange(baseAddress,0x00780000+0x80000);
}

#pragma mark ***Accessors
//csr reg
- (BOOL) bankFullTo3
{
    return bankFullTo3;
}

- (void) setBankFullTo3:(BOOL)aBankFullTo3
{
    [[[self undoManager] prepareWithInvocationTarget:self] setBankFullTo3:bankFullTo3];
    bankFullTo3 = aBankFullTo3;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelCSRRegChanged object:self];
}

- (BOOL) bankFullTo2
{
    return bankFullTo2;
}

- (void) setBankFullTo2:(BOOL)aBankFullTo2
{
    [[[self undoManager] prepareWithInvocationTarget:self] setBankFullTo2:bankFullTo2];
    bankFullTo2 = aBankFullTo2;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelCSRRegChanged object:self];
}

- (BOOL) bankFullTo1
{
    return bankFullTo1;
}

- (void) setBankFullTo1:(BOOL)aBankFullTo1
{
    [[[self undoManager] prepareWithInvocationTarget:self] setBankFullTo1:bankFullTo1];
    bankFullTo1 = aBankFullTo1;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelCSRRegChanged object:self];
}
- (BOOL) enableInternalRouting
{
    return enableInternalRouting;
}

- (void) setEnableInternalRouting:(BOOL)aEnableInternalRouting
{
    [[[self undoManager] prepareWithInvocationTarget:self] setEnableInternalRouting:enableInternalRouting];
    enableInternalRouting = aEnableInternalRouting;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelCSRRegChanged object:self];
}

- (BOOL) activateTriggerOnArmed
{
    return activateTriggerOnArmed;
}

- (void) setActivateTriggerOnArmed:(BOOL)aActivateTriggerOnArmed
{
    [[[self undoManager] prepareWithInvocationTarget:self] setActivateTriggerOnArmed:activateTriggerOnArmed];
    activateTriggerOnArmed = aActivateTriggerOnArmed;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelCSRRegChanged object:self];
}

- (BOOL) invertTrigger
{
    return invertTrigger;
}

- (void) setInvertTrigger:(BOOL)aInvertTrigger
{
    [[[self undoManager] prepareWithInvocationTarget:self] setInvertTrigger:invertTrigger];
    invertTrigger = aInvertTrigger;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelCSRRegChanged object:self];
}

- (BOOL) enableTriggerOutput
{
    return enableTriggerOutput;
}

- (void) setEnableTriggerOutput:(BOOL)aEnableTriggerOutput
{
    [[[self undoManager] prepareWithInvocationTarget:self] setEnableTriggerOutput:enableTriggerOutput];
    enableTriggerOutput = aEnableTriggerOutput;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelCSRRegChanged object:self];
}

//Acquisition control reg
- (BOOL) multiplexerMode
{
    return multiplexerMode;
}

- (void) setMultiplexerMode:(BOOL)aMultiplexerMode
{
    [[[self undoManager] prepareWithInvocationTarget:self] setMultiplexerMode:multiplexerMode];
    multiplexerMode = aMultiplexerMode;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelAcqRegChanged object:self];
}

- (BOOL) bankSwitchMode
{
    return bankSwitchMode;
}

- (void) setBankSwitchMode:(BOOL)aBankSwitchMode
{
    [[[self undoManager] prepareWithInvocationTarget:self] setBankSwitchMode:bankSwitchMode];
    bankSwitchMode = aBankSwitchMode;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelAcqRegChanged object:self];
}

- (BOOL) autoStart
{
    return autoStart;
}

- (void) setAutoStart:(BOOL)aAutoStart
{
    [[[self undoManager] prepareWithInvocationTarget:self] setAutoStart:autoStart];
    autoStart = aAutoStart;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelAcqRegChanged object:self];
}

- (BOOL) multiEventMode
{
    return multiEventMode;
}

- (void) setMultiEventMode:(BOOL)aMultiEventMode
{
    [[[self undoManager] prepareWithInvocationTarget:self] setMultiEventMode:multiEventMode];
    multiEventMode = aMultiEventMode;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelAcqRegChanged object:self];
}
- (BOOL) p2StartStop
{
    return p2StartStop;
}

- (void) setP2StartStop:(BOOL)ap2StartStop
{
    [[[self undoManager] prepareWithInvocationTarget:self] setP2StartStop:p2StartStop];
    p2StartStop = ap2StartStop;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelAcqRegChanged object:self];
}

- (BOOL) lemoStartStop
{
    return lemoStartStop;
}

- (void) setLemoStartStop:(BOOL)aLemoStartStop
{
    [[[self undoManager] prepareWithInvocationTarget:self] setLemoStartStop:lemoStartStop];
    lemoStartStop = aLemoStartStop;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelAcqRegChanged object:self];
}
- (BOOL) gateMode
{
    return gateMode;
}

- (void) setGateMode:(BOOL)aGateMode
{
    [[[self undoManager] prepareWithInvocationTarget:self] setGateMode:gateMode];
    gateMode = aGateMode;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelAcqRegChanged object:self];
}

//clocks and delays (Acquistion control reg)
- (BOOL) randomClock
{
    return randomClock;
}

- (void) setRandomClock:(BOOL)aRandomClock
{
    [[[self undoManager] prepareWithInvocationTarget:self] setRandomClock:randomClock];
    randomClock = aRandomClock;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelAcqRegChanged object:self];
}

- (BOOL) startDelayEnabled
{
    return startDelayEnabled;
}

- (void) setStartDelayEnabled:(BOOL)aStartDelayEnabled
{
    [[[self undoManager] prepareWithInvocationTarget:self] setStartDelayEnabled:startDelayEnabled];
    startDelayEnabled = aStartDelayEnabled;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelAcqRegChanged object:self];
}

- (BOOL) stopDelayEnabled
{
    return stopDelayEnabled;
}

- (void) setStopDelayEnabled:(BOOL)aStopDelayEnabled
{
    [[[self undoManager] prepareWithInvocationTarget:self] setStopDelayEnabled:stopDelayEnabled];
    stopDelayEnabled = aStopDelayEnabled;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelAcqRegChanged object:self];
}

- (int) stopDelay
{
    return stopDelay;
}

- (void) setStopDelay:(int)aStopDelay
{
    [[[self undoManager] prepareWithInvocationTarget:self] setStopDelay:stopDelay];
    stopDelay = aStopDelay;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelStopDelayChanged object:self];
}

- (int) startDelay
{
    return startDelay;
}

- (void) setStartDelay:(int)aStartDelay
{
    [[[self undoManager] prepareWithInvocationTarget:self] setStartDelay:startDelay];
    startDelay = aStartDelay;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelStartDelayChanged object:self];
}
- (int) clockSource
{
    return clockSource;
}

- (void) setClockSource:(int)aClockSource
{
    [[[self undoManager] prepareWithInvocationTarget:self] setClockSource:clockSource];
    clockSource = aClockSource;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelClockSourceChanged object:self];
}


//Event configuration
- (BOOL) pageWrap
{
    return pageWrap;
}

- (void) setPageWrap:(BOOL)aPageWrap
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPageWrap:pageWrap];
    pageWrap = aPageWrap;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelEventConfigChanged object:self];
}

- (BOOL) gateChaining
{
    return gateChaining;
}

- (void) setGateChaining:(BOOL)aState
{
    [[[self undoManager] prepareWithInvocationTarget:self] setGateChaining:gateChaining];
    gateChaining = aState;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelEventConfigChanged object:self];
}

- (BOOL) stopTrigger
{
    return stopTrigger;
}

- (void) setStopTrigger:(BOOL)aStopTrigger
{
    [[[self undoManager] prepareWithInvocationTarget:self] setStopTrigger:stopTrigger];
    
    stopTrigger = aStopTrigger;
	
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelStopTriggerChanged object:self];
}

- (int) pageSize
{
    return pageSize;
}

- (void) setPageSize:(int)aPageSize
{
	if(aPageSize<0)		aPageSize = 0;
	else if(aPageSize>7)aPageSize = 7;
    [[[self undoManager] prepareWithInvocationTarget:self] setPageSize:pageSize];
    pageSize = aPageSize;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelPageSizeChanged object:self];
}

- (int) sampleSize
{
	static unsigned long sampleSize[8]={
		128*1024,
		16*1024,
		4*1024,
		2*1024,
		1*1024,
		512,
		256,
		128
	};
	
	return sampleSize[pageSize];
}

- (int) nPages
{
	return (128*1024)/[self sampleSize];
}

- (ORRateGroup*) waveFormRateGroup
{
    return waveFormRateGroup;
}
- (void) setWaveFormRateGroup:(ORRateGroup*)newRateGroup
{
    [newRateGroup retain];
    [waveFormRateGroup release];
    waveFormRateGroup = newRateGroup;
    
    [[NSNotificationCenter defaultCenter]
	 postNotificationName:ORSIS3300RateGroupChangedNotification
	 object:self];    
}

- (id) rateObject:(int)channel
{
    return [waveFormRateGroup rateObject:channel];
}

- (void) initParams
{
	enabledMask = 0xFFFFFFFF;
}

- (void) setRateIntegrationTime:(double)newIntegrationTime
{
	//we this here so we have undo/redo on the rate object.
    [[[self undoManager] prepareWithInvocationTarget:self] setRateIntegrationTime:[waveFormRateGroup integrationTime]];
    [waveFormRateGroup setIntegrationTime:newIntegrationTime];
}

#pragma mark •••Rates
- (unsigned long) getCounter:(int)counterTag forGroup:(int)groupTag
{
	if(groupTag == 0){
		if(counterTag>=0 && counterTag<kNumSIS3300Channels){
			return waveFormCount[counterTag];
		}	
		else return 0;
	}
	else return 0;
}

- (long) enabledMask
{
	return enabledMask;
}

- (BOOL) enabled:(short)chan	
{ 
	return enabledMask & (1<<chan); 
}

- (void) setEnabledMask:(long)aMask	
{ 
	[[[self undoManager] prepareWithInvocationTarget:self] setEnabledMask:enabledMask];
	enabledMask = aMask;
	[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelEnabledChanged object:self];
}

- (void) setEnabledBit:(short)chan withValue:(BOOL)aValue		
{ 
	unsigned char aMask = enabledMask;
	if(aValue)aMask |= (1<<chan);
	else aMask &= ~(1<<chan);
	[self setEnabledMask:aMask];
}

- (long) ltGtMask
{
	return ltGtMask;
}

- (BOOL) ltGt:(short)chan	
{ 
	return ltGtMask & (1<<chan); 
}

- (void) setLtGtMask:(long)aMask	
{ 
	[[[self undoManager] prepareWithInvocationTarget:self] setLtGtMask:ltGtMask];
	ltGtMask = aMask;
	[[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelLtGtChanged object:self];
}

- (void) setLtGtBit:(short)chan withValue:(BOOL)aValue		
{ 
	unsigned char aMask = ltGtMask;
	if(aValue)aMask |= (1<<chan);
	else aMask &= ~(1<<chan);
	[self setLtGtMask:aMask];
}


- (NSMutableArray*) thresholds
{
    return thresholds;
}

- (void) setThresholds:(NSMutableArray*)someThresholds
{
	
    [[[self undoManager] prepareWithInvocationTarget:self] setThresholds:[self thresholds]];
	
    [someThresholds retain];
    [thresholds release];
    thresholds = someThresholds;
	
    [[NSNotificationCenter defaultCenter]
	 postNotificationName:ORSIS3300ModelThresholdArrayChanged
	 object:self];
}

- (int) threshold:(short)aChan
{
    return [[thresholds objectAtIndex:aChan] shortValue];
}

- (void) setThreshold:(short)aChan withValue:(int)aValue 
{ 
	if(aValue<0)aValue = 0;
	if(aValue>0x3FFF)aValue = 0x3FFF;
    [[[self undoManager] prepareWithInvocationTarget:self] setThreshold:aChan withValue:[self threshold:aChan]];
    [thresholds replaceObjectAtIndex:aChan withObject:[NSNumber numberWithInt:aValue]];
	
    [[NSNotificationCenter defaultCenter]
	 postNotificationName:ORSIS3300ModelThresholdChanged
	 object:self];
}

#pragma mark •••Hardware Access
- (void) readModuleID
{	
	unsigned long result = 0;
	[[self adapter] readLongBlock:&result
                         atAddress:[self baseAddress] + kModuleIDReg
                        numToRead:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
	unsigned short moduleID = result >> 16;
	unsigned short majorRev = (result >> 8) & 0xff;
	unsigned short minorRev = result & 0xff;
	NSLog(@"SIS3300 ID: %x  Firmware:%x.%x\n",moduleID,majorRev,minorRev);
}

- (void) writeControlStatusRegister
{		
	//The register is set up as a J/K flip/flop -- 1 bit to set a function and 1 bit to disable.
	unsigned long aMask = 0xffff0000;
	
	[[self adapter] writeLongBlock:&aMask
                         atAddress:[self baseAddress] + kControlStatus
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
	
	aMask = 0x0;	

	if(enableTriggerOutput)		aMask |= kSISEnableTriggerOutput;
	if(invertTrigger)			aMask |= kSISInvertTrigger;
	if(activateTriggerOnArmed)	aMask |= kSISTriggerOnArmedAndStarted;
	if(enableInternalRouting)	aMask |= kSISInternalTriggerRouting;
	if(bankFullTo1)				aMask |= kSISBankFullTo1;
	if(bankFullTo2)				aMask |= kSISBankFullTo2;
	if(bankFullTo3)				aMask |= kSISBankFullTo3;
	
	
	//aMask = (((~aMask & ~kCSRReservedMask)<<16)&0xffff0000) | aMask ;
	[[self adapter] writeLongBlock:&aMask
                         atAddress:[self baseAddress] + kControlStatus
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) writeAcquistionRegister
{
	// The register is set up as a J/K flip/flop -- 1 bit to set a function and 1 bit to disable.	
	
	unsigned long aMask = 0xffff0000;
	
	[[self adapter] writeLongBlock:&aMask
                         atAddress:[self baseAddress] + kAcquisitionControlReg
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
	
	aMask = 0x0;
	if(bankSwitchMode)			aMask |= kSISBankSwitch;
	if(autoStart)				aMask |= kSISAutostart;
	if(multiEventMode)			aMask |= kSISMultiEvent;
	if(startDelayEnabled)		aMask |= kSISEnableStartDelay;			
	if(stopDelayEnabled)		aMask |= kSISEnableStopDelay;			
	if(lemoStartStop)			aMask |= kSISEnableLemoStartStop;			
	if(p2StartStop)				aMask |= kSISEnableP2StartStop;			
	if(gateMode)				aMask |= kSISEnableGateMode;
	if(randomClock)				aMask |= kSISEnableRandomClock;
	/*clock src bits*/			aMask |= ((clockSource & 0x7) << kSISClockSetShiftCount);
	if(multiplexerMode)			aMask |= kSISMultiplexerMode;
		
	//put the inverse in the top bits to turn off everything else
	//aMask = ((~aMask<<16)&0xffff0000) | aMask;
	
	[[self adapter] writeLongBlock:&aMask
                         atAddress:[self baseAddress] + kAcquisitionControlReg
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) writeEventConfigurationRegister
{
	 
	//enable/disable autostop at end of page
	//set pagesize
	unsigned long aMask = 0x0;
	aMask					  |= pageSize;
	if(pageWrap)		aMask |= kSISWrapMask;
	if(randomClock)		aMask |= kSISRandomClock;		//This must be set in both Acq Control and Event Config Registers
	if(multiplexerMode) aMask |= kSISMultiplexerMode2;  //This must be set in both Acq Control and Event Config Registers
	[[self adapter] writeLongBlock:&aMask
                         atAddress:[self baseAddress] + kEventConfigAll
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) writeStartDelay
{
	unsigned long aValue = stopDelay;
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kStartDelay
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) writeStopDelay
{
	unsigned long aValue = startDelay;
	
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kStopDelay
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) setLed:(BOOL)state
{
	unsigned long aValue = CSRMask(state,kSISLed);
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kControlStatus
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) enableUserOut:(BOOL)state
{
	unsigned long aValue = CSRMask(state,kSISUserOutput);
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kControlStatus
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) writeTriggerSetup
{
	int n = 0xffff/2;
	int m = 0xffff/2;
	int p = 0xffff/2;
	BOOL enabled = YES;
	unsigned long aValue = (enabled<<24) | (p < 16) | (n < 8) | m;
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kTriggerSetupReg
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) writeTriggerClearValue:(unsigned long)aValue
{

	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kTriggerFlagClrCounterReg
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) setMaxNumberEvents:(unsigned long)aValue
{
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kMaxNumberEventsReg
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}


- (void) startSampling
{
	unsigned long aValue = 0x0;
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kStartSampling
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) stopSampling
{
	unsigned long aValue = 0x0;
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kStopSampling
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) startBankSwitching
{
	unsigned long aValue = 0x0;
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kStartAutoBankSwitch
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) stopBankSwitching
{
	unsigned long aValue = 0x0;
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kStopAutoBankSwitch
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) clearBankFullFlag:(int)whichFlag
{
	unsigned long aValue = 0x0;
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + (whichFlag?kClearBank2FullFlag:kClearBank1FullFlag)
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (unsigned long) eventNumberGroup:(int)group bank:(int) bank
{
	//Note, here banks are 0,1,2,3 NOT 1,2,3,4
	unsigned long eventNumber = 0x0;   
	[[self adapter] readLongBlock:&eventNumber
						atAddress:[self baseAddress] + eventCountOffset[group][bank]
                        numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];
	
	
	return eventNumber;
}

- (unsigned long) eventTriggerGroup:(int)group bank:(int) bank
{
	//Note, here banks are 0,1,2,3 NOT 1,2,3,4
	unsigned long triggerWord = 0x0;   
	[[self adapter] readLongBlock:&triggerWord
						atAddress:[self baseAddress] + eventDirOffset[group][bank]
                        numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];
	
	
	return triggerWord;
}

- (int) adcValue:(int)chan index:(int)index
{
	return adcValue[chan][index];
}

- (void) readAdcValues:(int)i
{
	i = i%512;
	unsigned long aValue;   
	[[self adapter] readLongBlock:&aValue
						atAddress:[self baseAddress] + 0x200018
                        numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];
	
	adcValue[0][i] = (aValue&0x3fff0000) >> 16;
	adcValue[1][i] = aValue&0x00003fff;

	[[self adapter] readLongBlock:&aValue
						atAddress:[self baseAddress] + 0x280018
                        numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];
	adcValue[2][i] = (aValue&0x3fff0000) >> 16;
	adcValue[3][i] = aValue&0x00003fff;
	
	[[self adapter] readLongBlock:&aValue
						atAddress:[self baseAddress] + 0x300018
                        numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];
	adcValue[4][i] = (aValue&0x3fff0000) >> 16;
	adcValue[5][i] = aValue&0x00003fff;
	
	[[self adapter] readLongBlock:&aValue
						atAddress:[self baseAddress] + 0x380018
                        numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];
	adcValue[6][i] = (aValue&0x3fff0000) >> 16;
	adcValue[7][i] = aValue&0x00003fff;
	
}	

- (void) readAddressCounts
{
	unsigned long aValue = 0x0;   
	unsigned long aValue1 = 0x0;   
	[[self adapter] readLongBlock:&aValue
						atAddress:[self baseAddress] + 0x200008
                        numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];
	[[self adapter] readLongBlock:&aValue1
						atAddress:[self baseAddress] + 0x200010
                        numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];
	NSLog(@"Bank1 Address Counter 1:  0x%04x   0x%04x\n",aValue,aValue1);

	[[self adapter] readLongBlock:&aValue
						atAddress:[self baseAddress] + 0x280008
                        numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];
	[[self adapter] readLongBlock:&aValue1
						atAddress:[self baseAddress] + 0x280010
                        numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];
	NSLog(@"Bank1 Address Counter 2:  0x%04x   0x%04x\n",aValue,aValue1);
	
	[[self adapter] readLongBlock:&aValue
						atAddress:[self baseAddress] + 0x300008
                        numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];
	[[self adapter] readLongBlock:&aValue1
						atAddress:[self baseAddress] + 0x300010
                        numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];
	NSLog(@"Bank1 Address Counter 3:    0x%04x  0x%04x\n",aValue,aValue1);

	[[self adapter] readLongBlock:&aValue
						atAddress:[self baseAddress] + 0x380008
                        numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];
		  [[self adapter] readLongBlock:&aValue1
							  atAddress:[self baseAddress] + 0x380010
							  numToRead:1
							 withAddMod:[self addressModifier]
						  usingAddSpace:0x01];
	NSLog(@"Bank1 Address Counter 4:    0x%04x  0x%04x\n",aValue,aValue1);
	
}


- (unsigned long) acqReg
{
 	unsigned long aValue = 0;
	[[self adapter] readLongBlock:&aValue
						atAddress:[self baseAddress] + kAcquisitionControlReg
                        numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];
	return aValue;
}

- (unsigned long) configReg
{
 	unsigned long aValue = 0;
	[[self adapter] readLongBlock:&aValue
						atAddress:[self baseAddress] + kControlStatus
                        numToRead:1
					   withAddMod:[self addressModifier]
					usingAddSpace:0x01];
	return aValue;
}
- (void) disArm:(int)bank
{
 	unsigned long aValue = ACQMask(FALSE,bank?kSISSampleBank2:kSISSampleBank1);
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kAcquisitionControlReg
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (void) arm:(int)bank
{
 	unsigned long aValue = ACQMask(TRUE , bank?kSISSampleBank2:kSISSampleBank1);
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kAcquisitionControlReg
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}

- (BOOL) bankIsFull:(int)bank
{
	unsigned long aValue=0;
	[[self adapter] readLongBlock:&aValue
                         atAddress:[self baseAddress] + kAcquisitionControlReg
                        numToRead:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
	unsigned long mask = (bank?kSISBank2ClockStatus : kSISBank1ClockStatus);
	return !((aValue & mask) == mask);
}

- (void) writeThresholds:(BOOL)verbose
{   
	int tchan = 0;
	int i;
	if(verbose) NSLog(@"Writing Thresholds:\n");
	for(i = 0; i < 4; i++) {
		//the thresholds are packed even/odd into one long word with the Less/Greater Than bits
		//ADC 0,2,4,6
		unsigned long even_thresh = [self threshold:tchan];
		if(enabledMask & (0x1L<<i*2)){
			if([self ltGt:tchan]) even_thresh |= kSISTHRLt;
		}
		else {
			even_thresh = 0x3fff;
		}
		if(verbose) NSLog(@"%d: 0x%04x %@\n",tchan, even_thresh & ~kSISTHRLt, (even_thresh & kSISTHRLt)?@"(LE)":@"");
		tchan++;
		
		unsigned long odd_thresh = [self threshold:tchan];
		if(enabledMask & (0x2L<<i*2)){
			if([self ltGt:tchan]) odd_thresh |= kSISTHRLt;
		}
		else {
			odd_thresh = 0x3fff;
		}
		if(verbose) NSLog(@"%d: 0x%04x %@\n",tchan, odd_thresh & ~kSISTHRLt, (odd_thresh & kSISTHRLt)?@"(LE)":@"");
		tchan++;
		
		unsigned long aValue = (even_thresh << kSISTHRChannelShift) | odd_thresh;
		
		[[self adapter] writeLongBlock:&aValue
							 atAddress:[self baseAddress] + thresholdRegOffsets[i]
							numToWrite:1
							withAddMod:[self addressModifier]
						 usingAddSpace:0x01];
		
	}
}

- (void) readThresholds:(BOOL)verbose
{   
	int i;
	if(verbose) NSLog(@"Reading Thresholds:\n");
	for(i =0; i < 4; i++) {
		
		unsigned long aValue;
		[[self adapter] readLongBlock: &aValue
							atAddress: [self baseAddress] + thresholdRegOffsets[i]
							numToRead: 1
						   withAddMod: [self addressModifier]
						usingAddSpace: 0x01];
		
		if(verbose){
			unsigned short odd_thresh = (aValue&0xffff);
			unsigned short even_thresh  = (aValue>>16);
			NSLog(@"%d: 0x%04x %@\n",i*2,    even_thresh  & ~kSISTHRLt,  (even_thresh & kSISTHRLt)?@"(LE)":@"" );
			NSLog(@"%d: 0x%04x %@\n",(i*2)+1,odd_thresh & ~kSISTHRLt,    (odd_thresh  & kSISTHRLt)?@"(LE)":@"");
		}
	}
}

- (unsigned long) readTriggerEventBank:(int)bank index:(int)index
{   		
	unsigned long aValue;
	[[self adapter] readLongBlock: &aValue
						atAddress: [self baseAddress] + (bank?kTriggerEvent2DirOffset:kTriggerEvent1DirOffset) + index*4
						numToRead: 1
					   withAddMod: [self addressModifier]
					usingAddSpace: 0x01];
		
	return aValue;
}


- (BOOL) isBusy
{
	
	unsigned long aValue = 0;
	[[self adapter] readLongBlock: &aValue
						atAddress: [self baseAddress] + kAcquisitionControlReg
						numToRead: 1
					   withAddMod: [self addressModifier]
					usingAddSpace: 0x01];

	return (aValue & kSISBusyStatus) != 0;
}

- (void) initBoard
{  
	[self reset];							//reset the card
	[self writeAcquistionRegister];			//set up the Acquisition Register
	[self writeEventConfigurationRegister];	//set up the Event Config Register
	if(startDelayEnabled)[self writeStartDelay];
	if(stopDelayEnabled)[self writeStopDelay];
	[self writeThresholds:NO];
	[self writeControlStatusRegister];		//set up Control/Status Register
	//[self writeTriggerSetup];
	[self writeTriggerClearValue:[self sampleSize]];
	
}

- (void) testMemory
{
	long i;
	for(i=0;i<1024;i++){
		unsigned long aValue = i;
		[[self adapter] writeLongBlock: &aValue
							atAddress: [self baseAddress] + 0x00400000+i*4
							numToWrite: 1
						   withAddMod: [self addressModifier]
						usingAddSpace: 0x01];
	}
	long errorCount =0;
	for(i=0;i<8000;i++){
		unsigned long aValue;
		[[self adapter] readLongBlock: &aValue
							atAddress: [self baseAddress] + 0x00400000+i*4
							numToRead: 1
						   withAddMod: [self addressModifier]
						usingAddSpace: 0x01];
		if(aValue!=i)errorCount++;
	}
	if(errorCount)NSLog(@"Error R/W Bank memory: %d errors\n",errorCount);
	else NSLog(@"Memory Bank Test Passed\n");
}

- (void) testEventRead
{
	[self reset];
	[self initBoard];
	[self clearBankFullFlag:0];
	NSLog(@"After Init Bank Full: %d\n",[self bankIsFull:0]);
	[self arm:0];
	NSLog(@"After Arm Bank Full: %d\n",[self bankIsFull:0]);
	[self startSampling];
	NSLog(@"Sampling started Bank Full: %d\n",[self bankIsFull:0]);
	int totalTime = 0;
	BOOL timeout = NO;
	while(![self bankIsFull:0]){
		[ORTimer delay:.1];
		if(totalTime++ >= 10){
			timeout = YES;
			break;
		}
	}
	if(!timeout){
		int numEvents= [self eventNumberGroup:0 bank:0];
		NSLog(@"got %d event\n",numEvents);
		int event;
		for(event=0;event<numEvents;event++){
			unsigned long triggerEventDir = [self readTriggerEventBank:currentBank index:event];
			NSLog(@"trigger Event:%d 0x%08x\n",event,triggerEventDir);
			}
		}
}

- (void) sampleAdcValues
{
	int i;
	for(i=0;i<512;i++){
		[self readAdcValues:i];
	}
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSIS3300ModelSampleDone object:self];
}

- (unsigned long) readGroup:(int)aGroup intoBuffer:(void*)aBuffer
{
	//NSLog(@"%d event Count: %d\n",aGroup,[self eventNumber:aGroup]);

	switch (aGroup) {
		case 0: return [self readEventDirectory:0x200000 bankAddressOffest:0x400000 intoBuffer:aBuffer];
		case 1: return [self readEventDirectory:0x280000 bankAddressOffest:0x480000 intoBuffer:aBuffer];
		case 2: return [self readEventDirectory:0x300000 bankAddressOffest:0x500000 intoBuffer:aBuffer];
		case 3: return [self readEventDirectory:0x380000 bankAddressOffest:0x580000 intoBuffer:aBuffer];
		default: return 0;
	}
}

- (unsigned int) readEventDirectory: (unsigned long) eventDirAddressOffset 
				  bankAddressOffest: (unsigned long) bankAddressOffest
						 intoBuffer: (void*) pBuffer
{
	/*
	 --------------------------------------------------------------
	 Function to read a full event. This breaks into these cases:
	 --pageWrap false. 
	 In this case, the event directory entry determines the end of the event 
	 as well as the number of samples. 
	 Note that we assume that the wrap bit in the event directory allows us 
	 to differentiate between 0 samples and 128Ksamples.
	 
	 --pageWrap true, but the event directory wrap bit is false. 
	 Again, the number of samples is determined by the address pointer.
	 
	 --pageWrap true and event directory wrap bit is true. 
	 In this case, a full m_nPagesize samples have been taken and the address pointer 
	 indicates the start of event. The data procede circularly in the first m_nPagesize 
	 words of the buffer memory since we don't support multi-event mode yet.
	 --------------------------------------------------------------
	 */
	unsigned long nPagesize = [self sampleSize]; // Max conversion count.
	
	// Decode the event directory entry:
	
	unsigned long  eventRegValue = [self readTriggerEventBank:0 index:0];	//------read from bank 0 only for now.....
	int adcMask= (eventRegValue&0xff000000) >> 24;
	
	bool           fWrapped      = (eventRegValue & kSISEventDirWrapFlag ) != 0;
	unsigned long  nEventEnd     = (eventRegValue & kSISEventDirEndEventMask);
	nEventEnd                   &= ([self sampleSize]-1); // limit the pointer to pagesize
	NSLog(@"-----------------acd mask: 0x%02x\n",adcMask);
	NSLog(@"pageSize: 0x%x\n",[self sampleSize]);
	NSLog(@"wrapped:  %d\n",fWrapped);
	NSLog(@"eventEnd:  0x%x\n",nEventEnd);
	unsigned long  nLongs = 0;
	unsigned long* Samples = ((unsigned long*)pBuffer);
	
	// The three cases above break into two cases: fWrapped true or not.
	
	if(fWrapped) {
		//  Full set of samples... 
		
		nLongs = [self sampleSize];
		
		// Breaks down into two reads:
		
		// The first read is from nEventEnd -> nPagesize.
		
		int nReadSize = (nPagesize - nEventEnd); //bytes?
		if(nReadSize > 0) {
			[[self adapter] readLongBlock: Samples
								atAddress: [self baseAddress] + bankAddressOffest + nEventEnd
								numToRead: nReadSize/sizeof(long)
							   withAddMod: [self addressModifier]
							usingAddSpace: 0x01];
		}
		
		// The second read, if necessary, is from 0 ->nEventEnd-1.
		
		unsigned long nOffset =  nReadSize; // Offset into Samples where data goes.
		nReadSize = nPagesize - nReadSize;  // Size of remaining read.
		if(nReadSize > 0) {
			[[self adapter] readLongBlock: &Samples[nOffset]
								atAddress: [self baseAddress] + bankAddressOffest
								numToRead: nReadSize/sizeof(long)
							   withAddMod: [self addressModifier]
							usingAddSpace: 0x01];			
		}
		nLongs = nPagesize;
	}
	else {                        
		// Only 0 - nEventEnd to read...
		if(nEventEnd > 0) {
			[[self adapter] readLongBlock: Samples
								atAddress: [self baseAddress] + bankAddressOffest
								numToRead: nEventEnd
							   withAddMod: [self addressModifier]
							usingAddSpace: 0x01];
			
			nLongs = nEventEnd;
		} 
		else {                      // nothing to read...
			nLongs = 0;
		}
	}
	
	return nLongs;
	
}

#pragma mark •••Data Taker
- (unsigned long) dataId { return dataId; }
- (void) setDataId: (unsigned long) DataId
{
    dataId = DataId;
}
- (void) setDataIds:(id)assigner
{
    dataId       = [assigner assignDataIds:kLongForm]; //short form preferred
}

- (void) syncDataIdsWith:(id)anotherCard
{
    [self setDataId:[anotherCard dataId]];
}

- (NSDictionary*) dataRecordDescription
{
    NSMutableDictionary* dataDictionary = [NSMutableDictionary dictionary];
    NSDictionary* aDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"ORSIS3300WaveformDecoder",            @"decoder",
								 [NSNumber numberWithLong:dataId],       @"dataId",
								 [NSNumber numberWithBool:YES],          @"variable",
								 [NSNumber numberWithLong:-1],			 @"length",
								 nil];
    [dataDictionary setObject:aDictionary forKey:@"SIS3300"];
    
    return dataDictionary;
}

#pragma mark •••HW Wizard
-(BOOL) hasParmetersToRamp
{
	return YES;
}
- (int) numberOfChannels
{
    return kNumSIS3300Channels;
}

- (NSArray*) wizardParameters
{
    NSMutableArray* a = [NSMutableArray array];
    ORHWWizParam* p;
    
    p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Page Size"];
    [p setFormat:@"##0" upperLimit:7 lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setPageSize:) getMethod:@selector(pageSize)];
    [p setActionMask:kAction_Set_Mask];
    [a addObject:p];
	
    p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Start Delay"];
    [p setFormat:@"##0" upperLimit:0xffff lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setStartDelay:) getMethod:@selector(startDelay)];
    [p setActionMask:kAction_Set_Mask];
    [a addObject:p];
	
    p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Stop Delay"];
    [p setFormat:@"##0" upperLimit:0xffff lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setStopDelay:) getMethod:@selector(stopDelay)];
    [p setActionMask:kAction_Set_Mask];
    [a addObject:p];
	
    p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Clock Source"];
    [p setFormat:@"##0" upperLimit:7 lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setClockSource:) getMethod:@selector(clockSource)];
    [p setActionMask:kAction_Set_Mask];
    [a addObject:p];
	
    [a addObject:[ORHWWizParam boolParamWithName:@"PageWrap" setter:@selector(setPageWrap:) getter:@selector(pageWrap)]];
    [a addObject:[ORHWWizParam boolParamWithName:@"StopTrigger" setter:@selector(setStopTrigger:) getter:@selector(stopTrigger)]];
    [a addObject:[ORHWWizParam boolParamWithName:@"P2StartStop" setter:@selector(setP2StartStop:) getter:@selector(p2StartStop)]];
    [a addObject:[ORHWWizParam boolParamWithName:@"LemoStartStop" setter:@selector(setLemoStartStop:) getter:@selector(lemoStartStop)]];
    [a addObject:[ORHWWizParam boolParamWithName:@"RandomClock" setter:@selector(setRandomClock:) getter:@selector(randomClock)]];
    [a addObject:[ORHWWizParam boolParamWithName:@"GateMode" setter:@selector(setGateMode:) getter:@selector(gateMode)]];
    [a addObject:[ORHWWizParam boolParamWithName:@"StartDelayEnabled" setter:@selector(setStartDelayEnabled:) getter:@selector(startDelayEnabled)]];
    [a addObject:[ORHWWizParam boolParamWithName:@"StopDelayEnabled" setter:@selector(setStopDelayEnabled:) getter:@selector(stopDelayEnabled)]];
    [a addObject:[ORHWWizParam boolParamWithName:@"MultiEvent" setter:@selector(setMultiEventMode:) getter:@selector(multiEventMode)]];
    [a addObject:[ORHWWizParam boolParamWithName:@"AutoStart" setter:@selector(setAutoStart:) getter:@selector(autoStart)]];
	
    p = [[[ORHWWizParam alloc] init] autorelease];
    [p setName:@"Threshold"];
    [p setFormat:@"##0" upperLimit:0x7fff lowerLimit:0 stepSize:1 units:@""];
    [p setSetMethod:@selector(setThreshold:withValue:) getMethod:@selector(threshold:)];
	[p setCanBeRamped:YES];
    [a addObject:p];
    
    p = [[[ORHWWizParam alloc] init] autorelease];
    [p setUseValue:NO];
    [p setName:@"Init"];
    [p setSetMethodSelector:@selector(initBoard)];
    [a addObject:p];
    
    return a;
}


- (NSArray*) wizardSelections
{
    NSMutableArray* a = [NSMutableArray array];
    [a addObject:[ORHWWizSelection itemAtLevel:kContainerLevel name:@"Crate" className:@"ORVmeCrateModel"]];
    [a addObject:[ORHWWizSelection itemAtLevel:kObjectLevel name:@"Card" className:@"ORSIS3300Model"]];
    [a addObject:[ORHWWizSelection itemAtLevel:kChannelLevel name:@"Channel" className:@"ORSIS3300Model"]];
    return a;
}

- (NSNumber*) extractParam:(NSString*)param from:(NSDictionary*)fileHeader forChannel:(int)aChannel
{
	NSDictionary* cardDictionary = [self findCardDictionaryInHeader:fileHeader];
	if([param isEqualToString:@"Threshold"])return [[cardDictionary objectForKey:@"thresholds"] objectAtIndex:aChannel];
    else if([param isEqualToString:@"Enabled"]) return [cardDictionary objectForKey:@"enabledMask"];
    else if([param isEqualToString:@"Page Size"]) return [cardDictionary objectForKey:@"pageSize"];
    else if([param isEqualToString:@"Start Delay"]) return [cardDictionary objectForKey:@"startDelay"];
    else if([param isEqualToString:@"Stop Delay"]) return [cardDictionary objectForKey:@"stopDelay"];
    else if([param isEqualToString:@"Clock Source"]) return [cardDictionary objectForKey:@"clockSource"];
    else if([param isEqualToString:@"PageWrap"]) return [cardDictionary objectForKey:@"pageWrap"];
    else if([param isEqualToString:@"StopTrigger"]) return [cardDictionary objectForKey:@"stopTrigger"];
    else if([param isEqualToString:@"P2StartStop"]) return [cardDictionary objectForKey:@"p2StartStop"];
    else if([param isEqualToString:@"LemoStartStop"]) return [cardDictionary objectForKey:@"lemoStartStop"];
    else if([param isEqualToString:@"RandomClock"]) return [cardDictionary objectForKey:@"randomClock"];
    else if([param isEqualToString:@"GateMode"]) return [cardDictionary objectForKey:@"gateMode"];
    else if([param isEqualToString:@"MultiEvent"]) return [cardDictionary objectForKey:@"multiEventMode"];
    else if([param isEqualToString:@"StartDelayEnabled"]) return [cardDictionary objectForKey:@"sartDelayEnabled"];
    else if([param isEqualToString:@"StopDelayEnabled"]) return [cardDictionary objectForKey:@"stopDelayEnabled"];
    else return nil;
}

- (void) runTaskStarted:(ORDataPacket*)aDataPacket userInfo:(id)userInfo
{
    if(![[self adapter] controllerCard]){
        [NSException raise:@"Not Connected" format:@"You must connect to a PCI Controller (i.e. a 617)."];
    }
    
    //----------------------------------------------------------------------------------------
    // first add our description to the data description
    
    [aDataPacket addDataDescriptionItem:[self dataRecordDescription] forKey:@"ORSIS3300Model"];    
    
    //cache some stuff
    location        = (([self crateNumber]&0x0000000f)<<21) | (([self slot]& 0x0000001f)<<16);
    theController   = [self adapter];
    
   // [self startRates];
	
    [self initBoard];
			
    if(!dataBuffer) dataBuffer = (unsigned long*)malloc(0x80000);
	if(bankSwitchMode)	[self startBankSwitching];
	else				[self stopBankSwitching];
	if(multiEventMode)[self setMaxNumberEvents:0x80000/[self sampleSize]]; 
	else [self setMaxNumberEvents:1]; 
	
	currentBank = 0;
	[self clearBankFullFlag:currentBank];
	[self arm:currentBank];
	[self startSampling];
	
	isRunning = true;
}

//**************************************************************************************
// Function:	TakeData
// Description: Read data from a card
//**************************************************************************************
-(void) takeData:(ORDataPacket*)aDataPacket userInfo:(id)userInfo
{
    @try {
		if(![self bankIsFull:currentBank]){
			//get the number of events
			int numEvents = [self eventNumberGroup:0 bank:currentBank];
			int event,group;
			for(event=0;event<numEvents;event++){
				unsigned long triggerEventDir = [self readTriggerEventBank:currentBank index:event];
				unsigned long startOffset = triggerEventDir&0x1fff;
			
				for(group=0;group<4;group++){
					unsigned long channelMask = triggerEventDir & (0xC0000000 >> (group*2));
					BOOL wrapped = ((triggerEventDir&0x80000) == 0x80000);
					//only read the channel that have trigger info
					if(channelMask==0)continue;
					unsigned long numLongs = 0;
					dataBuffer[numLongs++] = dataId | 0; //we'll fill in the length later
					dataBuffer[numLongs++] = location;
					dataBuffer[numLongs++] = triggerEventDir;
					
					int nBytesToRead;
					if(wrapped) {
						// Breaks down into two reads:
						// The first read is from startOffset -> nPagesize.
						nBytesToRead = ([self sampleSize] - startOffset);
						if(nBytesToRead > 0) {
							[[self adapter] readLongBlock: dataBuffer
												atAddress: [self baseAddress] + bankMemory[group][currentBank] + startOffset
												numToRead: nBytesToRead/sizeof(long)
											   withAddMod: [self addressModifier]
											usingAddSpace: 0x01];
						}
						
						// The second read, if necessary, is from 0 ->nEventEnd-1.
						
						unsigned long nOffset =  nBytesToRead; // Offset into Samples where data goes.
						nBytesToRead = startOffset;  // Size of remaining read.
						if(nBytesToRead > 0) {
							[[self adapter] readLongBlock: &dataBuffer[nOffset]
												atAddress: [self baseAddress] + bankMemory[group][currentBank]
												numToRead: nBytesToRead/sizeof(long)
											   withAddMod: [self addressModifier]
											usingAddSpace: 0x01];			
						}
					}
					else {                        
						// Only 0 - nEventEnd to read...
						[[self adapter] readLongBlock: dataBuffer
											atAddress: [self baseAddress] + bankMemory[group][currentBank] + startOffset
											numToRead: [self sampleSize]/sizeof(long)
										   withAddMod: [self addressModifier]
										usingAddSpace: 0x01];
					}
					
					long totalNumLongs = numLongs + [self sampleSize]/sizeof(long);
					dataBuffer[0] |= totalNumLongs; //see, we did fill it in...
					[aDataPacket addLongsToFrameBuffer:dataBuffer length:totalNumLongs];
					
				}
			}
			if(bankSwitchMode) currentBank= (currentBank+1)%2;
			[self clearBankFullFlag:currentBank];
			[self arm:currentBank];
			[self startSampling];
			
		}
	}
	@catch(NSException* localException) {
		[self incExceptionCount];
		[localException raise];
	}
}

- (void) runTaskStopped:(ORDataPacket*)aDataPacket userInfo:(id)userInfo
{
	[self stopBankSwitching];
    isRunning = NO;
    [waveFormRateGroup stop];
}

//this is the data structure for the new SBCs (i.e. VX704 from Concurrent)
- (int) load_HW_Config_Structure:(SBC_crate_config*)configStruct index:(int)index
{
	
    /* The current hardware specific data is:               *
     *                                                      *
     * 0: FIFO state address                                *
     * 1: FIFO empty state mask                             *
     * 2: FIFO address                                      *
     * 3: FIFO address AM                                   *
     * 4: FIFO size                                         */
    
	configStruct->total_cards++;
	configStruct->card_info[index].hw_type_id				= kSIS3300; //should be unique
	configStruct->card_info[index].hw_mask[0]				= dataId; //better be unique
	configStruct->card_info[index].slot						= [self slot];
	configStruct->card_info[index].crate					= [self crateNumber];
	configStruct->card_info[index].add_mod					= [self addressModifier];
	configStruct->card_info[index].base_add					= [self baseAddress];
    configStruct->card_info[index].deviceSpecificData[1]	= 0;
    configStruct->card_info[index].deviceSpecificData[2]	= [self baseAddress] * 0x100;
    configStruct->card_info[index].deviceSpecificData[3]	= 0x09;
    configStruct->card_info[index].deviceSpecificData[4]	= 0x4000;
	configStruct->card_info[index].num_Trigger_Indexes		= 0;
	
	configStruct->card_info[index].next_Card_Index 	= index+1;	
	
	return index+1;
}

- (void) reset
{
 	unsigned long aValue = 0; //value doesn't matter 
	[[self adapter] writeLongBlock:&aValue
                         atAddress:[self baseAddress] + kGeneralReset
                        numToWrite:1
                        withAddMod:[self addressModifier]
                     usingAddSpace:0x01];
}


- (BOOL) bumpRateFromDecodeStage:(short)channel
{
    if(isRunning)return NO;
    
    ++waveFormCount[channel];
    return YES;
}

- (unsigned long) waveFormCount:(int)aChannel
{
    return waveFormCount[aChannel];
}

-(void) startRates
{
    [self clearWaveFormCounts];
    [waveFormRateGroup start:self];
}

- (void) clearWaveFormCounts
{
    int i;
    for(i=0;i<kNumSIS3300Channels;i++){
        waveFormCount[i]=0;
    }
}

#pragma mark •••Archival
- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super initWithCoder:decoder];
    
    [[self undoManager] disableUndoRegistration];
    
	//csr
	[self setBankFullTo3:			[decoder decodeBoolForKey:@"bankFullTo3"]];
    [self setBankFullTo2:			[decoder decodeBoolForKey:@"bankFullTo2"]];
    [self setBankFullTo1:			[decoder decodeBoolForKey:@"bankFullTo1"]];
	[self setEnableInternalRouting:	[decoder decodeBoolForKey:@"enableInternalRouting"]];
    [self setActivateTriggerOnArmed:[decoder decodeBoolForKey:@"activateTriggerOnArmed"]];
    [self setInvertTrigger:			[decoder decodeBoolForKey:@"invertTrigger"]];
    [self setEnableTriggerOutput:	[decoder decodeBoolForKey:@"enableTriggerOutput"]];
	
	//acq
    [self setBankSwitchMode:		[decoder decodeBoolForKey:@"bankSwitchMode"]];
    [self setAutoStart:				[decoder decodeBoolForKey:@"autoStart"]];
    [self setMultiEventMode:		[decoder decodeBoolForKey:@"multiEventMode"]];
    [self setMultiplexerMode:		[decoder decodeBoolForKey:@"multiplexerMode"]];
    [self setLemoStartStop:			[decoder decodeBoolForKey:@"lemoStartStop"]];
    [self setP2StartStop:			[decoder decodeBoolForKey:@"p2StartStop"]];
    [self setGateMode:				[decoder decodeBoolForKey:@"gateMode"]];
	
	//clocks
    [self setRandomClock:			[decoder decodeBoolForKey:@"randomClock"]];
    [self setStartDelayEnabled:		[decoder decodeBoolForKey:@"startDelayEnabled"]];
    [self setStopDelayEnabled:		[decoder decodeBoolForKey:@"stopDelayEnabled"]];
    [self setStopDelay:				[decoder decodeIntForKey:@"stopDelay"]];
    [self setStartDelay:			[decoder decodeIntForKey:@"startDelay"]];
    [self setClockSource:			[decoder decodeIntForKey:@"clockSource"]];
    [self setStopDelay:				[decoder decodeIntForKey:@"stopDelay"]];
	
    [self setPageWrap:				[decoder decodeBoolForKey:@"pageWrap"]];
    [self setStopTrigger:			[decoder decodeBoolForKey:@"stopTrigger"]];
    [self setPageSize:				[decoder decodeIntForKey:@"pageSize"]];
    [self setEnabledMask:			[decoder decodeInt32ForKey:@"enabledMask"]];
	[self setThresholds:			[decoder decodeObjectForKey:@"thresholds"]];
	[self setLtGtMask:				[decoder decodeIntForKey:@"ltGtMask"]];
		
    [self setWaveFormRateGroup:[decoder decodeObjectForKey:@"waveFormRateGroup"]];
    
    if(!waveFormRateGroup){
        [self setWaveFormRateGroup:[[[ORRateGroup alloc] initGroup:kNumSIS3300Channels groupTag:0] autorelease]];
        [waveFormRateGroup setIntegrationTime:5];
    }
    [waveFormRateGroup resetRates];
    [waveFormRateGroup calcRates];
	
    [[self undoManager] enableUndoRegistration];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
	//csr
    [encoder encodeBool:bankFullTo3				forKey:@"bankFullTo3"];
    [encoder encodeBool:bankFullTo2				forKey:@"bankFullTo2"];
    [encoder encodeBool:bankFullTo1				forKey:@"bankFullTo1"];
    [encoder encodeBool:enableInternalRouting	forKey:@"enableInternalRouting"];
    [encoder encodeBool:activateTriggerOnArmed	forKey:@"activateTriggerOnArmed"];
    [encoder encodeBool:invertTrigger			forKey:@"invertTrigger"];
    [encoder encodeBool:enableTriggerOutput		forKey:@"enableTriggerOutput"];

	//acq
    [encoder encodeBool:bankSwitchMode			forKey:@"bankSwitchMode"];
    [encoder encodeBool:autoStart				forKey:@"autoStart"];
    [encoder encodeBool:multiEventMode			forKey:@"multiEventMode"];
	[encoder encodeBool:multiplexerMode			forKey:@"multiplexerMode"];
    [encoder encodeBool:lemoStartStop			forKey:@"lemoStartStop"];
    [encoder encodeBool:p2StartStop				forKey:@"p2StartStop"];
    [encoder encodeBool:gateMode				forKey:@"gateMode"];
	
 	//clocks
    [encoder encodeBool:randomClock				forKey:@"randomClock"];
    [encoder encodeBool:startDelayEnabled		forKey:@"startDelayEnabled"];
    [encoder encodeBool:stopDelayEnabled		forKey:@"stopDelayEnabled"];
    [encoder encodeInt:stopDelay				forKey:@"stopDelay"];
    [encoder encodeInt:startDelay				forKey:@"startDelay"];
    [encoder encodeInt:clockSource				forKey:@"clockSource"];
	
    [encoder encodeBool:pageWrap				forKey:@"pageWrap"];
    [encoder encodeBool:stopTrigger				forKey:@"stopTrigger"];

    [encoder encodeInt:pageSize					forKey:@"pageSize"];
    [encoder encodeInt32:enabledMask			forKey:@"enabledMask"];
    [encoder encodeObject:thresholds			forKey:@"thresholds"];
    [encoder encodeInt:ltGtMask					forKey:@"ltGtMask"];
	
    [encoder encodeObject:waveFormRateGroup forKey:@"waveFormRateGroup"];
	
}

- (NSMutableDictionary*) addParametersToDictionary:(NSMutableDictionary*)dictionary
{
    NSMutableDictionary* objDictionary = [super addParametersToDictionary:dictionary];
	//csr
	[objDictionary setObject: [NSNumber numberWithBool:bankFullTo3]			  forKey:@"bankFullTo3"];
	[objDictionary setObject: [NSNumber numberWithBool:bankFullTo2]			  forKey:@"bankFullTo2"];
	[objDictionary setObject: [NSNumber numberWithBool:bankFullTo1]			  forKey:@"bankFullTo1"];
	[objDictionary setObject: [NSNumber numberWithBool:enableInternalRouting] forKey:@"enableInternalRouting"];
	[objDictionary setObject: [NSNumber numberWithBool:activateTriggerOnArmed] forKey:@"activateTriggerOnArmed"];
	[objDictionary setObject: [NSNumber numberWithBool:invertTrigger]		forKey:@"invertTrigger"];
	[objDictionary setObject: [NSNumber numberWithBool:enableTriggerOutput] forKey:@"enableTriggerOutput"];
	
	//acq
	[objDictionary setObject: [NSNumber numberWithBool:bankSwitchMode]		forKey:@"bankSwitchMode"];
	[objDictionary setObject: [NSNumber numberWithBool:autoStart]			forKey:@"autoStart"];
	[objDictionary setObject: [NSNumber numberWithBool:multiEventMode]		forKey:@"multiEventMode"];
	[objDictionary setObject: [NSNumber numberWithBool:multiplexerMode]		forKey:@"multiplexerMode"];
	[objDictionary setObject: [NSNumber numberWithBool:lemoStartStop]		forKey:@"lemoStartStop"];
	[objDictionary setObject: [NSNumber numberWithBool:p2StartStop]			forKey:@"p2StartStop"];
	[objDictionary setObject: [NSNumber numberWithBool:gateMode]			forKey:@"gateMode"];

 	//clocks
	[objDictionary setObject: [NSNumber numberWithBool:randomClock]			forKey:@"randomClock"];
	[objDictionary setObject: [NSNumber numberWithInt:clockSource]			forKey:@"clockSource"];
	[objDictionary setObject: [NSNumber numberWithInt:stopDelay]			forKey:@"stopDelay"];
	[objDictionary setObject: [NSNumber numberWithInt:startDelay]			forKey:@"startDelay"];
	[objDictionary setObject: [NSNumber numberWithBool:startDelayEnabled]	forKey:@"startDelayEnabled"];
	[objDictionary setObject: [NSNumber numberWithBool:stopDelayEnabled]	forKey:@"stopDelayEnabled"];

	[objDictionary setObject: [NSNumber numberWithInt:pageSize]				forKey:@"pageSize"];
	[objDictionary setObject: [NSNumber numberWithBool:pageWrap]			forKey:@"pageWrap"];
	[objDictionary setObject: [NSNumber numberWithBool:stopTrigger]			forKey:@"stopTrigger"];
	[objDictionary setObject: [NSNumber numberWithLong:enabledMask]			forKey:@"enabledMask"];
    [objDictionary setObject:thresholds										forKey:@"thresholds"];	
    [objDictionary setObject: [NSNumber numberWithLong:ltGtMask]			forKey:@"ltGtMask"];	
	
    return objDictionary;
}

@end
