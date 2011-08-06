#import <Cocoa/Cocoa.h>
#import <Security/Authorization.h>
#include "BetterAuthorizationSampleLib.h"

#define SSYAuthorizedTaskmasterInitialErrorCode 251000
#define SSYAuthorizedTaskmasterNoCommandSpecsCantRemoveRightsErrorCode 251001
#define SSYAuthorizedTaskmasterErrorRemovingRightErrorCode 251002
#define SSYAuthorizedTaskmasterRequestIsNilErrorCode 251003
#define SSYAuthorizedTaskmasterNoCommandSpecsCantExecuteErrorCode 251004
#define SSYAuthorizedTaskmasterNoCommandSpecsErrorCode 251005
#define SSYAuthorizedTaskmasterNilHelperToolNameErrorCode 251006
#define SSYAuthorizedTaskmasterHelperReturnedError_ErrorCode 251007
#define SSYAuthorizedTaskmasterHelperReturnedNoData_ErrorCode 251008

extern NSString* const SSYAuthorizedTaskmasterErrorDomain ;

/*!
 @brief     A class for accessing a privileged Helper Tool to perform authorized tasks
 @details   Designed to instantiated as a singleton, but you could have more than
 one if you really wanted to.
 */
@interface SSYAuthorizedTaskMaster : NSObject {
	AuthorizationRef authorizationRef ;
	// We can't retain the C array _commandSpecs, but by
	// requiring it to be const we insure that it won't go away.
	const BASCommandSpec* commandSpecs ;
	NSString* helperToolName ;
	NSString* installerToolName ;
}

/*!
 @brief    To get and/or create a SSYAuthorizedTaskmaster singleton for an application.
 @details  Recommended unless you have > 1 authorized helper tool in an application.&nbsp; 
 The sharedTaskmaster singleton is initialized with value(s) returned by [NSApp delegate] if
 it responds to any of the optional methods in the SSYAuthorizedHelpee protocol.&nbsp;  
 Otherwise, the default values given in the designated initializer documentation are used.
 @result   The SSYAuthorizedTaskmaster singleton.
 */
+ (SSYAuthorizedTaskMaster*)sharedTaskmaster ;

/*!
 @brief    Designated initializer.
 @details  An instance of SSYAuthorizedTaskmaster needs to know what its commands are,
 what additional prompt if any to present in the authentication dialog, and the name
 of the tool that executes the tasks.
 @param    commandSpecs a C array of BASCommandSpec structs, specifying the commands that
 the receiver will implement.&nbsp;   Because we can't retain a C array,
 we require it to be const we insure that it won't go away.&nbsp; If this is NULL, commandSpecs
 will be set to a an array consisting of a single element of NULL components, which won't
 be very useful.&nbsp;  To be useful, this parameter must not be NULL.
 @param    helperToolName The name of the authorized helper tool which must be found in
 Contents/MacOS.&nbsp;  If you pass nil, defaults to @"AuthorizedTaskHelperTool".
 @param    installerToolName The name of the tool used to install the helper tool which must be
 found in Contents/MacOS.&nbsp;  If you pass nil, defaults to @"AuthorizedTaskHelperToolInstaller".
 @param    stringsFilename The name of a .strings file containing the prompt(s) specified in the
 rightDescriptionKey field(s) of the BASCommandSpec structs in commandSpecs.&nbsp;  If nil, defaults
 to the usual "Localizable".&nbsp;  This argument is only used for prepending a string to the " MyApp.app
 requires that you type your/administrator password" prompt in the authentication dialogs.
 @param    bundleIdentifier The bundle identifier of the bundle which contains the 
 stringsFilename.strings file in its Resources.&nbsp;  If nil, defaults to 
 [[NSBundle mainBundle] bundleIdentifier].&nbsp;  This argument is only used for prepending a string to the
 " MyApp.app requires that you type your/administrator password" prompt in the authentication dialogs.&nbsp;  
 It may be nil.
 */
- (id)initWithCommandSpecs:(const BASCommandSpec *)commandSpecs
			helperToolName:(NSString *)helperToolName
		 installerToolName:(NSString *)installerToolName
		   stringsFilename:(NSString*)stringsFilename
		  bundleIdentifier:(NSString*)bundleIdentifier ;

/*!
 @brief    Executes request in the Helper Tool
 @details  
 @param    request request to be executed
 @param    response_p Pointer to which the response NSDictionary* will be assigned.&nbsp;  
 *response_p will be autoreleased, but you must close any file descriptors
 that you get in it.
 @param    #error_p  Pointer to an NSError* to which any error which occurs
 will be assigned.  You may pass NULL if not interested in the error.
 
 @result   YES if successful, NO otherwise
 */
- (BOOL)executeRequest:(NSDictionary*)request
			response_p:(NSDictionary**)response_p
			   error_p:(NSError**)error_p ;

/*!
 @brief    Removes a named right from the system's Security Server's
 credentials cache, using AuthorizationRightRemove().
 
 @details  A utility method, useful in debugging
 @param    rightName The name of the right to be removed
 @result   The valued returned by AuthorizationRightRemove(), or
  paramErr if rightName is NULL.
 */
- (OSStatus)removeRight:(const char*)rightName ;

/*!
 @brief     Removes the rights specified for all commands in the
 receiver's current commandSpec from the the system's Security Server's
 credentials cache, using AuthorizationRightRemove().

 @details  A utility method, useful in debugging.&nbsp;  
 @param    error_p  On return, if an error occurred, points to
 an error giving the cause.&nbsp;  If you are not interested in the error,
 you may pass NULL.
 @result   YES upon success, otherwise NO.
*/
- (BOOL)removeRightsError_p:(NSError**)error_p ;


/*!
 @brief    Destroys the instance's authorization (_authRef) using AuthorizationFree() and then
 creates a new one using AuthorizationCreate().
 @details  A utility method, useful in debugging
 @param    rightName The name of the right to be removed
 */
- (void)recreateAuthorization ;

@end
