#import "SSYAuthorizedTaskMaster+StatPaths.h"
#import "AuthorizedTasks_Typicapp.h"
#import "NSError+SSYAdds.h"
#import "NSDictionary+Readable.h"
#import "NSError+LowLevel.h"
#import <sys/stat.h>

@implementation SSYAuthorizedTaskMaster (StatFilesTask)


- (BOOL)statFilePaths:(NSArray*)paths
			  stats_p:(NSDictionary**)stats_p
			  error_p:(NSError**)error_p {
	// Create request.
	NSDictionary* request = [NSDictionary dictionaryWithObjectsAndKeys:
							 @kStatPathsCommand, @kBASCommandKey,
							 (CFArrayRef)paths, @kInfos,
							 nil] ;
	
	// Execute request.
	NSDictionary* response = nil ;
	BOOL ok = [self executeRequest:request
						response_p:&response
						   error_p:error_p] ;
	
	int errCode = 0 ;
	if (!ok) {
		errCode = 24560 ;
	}
	else {
		if (stats_p) {
			*stats_p = [response objectForKey:@kStatDatas] ;
		}
		
		NSDictionary* failures = [response objectForKey:@kErrorCodes] ;
		if ([failures respondsToSelector:@selector(count)]) {
			if ([failures count] != 0) {
				errCode = 25565 ;
			}
		}
	}
	
	if (error_p && (errCode != 0)) {
		*error_p = SSYMakeError(errCode, @"SSYAuthorizedTaskMaster executeRequest::: failed") ;
		*error_p = [*error_p errorByAddingUserInfoObject:[response objectForKey:@kErrorCodes]
												  forKey:@kErrorCodes] ;
		*error_p = [*error_p errorByAddingUnderlyingError:*error_p] ;
	}
	
	return ok ;
}	

- (BOOL)statPath:(NSString*)path
			stat:(struct stat*)stat_p
		 error_p:(NSError**)error_p {
	// For efficiency in case the caller expects the path may not exist,
	// and has passed error_p = NULL, we don't create a local error.
	NSArray* paths = [NSArray arrayWithObject:path] ;
	NSDictionary* stats ;
	BOOL ok = [self statFilePaths:paths
						  stats_p:&stats
						  error_p:error_p] ;

	NSData* statData = [stats objectForKey:path] ;
	struct stat aStat ;
	size_t statSize = sizeof(aStat) ;
	if (statData && stat_p) {
		const void* bytes = [statData bytes] ;
		memcpy(&aStat, bytes, statSize) ;
		*stat_p = aStat ;
	}
	else if (error_p != NULL) {
		NSError* underlyingError = [*error_p underlyingError] ;
		NSDictionary* underlyingUserInfo = [underlyingError userInfo] ;
		NSDictionary* errorCodes = [underlyingUserInfo objectForKey:@kErrorCodes] ;
		NSNumber* errorCodeNumber = [errorCodes objectForKey:path] ;
		NSInteger errorCode = [errorCodeNumber integerValue] ;
		if (errorCode == SSYAuthorizedTasksPathTooLong) {
			*error_p = SSYMakeError(513315, @"Path too long") ;
		}
		else {
			*error_p = [NSError errorWithPosixErrorCode:errorCode] ;
		}

		*error_p = [SSYMakeError(513563, @"Could get stat for path even authorized") errorByAddingUnderlyingError:*error_p] ;
	}

	return ok ;
}

- (NSDate*)modificationDateForPath:(NSString*)path 
						   error_p:(NSError**)error_p {
	struct stat aStat ;
	NSError* error = nil ;
	NSDate* date = nil ;
	BOOL ok = [[SSYAuthorizedTaskMaster sharedTaskmaster] statPath:path
															  stat:&aStat
														   error_p:&error] ;
	if (ok) {
		time_t secs = aStat.st_mtimespec.tv_sec ;
		long nanosecs = aStat.st_mtimespec.tv_nsec ;
		NSTimeInterval timeSince1970 = secs + 1e-9 * nanosecs ;
		date = [NSDate dateWithTimeIntervalSince1970:timeSince1970] ;
	}
		
	return date ;
}

@end