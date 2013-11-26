//
//  TaskStep.m
//  CocoaScript
//
//  Created by Matt Gallagher on 2010/11/01.
//  Copyright 2010 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "ORInvocationStep.h"
#import "OROpSequenceQueue.h"
#import "NSInvocation+Extensions.h"

@implementation ORInvocationStep

@synthesize invocation;
@synthesize outputStateKey;

+ (ORInvocationStep*)invocation:(NSInvocation*)anInvocation;
{
	ORInvocationStep* step = [[[self alloc] init] autorelease];
    step.invocation = anInvocation;
	return step;
}

- (void)dealloc
{
    [invocation release];
    invocation = nil;
	[super dealloc];
}

- (void)runStep
{
	if (self.concurrentStep) [NSThread sleepForTimeInterval:5.0];

    [invocation invokeWithNoUndoOnTarget:[invocation target]];
    id result = [invocation returnValue];
    
    if (outputStateKey && result){
        [currentQueue setStateValue:result forKey:outputStateKey];
	}
}


@end
