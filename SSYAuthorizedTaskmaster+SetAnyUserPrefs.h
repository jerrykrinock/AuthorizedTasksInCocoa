#import <Cocoa/Cocoa.h>
#import "SSYAuthorizedTaskMaster/SSYAuthorizedTaskMaster.h"


@interface SSYAuthorizedTaskMaster (Tasks) 

- (BOOL)setAnyUserPrefs:(NSDictionary*)prefs
	 inBundleIdentifier:(NSString*)bundleIdentifier
				error_p:(NSError**)error_p ;

@end
