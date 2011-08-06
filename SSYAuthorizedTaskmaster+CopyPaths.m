#import "SSYAuthorizedTaskMaster+CopyPaths.h"
#import "AuthorizedTasks_Typicapp.h"
#import "NSError+SSYAdds.h"
#import "NSDictionary+Readable.h"
#import "NSError+LowLevel.h"

NSString* const SSYAuthorizedTaskMasterPerPathErrors = @"SSYAuthorizedTaskMasterPerPathErrors" ;



@implementation SSYAuthorizedTaskMaster (CopyPathsTask)

- (BOOL)copyFilePaths:(NSDictionary*)paths
			  error_p:(NSError**)error_p {
	if (!error_p) {
		NSError* error = nil ;
		error_p = &error ;
	}
	
	NSMutableArray* infos = [[NSMutableArray alloc] init] ;
	
	for (NSString* path in paths) {
		
		
		NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:
							  path, @kSourcePath,
							  [paths objectForKey:path], @kDestinPath,
							  nil] ;
		
		[infos addObject:info] ;
	}
	
	// Create request.
	NSDictionary* request = [NSDictionary dictionaryWithObjectsAndKeys:
							 @kCopyPathsCommand, @kBASCommandKey,
							 (CFArrayRef)infos, @kInfos,
							 nil] ;
	[infos release] ;
	
	// Execute request.
	NSDictionary* response = nil ;
	NSError* underlyingError = nil ;
	BOOL ok = [self executeRequest:request
						response_p:&response
						   error_p:&underlyingError] ;
	
	int errCode = 0 ;
	if (!ok) {
		errCode = 23560 ;
	}
	else {
		NSDictionary* errors = [response objectForKey:@kErrors] ;
		if ([errors respondsToSelector:@selector(count)]) {
			if ([errors count] != 0) {
				errCode = 23565 ;
			}
		}
	}
	
	if (errCode != 0) {
		*error_p = SSYMakeError(errCode, @"SSYAuthorizedTaskMaster executeRequest::: failed") ;
		NSDictionary* perPathErrors = [response objectForKey:@kErrors] ;
		*error_p = [*error_p errorByAddingUserInfoObject:perPathErrors
												  forKey:SSYAuthorizedTaskMasterPerPathErrors] ;
		if (!perPathErrors) {
			*error_p = [*error_p errorByAddingUnderlyingError:underlyingError] ;
		}
		*error_p = [*error_p errorByAddingUserInfoObject:paths
												  forKey:@"Paths"] ;
	}
	
	return ok ;
}	

- (BOOL)copyPath:(NSString*)sourcePath
		  toPath:(NSString*)destinPath
		 error_p:(NSError**)error_p {
	NSError* error = nil ;
	NSDictionary* paths = [NSDictionary dictionaryWithObjectsAndKeys:
						   destinPath,   // value (destin)
						   sourcePath,   // key   (source)
						   nil] ;
	BOOL ok = [self copyFilePaths:paths
						  error_p:&error] ;
	if (!ok) {
		NSDictionary* perPathErrors = [[error userInfo] objectForKey:SSYAuthorizedTaskMasterPerPathErrors] ;
		if (perPathErrors) {
			NSDictionary* errorDictionary = [perPathErrors objectForKey:sourcePath] ;
			if (errorDictionary) {
				error = [NSError errorWithPosixErrorCode:[[errorDictionary objectForKey:@kErrno] integerValue]] ;
			}
		}
	}
	
	if (error && error_p) {
		*error_p = error ;
	}
	
	return ok ;
}

@end