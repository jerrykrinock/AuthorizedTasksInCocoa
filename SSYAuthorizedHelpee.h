#include "BetterAuthorizationSampleLib.h"

@protocol SSYAuthorizedHelpee

- (const BASCommandSpec*)authorizedHelperCommandSpecs ;

@optional

- (NSString*)authorizedHelperToolName ;
- (NSString*)authorizedHelperInstallerToolName ;
- (NSString*)authorizedHelperStringsFilename ;
- (NSString*)authorizedHelperBundleIdentifier ;

@end