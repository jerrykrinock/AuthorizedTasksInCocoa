#include <unistd.h>
#include <netinet/in.h>

#import <Cocoa/Cocoa.h>
#import "DemoAppController.h"
#import "SSDictionaryEntry.h"

#import "SSYAuthorizedTaskMaster+DemoTasks.h"

extern const BASCommandSpec kCommandSpecs[] ;

#define DIC_TO_READABLE_VALUES_ARRAY_TRANSFORMER @"DicToReadableValuesArrayTransformer"

@implementation DemoAppController

#pragma mark [NSApp delegate], SSYAuthorizedHelpee Protocol Methods

//  We implement only two of the optional SSYAuthorizedHelpee Protocol Methods.
//  Our shared taskmaster will be initialized with default values for the methods
//  that we don't implement.

- (NSString*)authorizedHelperToolName {
	return @"AuthorizedTaskHelperTool_Demo" ;
}

// We return the kCommandSpecs constant from this method in the application
// because, although kCommandSpecs is declared in the SSYAuthorizedTaskmaster
// framework, it is not defined in there, and since we use kCommandSpecs
// explicitly in the framework, the framework would not compile.
- (const BASCommandSpec*)authorizedHelperCommandSpecs {
	return kCommandSpecs ;
}


#pragma mark Authorized Actions

// Called when the user clicks the "GetVersion" button.  This is the simplest 
// possible BetterAuthorizationSample operation, in that it doesn't handle any failures.
- (IBAction)doGetVersion:(id)sender {
	NSError* error = nil ;
	NSString* version ;
	BOOL ok = [[SSYAuthorizedTaskMaster sharedTaskmaster] getVersion_p:&version
													error_p:&error] ;
	
	// Log our results.
    if (ok == YES) {
        [textViewLog insertText:[NSString stringWithFormat:@"version = %@\n", version]] ;
    }
	else {
        [textViewLog insertText:[error localizedDescription]] ;
		[textViewLog insertText:@"\n"] ;
    }
}

// Called when the user clicks the "GetUIDs" button.  This is a typical BetterAuthorizationSample 
// privileged operation implemented in Objective-C.
- (IBAction)doGetUIDs:(id)sender {
	NSError *error = nil ;
	NSString *ruid, *euid ;
	
    BOOL ok = [[SSYAuthorizedTaskMaster sharedTaskmaster] getRUID:&ruid
												  EUID:&euid
											   error_p:&error] ;
	
    // Log our results.
    
    if (ok == YES) {
        [textViewLog insertText:[NSString stringWithFormat:@"RUID = %@, EUID=%@\n", ruid, euid]] ;
	}
	else {
		[textViewLog insertText:[error localizedDescription]] ;
		[textViewLog insertText:@"\n"] ;
	}			   
}

// Calls helper to open three low-numbered ports (which can't otherwise by opened by 
// non-privileged code).
- (IBAction)doOpenSomeLowNumberedPorts:(id)sender {
	NSError *error = nil ;
	NSArray *lowNumberedPorts ;
	
    BOOL ok = [[SSYAuthorizedTaskMaster sharedTaskmaster] openSomeLowPortNumbers_p:&lowNumberedPorts
														   error_p:&error] ;
	
    // Log our results.
    if (ok == YES) {
        [textViewLog insertText:
		 [NSString stringWithFormat:@"ports[0] = %d, port[1] = %d, port[2] = %d\n", 
		  [[lowNumberedPorts objectAtIndex:0] intValue], 
		  [[lowNumberedPorts objectAtIndex:1] intValue], 
		  [[lowNumberedPorts objectAtIndex:2] intValue]]];
	}
	else {
		[textViewLog insertText:[error localizedDescription]] ;
		[textViewLog insertText:@"\n"] ;
	}
}
    
- (NSMutableDictionary *)anyUserPrefsDic {
    if (_anyUserPrefsDic == nil) {
		_anyUserPrefsDic = [[NSMutableDictionary alloc] init] ;
	}
	
	return _anyUserPrefsDic ;
}

- (void)setAnyUserPrefsDic:(NSMutableDictionary *)value {
    if (_anyUserPrefsDic != value) {
        [_anyUserPrefsDic release];
        _anyUserPrefsDic = [value retain];
    }
}

- (IBAction)doSetSystemPrefs:(id)sender {
	NSError *error = nil ;
	NSMutableDictionary *anyUserPrefsDic = [self anyUserPrefsDic] ;
	
    BOOL ok = [[SSYAuthorizedTaskMaster sharedTaskmaster] setAnyUserPrefs:anyUserPrefsDic
												inBundleIdentifier:[textBundleID stringValue]
														   error_p:&error] ;
	if (ok == YES) {
        [textViewLog insertText:@"Probably succeeded writing prefs\n"];
	}
	else {
		[textViewLog insertText:[error localizedDescription]] ;
		[textViewLog insertText:@"\n"] ;
	}
	
}

- (IBAction)doWriteTextToFile:(id)sender {
	NSError *error = nil ;
	NSString *text = [textToFile string] ;
	NSString *filePath = [pathToFile stringValue] ;
	
	NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding] ;
	
    BOOL ok = [[SSYAuthorizedTaskMaster sharedTaskmaster] writeData:data
															 toFile:filePath
															error_p:&error] ;
	if (ok == YES) {
        [textViewLog insertText:@"Probably succeeded writing data to file\n"];
	}
	else {
		NSString* text = [error localizedDescription] ;
		if (!text) {
			text = [NSString stringWithFormat:@"Sorry, taskmaster failed but returned error %p", error] ;
		}
		[textViewLog insertText:text] ;
		[textViewLog insertText:@"\n"] ;
	}
}

#pragma mark Utility Debugging Actions

- (IBAction)recreateRights:(id)sender {
	[[SSYAuthorizedTaskMaster sharedTaskmaster] recreateAuthorization] ;
}

- (IBAction)removeRightsForAllCommands:(id)sender {
	int i=0 ;
	while (kCommandSpecs[i].commandName != NULL) {
		// Not all commands have rightName, but all commands have commandName
		char *rightName = (char*)kCommandSpecs[i].rightName ;
		[textViewLog insertText:[NSString stringWithFormat:@"Removing right for %s", rightName]] ;
		[[SSYAuthorizedTaskMaster sharedTaskmaster] removeRight:rightName] ;
		i++ ;
	}
}

#pragma mark Class Infrastructure

-(id)init {
	if ((self = [super init])) {
		// This has nothing to do with demo-ing authorization.  It is only used in
		// binding the Prefs Key/Value table in the window to our _anyUserPrefsDic ivar.
		// Just something for the Cocoa geeks to enjoy.
		id transformer = [[DicToReadableValuesArray alloc] init] ; 
		[NSValueTransformer setValueTransformer:transformer			
										forName:DIC_TO_READABLE_VALUES_ARRAY_TRANSFORMER] ;
		[transformer release] ;
	}
	
	return self;
}

- (void)dealloc {
	[_anyUserPrefsDic release] ;
	
	[super dealloc] ;
}

@end