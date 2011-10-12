//
//  ORSerialPortList.h
//  ORCA
//
//  Created by Mark Howe on Mon Feb 10 2003.
//  Copyright � 2002 CENPA, University of Washington. All rights reserved.
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

//  Mark Howe  -- Modified from ORSerialPortList.h by Andreas Mayer

#import "ORSerialPort.h"

@interface ORSerialPortList : NSObject
{
	@private
        NSMutableArray*		 portList;
        NSArray*			 oldPortList;
		NSMutableDictionary* aliaseDictionary;
}

+ (ORSerialPortList*) sharedSerialPortList;
+ (NSEnumerator*) portEnumerator;

- (unsigned) count;
- (ORSerialPort*) objectAtIndex:(unsigned)index;
- (ORSerialPort*) objectWithName:(NSString*) name;
- (NSArray*) getPortList;

- (NSString*) aliaseForPort:(ORSerialPort*)aPort;
- (NSString*) aliaseForPortName:(NSString*)aPortName;
- (void) assignAliase:(NSString*)anAliase forPort:(ORSerialPort*)aPort;


@end
