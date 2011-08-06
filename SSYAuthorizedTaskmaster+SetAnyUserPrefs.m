#import "SSYAuthorizedTaskMaster+SetAnyUserPrefs.h"
#import "AuthorizedTasks_Demo.h"
#import "NSError+Easy.h"

@implementation SSYAuthorizedTaskMaster (Tasks)

- (BOOL)setAnyUserPrefs:(NSDictionary*)prefs
	 inBundleIdentifier:(NSString*)bundleIdentifier
				error_p:(NSError**)error_p {
	SSYInitErrorP

	if ([prefs count] < 1) {
		SSYMakeAssignErrorP(22354, @"No key/value pairs to set in prefs") ;
		goto end ;
	}
	
    if ([bundleIdentifier length] < 1) {
		SSYMakeAssignErrorP(26574, @"No bundle identifier given to set") ;
		goto end ;
	}
	
	// Create request.
	NSDictionary* request = [NSDictionary dictionaryWithObjectsAndKeys:
							 @kSetAnyUserPrefsCommand, @kBASCommandKey,
							 prefs, @kDictionaryPayload,
							 bundleIdentifier, @kBundleIdentifier,
							 nil] ;
	
	// Execute request.
	BOOL ok = [self executeRequest:request
						response_p:NULL
						   error_p:error_p] ;
	
	if (!ok) {goto end;}
	
	// Process response 
	// No response and thus no processing required for this task
	
end:
	return ok ;
}	


@end