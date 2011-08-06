#import "SSYAuthorizedHelpee.h"

@interface DemoAppController : NSObject <SSYAuthorizedHelpee> {
    NSTextView* textViewLog;
	NSTextField* textBundleID ;
	NSTextView* textToFile ;
	NSTextField* pathToFile ;

	NSMutableDictionary* _anyUserPrefsDic ;
}

- (IBAction)doGetVersion:(id)sender;
- (IBAction)doGetUIDs:(id)sender;
- (IBAction)doOpenSomeLowNumberedPorts:(id)sender;
- (IBAction)doSetSystemPrefs:(id)sender ;
- (IBAction)doWriteTextToFile:(id)sender ;

- (IBAction)recreateRights:(id)sender;
- (IBAction)removeRightsForAllCommands:(id)sender ;

@end
