#include "BetterAuthorizationSampleLib.h"
#include "AuthorizedTasks_Typicapp.h"

/*
 This array must have the same number of elements as kCommandSpecs, and
 corresponding elements must refer to the same tasks.
 
 Each element in the array must be a function name taken from a HelperToolTaskXXXX.c file.

 The array must end with a NULL termination sentinel.
*/
const BASCommandProc kCommandProcs[] = {
	DoSetAnyUserPrefs,
	DoCopyPaths,
	DoStatPaths,
	DoSetPermissions,
    NULL  // array-termination sentinel
} ;
