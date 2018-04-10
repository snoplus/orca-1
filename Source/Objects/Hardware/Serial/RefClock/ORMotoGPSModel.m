//--------------------------------------------------------
// ORMotoGPSModel
// Created by Mark  A. Howe on Fri Jul 22 2005 / Julius Hartmann, KIT, November 2017
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

#import "ORMotoGPSModel.h"
#import "ORRefClockModel.h"

#pragma mark ***External Strings
NSString* ORMotoGPSModelSetDefaultsChanged      = @"ORMotoGPSModelSetDefaultsChanged";
NSString* ORMotoGPSModelTrackModeChanged	    = @"ORMotoGPSModelTrackModeChanged";
NSString* ORMotoGPSModelSyncChanged	            = @"ORMotoGPSModelSyncChanged";
NSString* ORMotoGPSModelAlarmWindowChanged	    = @"ORMotoGPSModelAlarmWindowChanged";
NSString* ORMotoGPSModelStatusChanged           = @"ORMotoGPSModelStatusChanged";
NSString* ORMotoGPSModelStatusPollChanged       = @"ORMotoGPSModelStatusPollChanged";
NSString* ORMotoGPSModelReceivedMessageChanged  = @"ORMotoGPSModelReceivedMessageChanged";
NSString* ORMotoGPSStatusValuesReceived =
    @"ORMotoGPSStatusValuesReceived";

extern NSString* ORMotoGPS;

//#define maxReTx 3  // above this number, stop trying to
// retransmit and place an Error.

@interface ORMotoGPSModel (private)
- (void) updatePoll;
@end

@implementation ORMotoGPSModel

- (void) dealloc
{
    //[lastRecTelegram dealloc];
    [super dealloc];
}

- (void) setRefClock:(ORRefClockModel*)aRefClock
{
    refClock  = aRefClock; //this is a delegate... don't retain or release
}


#pragma mark ***Accessors

- (BOOL) statusPoll
{
    return statusPoll;
}

- (void) setStatusPoll:(BOOL)aStatusPoll
{
    statusPoll = aStatusPoll;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORMotoGPSModelStatusPollChanged object:self];
    [self updatePoll];
}

//put our parameters into any run header
// todo -- this will not be called automatically. It has to be called from refClock if needed.
- (NSMutableDictionary*) addParametersToDictionary:(NSMutableDictionary*)dictionary
{
    NSMutableDictionary* objDictionary = [NSMutableDictionary dictionary];
    [objDictionary setObject:NSStringFromClass([self class]) forKey:@"Class Name"];
	return objDictionary;
}

- (BOOL) portIsOpen
{
    return [refClock portIsOpen];
}

- (int) CableDelay
{
    return cableDelayNs;
}
- (void) setCableDelay:(int)aDelay
{
    cableDelayNs = aDelay;
}

- (NSString*) lastReceived{
    return lastRecTelegram;
}

- (unsigned int) visibleSatellites{
    return visibleSatellites;
}
- (unsigned int) trackedSatellites{
    return trackedSatellites;
}
- (unsigned int) accSignalStrength{
    return accSignalStrength;
}
- (NSString*) antennaSense{
    return antennaSense;
}
- (float) oscTemperature{
    return oscTemperature;
}

#pragma mark *** Commands
- (void) writeData:(NSDictionary*)aDictionary
{
    [refClock addCmdToQueue:aDictionary];
}

#define visSatIdx 55
#define trSatIdx 56
#define chanDatIdx 57
#define relSigStrIdx 2
#define antSenseIdx 130
#define antSenseBitMask 0x06
#define tempIdx 139

- (void) processResponse:(NSData*)receivedData forRequest:(NSDictionary*)lastRequest;
{
    //receivedData should have been processed by refClockModel to be the full response.
    //Here is where the data is decoded into something meaningful for this object
    
    //use [refClock lastRequest] to get the orginal command
    NSLog(@"debug Moto \n");
     if([refClock verbose]) NSLog(@"Received Moto GPS response \n");
    
    ///MAH -- I didn't attempt to do anything to the old processing code below since I don't know the format
    //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

    unsigned short nBytes = [receivedData length];
    unsigned char* bytes = (unsigned char *)[receivedData bytes];
    //if([inComingData length] >= 7) {
    if(bytes[nBytes - 1] == '\n') { // check for trailing \n (LF)
        //lastRecTelegram = [NSString stringWithCString:(char*)bytes encoding: NSASCIIStringEncoding];
        //lastRecTelegram = [[NSString alloc]initWithBytes:bytes length:nBytes encoding:NSASCIIStringEncoding];
        lastRecTelegram = [self bytesToPrintable:bytes length:nBytes];
        
        if([lastRequest isEqualToDictionary:[self statusCommand]]){
            NSLog(@"processing GPS status...\n");
//#define visSatIdx 55
//#define trSatIdx 56
//#define chanDatIdx 57
//#define relSigStrIdx 2
//#define antSenseIdx 130
//#define antSenseBitMask 0x06
            
            
            
            
            
            
            
            
//#define tempIdx 139
            
//        //status variables
            visibleSatellites = bytes[visSatIdx];
            trackedSatellites = bytes[trSatIdx];
            accSignalStrength = 0;
            unsigned char chanSignalStrength;
            for (int i = 0; i < 12; ++i){
                chanSignalStrength = bytes[chanDatIdx + 6*i + relSigStrIdx];
                accSignalStrength += chanSignalStrength;
            }
            switch(bytes[antSenseIdx] & antSenseBitMask){
                case 0: antennaSense = @"OK"; break;
                case 2: antennaSense = @"over current (shorted!)"; break;
                case 4: antennaSense = @"under current (open!)"; break;
                case 6: antennaSense = @"warning: not valid"; break;
            }

            oscTemperature = -110.0;
            unsigned short temperature = bytes[tempIdx];
            oscTemperature += 0.5 * temperature;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ORMotoGPSStatusValuesReceived object:self];
        }
        
//        if([refClock verbose]){
//            //NSLog(@"last command: %s (synClock dataAvailable) \n", lastCmd);
//            NSLog(@"Data received: %s ; size: %d \n", bytes, nBytes);
//        }

        [[NSNotificationCenter defaultCenter] postNotificationName:ORMotoGPSModelReceivedMessageChanged object:self];
    }
    else {
        NSLog(@"Warning (MotoGPSModel::dataAvailable): unsupported command \n");
    }

}

