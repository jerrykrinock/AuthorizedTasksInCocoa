#import <Cocoa/Cocoa.h>
#import "SSYAuthorizedTaskMaster.h"
#import "SSYAuthorizedHelpee.h"

#include "CommandProcArguments.h"
#include "BetterAuthorizationSampleLib.h"

static SSYAuthorizedTaskMaster* sharedTaskmaster = nil ;

NSString* const SSYConstKeyOSStatusErrorCode = @"OSStatus" ;
NSString* const SSYAuthorizedTaskmasterErrorDomain = @"SSYAuthorizedTaskmasterErrorDomain" ;

const BASCommandSpec nullCommandSpecs[] = {				
	// Only the null termination, just to keep from crashing.
	{	NULL,
		NULL, 
		NULL, 
		NULL,
		NULL
	}
} ;

@implementation SSYAuthorizedTaskMaster

+ (NSError*)errorWithOSStatusErrorCode:(NSInteger)code {
	NSString* domain ;
	NSString* descString ;
	domain = NSOSStatusErrorDomain ;
	const char* cString = GetMacOSStatusCommentString(code) ;

	if (cString) {
		descString = [NSString stringWithUTF8String:cString] ;
	}
	else {
		descString = [NSString stringWithFormat:
					  @"OSStatus error code %d.  See MacErrors.h",
					  code] ;
	}
	
	NSError* error= [NSError errorWithDomain:domain
										code:code
									userInfo:nil] ;

	return error ;
}

- (void)setHelperToolName:(NSString*)helperToolName_ {
    if (helperToolName != helperToolName_) {
        [helperToolName release];
        helperToolName = [helperToolName_ retain];
    }
}

- (void)setInstallerToolName:(NSString*)installerToolName_ {
	if (installerToolName != installerToolName_) {
        [installerToolName release];
        installerToolName = [installerToolName_ retain];
    }
}

- (const BASCommandSpec *)commandSpecs {
    return commandSpecs ;
}

- (NSString *)helperToolName {
    return helperToolName ;
}

- (NSString *)installerToolName {
    return installerToolName ;
}

- (id)initWithCommandSpecs:(const BASCommandSpec*)commandSpecs_
			helperToolName:(NSString*)helperToolName_
		 installerToolName:(NSString*)installerToolName_
		   stringsFilename:(NSString*)stringsFilename
		  bundleIdentifier:(NSString*)bundleIdentifier {
	self = [super init];
	if (self != nil) {
		OSStatus    err;
		
		// Create the AuthorizationRef that we'll use through this application.  We ignore 
		// any error from this.  A failure from AuthorizationCreate is very unusual, and if it 
		// happens there's no way to recover; Authorization Services just won't work.
		
		// If we don't do this, to assign _authRef before attempting a privileged task,
		// an assertion will burp out of BetterAuthorizationSampleLib.
		err = AuthorizationCreate(NULL, NULL, kAuthorizationFlagDefaults, &authorizationRef);
		if (
			(err != noErr) 
			||
			(authorizationRef == NULL)
			) {
			NSLog(@"Internal Error 231-0571.  Could not create Authorization.") ;
			[self release] ;
			return nil ;
		}

		if (commandSpecs_ == NULL) {
			NSLog(@"Internal Error 231-0574.  NULL commandSpecs.  Trouble ahead.") ;
			commandSpecs_ = nullCommandSpecs ;
		}
		commandSpecs = commandSpecs_ ;
		
		if (bundleIdentifier == nil) {
			bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier] ;
		}
		
		BASSetDefaultRules(
						   authorizationRef, 
						   commandSpecs, 
						   (CFStringRef)bundleIdentifier, 
						   (CFStringRef)stringsFilename
						   ) ;
		if (helperToolName_ == nil) {
			helperToolName_ = @"AuthorizedTaskHelperTool" ;
		}
		[self setHelperToolName:helperToolName_] ;
		
		if (installerToolName_ == nil) {
			installerToolName_ = @"AuthorizedTaskHelperToolInstaller" ;
		}
		[self setInstallerToolName:installerToolName_] ;
	}
	return self;
}


