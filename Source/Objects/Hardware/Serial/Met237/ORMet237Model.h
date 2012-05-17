//--------------------------------------------------------
// ORMet237Model
// Created by Mark  A. Howe on Fri Jul 22 2005
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
#import "ORAdcProcessing.h"

@class ORSerialPort;
@class ORTimeRate;
@class ORSafeQueue;

#define kMet237Counting  0
#define kMet237Holding   1
#define kMet237Stopped   2

@interface ORMet237Model : OrcaObject <ORAdcProcessing>
{
    @private
        NSString*       portName;
        BOOL            portWasOpen;
        ORSerialPort*   serialPort;
		NSString*		lastRequest;
		ORSafeQueue*    cmdQueue;
		unsigned long	timeMeasured;
        NSMutableString* buffer;
		NSString* measurementDate;
		float size1;
		float size2;
		int count1;
		int count2;
		int countingMode;
		int cycleDuration;
		BOOL running;
		NSDate* cycleStarted;
		NSDate* cycleWillEnd;
		int cycleNumber;
		BOOL recordComingIn;
		BOOL statusComingIn;
		ORTimeRate*			timeRates[2];
		BOOL	wasRunning;
		float maxCounts;
		float countAlarmLimit;
        BOOL dataValid;
}

#pragma mark ***Initialization
- (id)   init;
- (void) dealloc;
- (void) registerNotificationObservers;
- (void) dataReceived:(NSNotification*)note;
- (BOOL) dataForChannelValid:(int)aChannel;

#pragma mark ***Accessors
- (float) countAlarmLimit;
- (void) setCountAlarmLimit:(float)aCountAlarmLimit;
- (float) maxCounts;
- (void) setMaxCounts:(float)aMaxCounts;
- (ORTimeRate*)timeRate:(int)index;
- (int) cycleNumber;
- (void) setCycleNumber:(int)aCycleNumber;
- (NSDate*) cycleWillEnd;
- (void) setCycleWillEnd:(NSDate*)aCycleWillEnd;
- (NSDate*) cycleStarted;
- (void) setCycleStarted:(NSDate*)aCycleStarted;
- (BOOL) running;
- (void) setRunning:(BOOL)aRunning;
- (int) cycleDuration;
- (void) setCycleDuration:(int)aCycleDuration;
- (int) countingMode;
- (void) setCountingMode:(int)aCountingMode;
- (int) count2;
- (void) setCount2:(int)aCount2;
- (int) count1;
- (void) setCount1:(int)aCount1;
- (float) size2;
- (void) setSize2:(float)aSize2;
- (float) size1;
- (void) setSize1:(float)aSize1;
- (NSString*) measurementDate;
- (void) setMeasurementDate:(NSString*)aMeasurementDate;
- (ORSerialPort*) serialPort;
- (void) setSerialPort:(ORSerialPort*)aSerialPort;
- (BOOL) portWasOpen;
- (void) setPortWasOpen:(BOOL)aPortWasOpen;
- (NSString*) portName;
- (void) setPortName:(NSString*)aPortName;
- (NSString*) lastRequest;
- (void) setLastRequest:(NSString*)aRequest;
- (void) openPort:(BOOL)state;
- (unsigned long) timeMeasured;
- (NSString*) countingModeString;

#pragma mark ***Polling
- (void) startCycle;
- (void) stopCycle;

#pragma mark ***Commands
- (void) addCmdToQueue:(NSString*)aCmd;
- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;
- (void) initHardware;
- (void) sendAuto;				
- (void) sendManual;					
- (void) startCountingByComputer;	
- (void) startCountingByCounter;	
- (void) stopCounting;	
- (void) clearBuffer;				
- (void) getNumberRecords;			
- (void) getRevision;				
- (void) getMode;					
- (void) getModel;					
- (void) getRecord;					
- (void) resendRecord;				
- (void) goToStandbyMode;			
- (void) getToActiveMode;			
- (void) goToLocalMode;				
- (void) universalSelect;

#pragma mark •••Adc Processing Protocol
- (void)processIsStarting;
- (void)processIsStopping;
- (void) startProcessCycle;
- (void) endProcessCycle;
- (BOOL) processValue:(int)channel;
- (void) setProcessOutput:(int)channel value:(int)value;
- (NSString*) processingTitle;
- (void) getAlarmRangeLow:(double*)theLowLimit high:(double*)theHighLimit  channel:(int)channel;
- (double) convertedValue:(int)channel;
- (double) maxValueForChan:(int)channel;

@end

extern NSString* ORMet237ModelCountAlarmLimitChanged;
extern NSString* ORMet237ModelMaxCountsChanged;
extern NSString* ORMet237ModelCycleNumberChanged;
extern NSString* ORMet237ModelCycleWillEndChanged;
extern NSString* ORMet237ModelCycleStartedChanged;
extern NSString* ORMet237ModelRunningChanged;
extern NSString* ORMet237ModelCycleDurationChanged;
extern NSString* ORMet237ModelCountingModeChanged;
extern NSString* ORMet237ModelCount2Changed;
extern NSString* ORMet237ModelCount1Changed;
extern NSString* ORMet237ModelSize2Changed;
extern NSString* ORMet237ModelSize1Changed;
extern NSString* ORMet237ModelMeasurementDateChanged;
extern NSString* ORMet237ModelPollTimeChanged;
extern NSString* ORMet237ModelSerialPortChanged;
extern NSString* ORMet237Lock;
extern NSString* ORMet237ModelPortNameChanged;
extern NSString* ORMet237ModelPortStateChanged;