- (NSString*) bytesToPrintable:(unsigned char *)bytes length:(unsigned short)aLength{
    NSString* printable = [[NSString alloc]init];
    char c;
    for(int i = 0; i < aLength; ++i){
        c = bytes[i];
        if(isprint(c)){
            printable = [printable stringByAppendingFormat:@"%c", c];
        }
        else{
            printable = [printable stringByAppendingString:@"."];
        }
    }
    
    return printable;
}

- (void) setDefaults{
    [self writeData:[self defaultsCommand]];
}
- (void) autoSurvey{
    [self writeData:[self autoSurveyCommand]];
}
- (void) requestStatus
{
    [self writeData:[self statusCommand]];
}

- (NSDictionary*) defaultsCommand
{
    unsigned char cmdData[7];
    cmdData[0] = '@';
    cmdData[1] = '@';
    cmdData[2] = 'C';
    cmdData[3] = 'f';
    cmdData[4] = 0x25;  // checksum
    cmdData[5] = '\r';
    cmdData[6] = '\n';

    NSDictionary * commandDict = @{
                               @"data"      : [NSData dataWithBytes:cmdData length:7],
                               @"device"    : ORMotoGPS,
                               @"replySize" : @7
                               };
    NSLog(@"MotoGPSModel::statusCommand! \n");

    return commandDict;
}

- (NSDictionary*) autoSurveyCommand{
    unsigned char cmdData[8];
    cmdData[0] = '@';
    cmdData[1] = '@';
    cmdData[2] = 'G';
    cmdData[3] = 'd';
    cmdData[4] = 0x03;  // 3: enabel auto-survey
    cmdData[5] = 32;  // checksum
    cmdData[6] = '\r';
    cmdData[7] = '\n';
    
    NSDictionary * commandDict = @{
                                   @"data"      : [NSData dataWithBytes:cmdData length:8],
                                   @"device"    : ORMotoGPS,
                                   @"replySize" : @8
                                   };
    NSLog(@"MotoGPSModel::autoSurveyCommand! \n");
    
    return commandDict;
}

- (NSDictionary*) statusCommand{
    unsigned char cmdData[8];
    cmdData[0] = '@';
    cmdData[1] = '@';
    cmdData[2] = 'H';
    cmdData[3] = 'a';
    cmdData[4] = 0x00;  // 0: GPS response message once
    cmdData[5] = 41;  // checksum
    cmdData[6] = '\r';
    cmdData[7] = '\n';
    
    NSDictionary * commandDict = @{
                                   @"data"      : [NSData dataWithBytes:cmdData length:8],
                                   @"device"    : ORMotoGPS,
                                   @"replySize" : @154
                                   };
    NSLog(@"MotoGPSModel::statusCommand! \n");
    
    return commandDict;
}

- (NSUndoManager*) undoManager
{
    return [refClock undoManager];
}
#pragma mark ***Archival
- (id)initWithCoder:(NSCoder*)decoder  // todo: function needed?
{
    self = [super init];

    [[self undoManager] disableUndoRegistration];
    [self setCableDelay:  [decoder decodeIntForKey:  @"cableDelayNs"]];
    //lastRecTelegram = [[[NSString alloc] init] retain];
    //lastRecTelegram = @"";
    [[self undoManager] enableUndoRegistration];
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder  // todo: function needed?
{
    [encoder encodeInt: cableDelayNs  forKey:@"cableDelayNs"];
}
@end

@implementation ORMotoGPSModel (private)

- (void) updatePoll
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updatePoll) object:nil];
    float delay = 4.0; // Seconds
    if(statusPoll){
        [self requestStatus];
        [self performSelector:@selector(updatePoll) withObject:nil afterDelay:delay];
    }
    return;
}


@end