+ (SSYAuthorizedTaskMaster*)sharedTaskmaster {
	@synchronized(self) {
        if (sharedTaskmaster == nil) {
			// Get configuration parameters from NSApp's delegate, or assign defalts
			const BASCommandSpec* authorizedHelperCommandSpecs = NULL ; // defaults to @"AuthorizedTaskHelperTool"
			if ([NSApp delegate]) {
				if ([[NSApp delegate] respondsToSelector:@selector(authorizedHelperCommandSpecs)]) {
					authorizedHelperCommandSpecs = [(NSObject <SSYAuthorizedHelpee> *)[NSApp delegate] authorizedHelperCommandSpecs] ;
					
					NSString* authorizedHelperToolName = nil ; // defaults to @"AuthorizedTaskHelperTool"
					if ([[NSApp delegate] respondsToSelector:@selector(authorizedHelperToolName)]) {
						authorizedHelperToolName = [(NSObject <SSYAuthorizedHelpee> *)[NSApp delegate] authorizedHelperToolName] ;
					}
					NSString* authorizedHelperInstallerToolName = nil ; // defaults to "AuthorizedTaskHelperToolInstaller"
					if ([[NSApp delegate] respondsToSelector:@selector(authorizedHelperInstallerToolName)]) {
						authorizedHelperInstallerToolName = [(NSObject <SSYAuthorizedHelpee> *)[NSApp delegate] authorizedHelperInstallerToolName] ;
					}
					NSString* authorizedHelperStringsFilename = nil ; // defaults to "Localizable"
					if ([[NSApp delegate] respondsToSelector:@selector(authorizedHelperStringsFilename)]) {
						authorizedHelperStringsFilename = [(NSObject <SSYAuthorizedHelpee> *)[NSApp delegate] authorizedHelperStringsFilename] ;
					}
					NSString* authorizedHelperBundleIdentifier = nil ; // defaults to main bundle
					if ([[NSApp delegate] respondsToSelector:@selector(authorizedHelperBundleIdentifier)]) {
						authorizedHelperBundleIdentifier = [(NSObject <SSYAuthorizedHelpee> *)[NSApp delegate] authorizedHelperBundleIdentifier] ;
					}
					
					sharedTaskmaster = [[self alloc] initWithCommandSpecs:authorizedHelperCommandSpecs
														   helperToolName:authorizedHelperToolName
														installerToolName:authorizedHelperInstallerToolName
														  stringsFilename:authorizedHelperStringsFilename 
														 bundleIdentifier:authorizedHelperBundleIdentifier] ;			
				}
				else {
					NSLog(@"Warning 340-1566.  NSApp's delegate does not implement authorizedHelperCommandSpecs.") ;
					sharedTaskmaster = nil ;
				}
			}
			else {
				NSLog(@"Warning 340-1567.  SSYAuthorizedTaskmaster requires an app with a delegate.") ;
				sharedTaskmaster = nil ;
			}
		}
	}
    return sharedTaskmaster ;
}

- (void)dealloc {
	[self setHelperToolName:nil] ;
	[self setInstallerToolName:nil] ;
	
	[super dealloc] ;
}

- (OSStatus)removeRight:(const char*)rightName {
	OSStatus result = paramErr ;
	if (rightName != NULL) {
		result = AuthorizationRightRemove(
										  authorizationRef,
										  rightName
										  ) ;
	}
	
	return result ;
}

- (BOOL)removeRightsError_p:(NSError**)error_p {
	if (!error_p) {
		NSError* error = nil ;
		error_p = &error ;
	}
	BOOL ok = YES ;

	// Make sure command has been configured
	if ([self commandSpecs] == NULL) {
		NSString* errMsg = @"No command specs!" ;
		int errCode = SSYAuthorizedTaskmasterNoCommandSpecsCantRemoveRightsErrorCode ;
		*error_p = [NSError errorWithDomain:@"SSYAuthorizedTaskmaster"
									   code:errCode
								   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
											 [[self class] description], @"Object Class",
											 NSStringFromSelector(_cmd), @"Method",
											 errMsg, NSLocalizedDescriptionKey,
											 nil]] ;
		ok = NO ;
		goto end ;
	}
	
	int i = 0 ;
	while (YES) {
		BASCommandSpec commandSpec = ([self commandSpecs])[i] ;
		if (commandSpec.commandName == NULL) {
			// Hit the nil sentinel.  No more.
			break ;
		}
		
		// Get the rightName for the commandSpec at this index
		const char* rightName = commandSpec.rightName ;
		
		// Attempt to remove it
		OSStatus status = [self removeRight:rightName] ;
		
		// Handle error
		if (status != noErr) {
			NSError* error_ = [[self class] errorWithOSStatusErrorCode:status] ;
			NSString* errMsg = [NSString stringWithFormat:
					  @"Got Error attempting to remove right %@",
					  [NSString stringWithUTF8String:rightName]] ;
			int errCode = SSYAuthorizedTaskmasterErrorRemovingRightErrorCode ;
			*error_p = [NSError errorWithDomain:@"SSYAuthorizedTaskmaster"
										   code:errCode
									   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
												 [[self class] description], @"Object Class",
												 NSStringFromSelector(_cmd), @"Method",
												 errMsg, NSLocalizedDescriptionKey,
												 error_, NSUnderlyingErrorKey,
												 nil]] ;
			ok = NO ;
			goto end ;
		}
		
		i++ ;
	}
	
