#import "SSYAuthorizedTaskMaster+SetPermissions.h"
#import "AuthorizedTasks_Typicapp.h"
#import "NSError+SSYAdds.h"
#import "NSDictionary+Readable.h"

@implementation SSYAuthorizedTaskMaster (SetPermissionsTask)

- (BOOL)getPermissions_p:(NSDictionary**)oldPermissions_p
		  setPermissions:(NSDictionary*)newPermissions
				 error_p:(NSError**)error_p {
	if (!error_p) {
		NSError* error = nil ;
		error_p = &error ;
	}
	
	// Create request.
	NSDictionary* request = [NSDictionary dictionaryWithObjectsAndKeys:
							 @kSetPermissionsCommand, @kBASCommandKey,
							 (CFDictionaryRef)newPermissions, @kInfos,
							 nil] ;
	
	// Execute request in helper tool.
	NSDictionary* response = nil ;
	BOOL ok = [self executeRequest:request
						response_p:&response
						   error_p:error_p] ;
	int errCode = 0 ;
	if (!ok) {
		errCode = 15846 ;
	}
	else {
		NSDictionary* failures = [response objectForKey:@kErrorDescriptions] ;
		if ([failures respondsToSelector:@selector(count)]) {
			if ([failures count] != 0) {
				errCode = 26015 ;
			}
		}
	}
	
	if (errCode != 0) {
		NSError* error_ = SSYMakeError(errCode, @"SSYAuthorizedTaskMaster failed") ;
		*error_p = [*error_p errorByAddingUserInfoObject:[response objectForKey:@kErrorDescriptions]
												  forKey:@kErrorDescriptions] ;
		*error_p = [error_ errorByAddingUnderlyingError:*error_p] ;
	}
	
	if (oldPermissions_p) {
		NSDictionary* infos = [response objectForKey:@kInfos] ;
		*oldPermissions_p = infos ;
	}
	
	return ok ;
}	

- (BOOL)getPermissionNumber_p:(NSNumber**)oldPermissionNumber_p
		  setPermissionNumber:(NSNumber*)newPermissionNumber
						 path:(NSString*)path
					  error_p:(NSError**)error_p {
	NSDictionary* oldPermissions = nil ;
	NSDictionary* newPermissions = [NSDictionary dictionaryWithObject:newPermissionNumber
															   forKey:path] ;
	BOOL ok = [self getPermissions_p:&oldPermissions
					  setPermissions:newPermissions
							 error_p:error_p] ;
	if (oldPermissionNumber_p) {
		NSArray* oldPermissionValues = [oldPermissions allValues] ;
		if ([oldPermissionValues count] > 0) {
			*oldPermissionNumber_p = [oldPermissionValues objectAtIndex:0] ;
		}
	}
	
	return ok ;
}

@end