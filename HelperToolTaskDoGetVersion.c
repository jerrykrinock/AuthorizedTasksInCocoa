// Needed for any key constants used in the request/response dics:
#include "AuthorizedTasks_Demo.h"

// Needed for COMMAND_PROC_ARGUMENTS:
#include "CommandProcArguments.h"

// Provides some handy utilities for dealing with CF (CoreFoundation).
// It may not be used in all tasks but is included so you don't lose it.
#include "MoreCFQ.h"


OSStatus DoGetVersion(COMMAND_PROC_ARGUMENTS) {	
	OSStatus					retval = noErr;
	CFNumberRef					value;
    static const int kCurrentVersion = 17;          // something very easy to spot
	
	// Pre-conditions
	
    // userData may be NULL
	assert(request != NULL);
	assert(response != NULL);
    // asl may be NULL
    // aslMsg may be NULL
	
    // Add them to the response.
    
	value = CFNumberCreate(NULL, kCFNumberIntType, &kCurrentVersion);
	if (value == NULL) {
		retval = coreFoundationUnknownErr;
    } else {
        CFDictionaryAddValue(response, CFSTR(kNumberPayload), value);
	}
	
	if (value != NULL) {
		CFRelease(value);
	}

	return retval;
}