end:
	return ok ;
}



- (void)recreateAuthorization {
    // Called when the user chooses the "Recreate" button.  This is just a testing 
    // convenience; it allows you to destroy the credentials that are stored in the cache 
    // associated with _authRef, so you can force the system to ask you for a password again.  
    // However, this isn't as convenient as you might think because the credentials might 
    // be cached globally.  See DTS Q&A 1277 "Security Credentials" for the gory details.
    //
    // <http://developer.apple.com/qa/qa2001/qa1277.html>
	OSStatus    err;
	
	// Free _authRef, destroying any credentials that it has acquired along the way. 
	
	err = AuthorizationFree(authorizationRef, kAuthorizationFlagDestroyRights);
	assert(err == noErr);
	authorizationRef = NULL;
	
	
	// Recreate it from scratch.
	
	err = AuthorizationCreate(NULL, NULL, kAuthorizationFlagDefaults, &authorizationRef);
	assert(err == noErr);
	assert( (err == noErr) == (authorizationRef != NULL) );    
}

- (BOOL)executeRequest:(NSDictionary*)request
			response_p:(NSDictionary**)response_p
			   error_p:(NSError**)error_p {
	BOOL ok = YES ;
		
	int errCode ;
	NSString* errMsg ;
	
	if (request == nil) {
		if (error_p != NULL) {
			errMsg = @"Nil request" ;
			errCode = SSYAuthorizedTaskmasterRequestIsNilErrorCode ;
			*error_p = [NSError errorWithDomain:@"SSYAuthorizedTaskmaster"
										   code:errCode
									   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
												 [[self class] description], @"Object Class",
												 NSStringFromSelector(_cmd), @"Method",
												 errMsg, NSLocalizedDescriptionKey,
												 nil]] ;
		}
		ok = NO ;
		goto end ;
	}
		
	if ([self commandSpecs] == NULL) {
		if (error_p != NULL) {
			errMsg = @"Attempt to execute before commandSpecs have been set." ;
			errCode = SSYAuthorizedTaskmasterNoCommandSpecsCantExecuteErrorCode ;
			*error_p = [NSError errorWithDomain:@"SSYAuthorizedTaskmaster"
										   code:errCode
									   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
												 [[self class] description], @"Object Class",
												 NSStringFromSelector(_cmd), @"Method",
												 errMsg, NSLocalizedDescriptionKey,
												 nil]] ;
		}
		ok = NO ;
		goto end ;
	}
	
	if ([self helperToolName] == nil) {
		if (error_p != NULL) {
			errMsg = @"Attempt to execute with nil helper tool name." ;
			errCode = SSYAuthorizedTaskmasterNilHelperToolNameErrorCode ;
			*error_p = [NSError errorWithDomain:@"SSYAuthorizedTaskmaster"
										   code:errCode
									   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
												 [[self class] description], @"Object Class",
												 NSStringFromSelector(_cmd), @"Method",
												 errMsg, NSLocalizedDescriptionKey,
												 nil]] ;
		}
		ok = NO ;
		goto end ;
	}	
	
	// Although our invoker may not need a response, BASExecuteRequestInHelperTool
	// requires one, so we make one if we weren't given one.
	if (response_p == nil) {
		NSMutableDictionary* response ;
		response_p = &response ;
	}
	
	NSString* bundleID = [[NSBundle mainBundle] bundleIdentifier] ;	
	assert(bundleID != nil) ;
	
	*response_p = nil ;
	OSStatus err = noErr - 1 ;
	int nTries = 0 ;
	
	NSString* msg = nil ;
	BASFailCode failCode = SSYAuthorizedTaskmasterInitialErrorCode ; // initialized to suppress compiler warning
	
	while ((err != noErr) && (nTries < 2)) {
		err = BASExecuteRequestInHelperTool(
											authorizationRef, 
											[self commandSpecs], 
											(CFStringRef)bundleID, 
											(CFDictionaryRef)request, 
											(CFDictionaryRef*)response_p
											);
		if (err == userCanceledErr) {
			break ;
		}
		
		nTries++ ;
		if (nTries > 1) {
			break ;
		}
		
		// If it failed, try to reinstall the helper tool.
		if (err != noErr) {
			// BASFixFailure needs the failCode
			failCode = BASDiagnoseFailure(authorizationRef, (CFStringRef) bundleID);
			
			// BASFixFailure tries to reinstall the helper tool
			OSStatus fixErr = BASFixFailure(
								authorizationRef,
								(CFStringRef) bundleID,
								(CFStringRef)[self installerToolName],
								(CFStringRef)[self helperToolName],
								failCode
								) ;
			if (fixErr == userCanceledErr) {
				break ;
			}
			/*DB?Line*/ NSLog(@"12051: Helper tool failCode=%d  fixErr=%d", failCode, fixErr) ;
			
			if (fixErr != noErr) {
				// The helper tool could not be installed or reinstalled.
				// So we go back to what the original failure was and try to inform the user
				// It is left as a homework assignment if anyone wants to localize this:
				switch (failCode) {
					case kBASFailUnknown:
						msg = @"failed for an unknown reason." ;
						break ;
					case kBASFailDisabled:
						msg = @"is installed but disabled." ;
						break ;
					case kBASFailPartiallyInstalled:
						msg = @"is only partially installed." ;
						break ;
					case kBASFailNotInstalled: 
						msg = @"is not installed." ;
						break ;
					case kBASFailNeedsUpdate:
						msg = @"is installed but out of date." ;
						break ;
					case coreFoundationUnknownErr:
						msg = @"Unknown error from BASFixFailure()" ;
				}
				msg = [NSString stringWithFormat:
					   @"%@ %@  Tried to reinstall it using %@ but that failed too.",
					   [self helperToolName],
					   msg,
					   [self installerToolName]] ;
			}			
		}
	}
	
	// If all of the above went OK, it means that the IPC (inter-process communication)
	// to the helper tool worked.  But that doesn't mean all is OK yet...
	// We now have to check the response to see if the command's execution within 
	// the helper tool was successful.
	if ((err == noErr) && (*response_p != nil)) {
		err = BASGetErrorFromResponse((CFDictionaryRef)*response_p) ;
	}
	
	// According to BASExecuteRequestInHelperTool, we must release *response_p.
	// Also, it will be nil if the request fails.
	// But the invoker needs it.  So, we autorelease it.
	[*response_p autorelease] ;
	
	// If error, assign ok and *error_p	
	if (err != noErr) {
		ok = NO ;
		if (*error_p != NULL) {
			*error_p = [[self class] errorWithOSStatusErrorCode:err] ;
			if (msg == nil) {
				msg = @"AuthorizedTaskHelperTool returned an error code." ;
			}
			
			if ([[*error_p domain] isEqualToString:NSOSStatusErrorDomain] && ([*error_p code] ==1)) {
				// It's an information-less "The operation couldn’t be completed." error.
				// Forget it.
				*error_p = nil ;
			}
			
			*error_p = [NSError errorWithDomain:SSYAuthorizedTaskmasterErrorDomain
										   code:SSYAuthorizedTaskmasterHelperReturnedError_ErrorCode
									   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
												 msg, NSLocalizedDescriptionKey,
												 *error_p, NSUnderlyingErrorKey,  // may be nil sentinel
												 nil]] ;
		}	
	}
	else if (*response_p == nil) {
		ok = NO ;
		if (*error_p != NULL) {
			msg = @"No data received from AuthorizedTaskHelperTool.\n" ;
			*error_p = [NSError errorWithDomain:@"SSYAuthorizedTaskmaster"
										   code:SSYAuthorizedTaskmasterHelperReturnedNoData_ErrorCode
									   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
												 msg, NSLocalizedDescriptionKey,
												 nil]] ;
		}
	}
	
end:
	return ok ;
}


@end