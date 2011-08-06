#ifndef _COMMANDPROCARGUMENTS_H
#define _COMMANDPROCARGUMENTS_H


// A convenient constant for inserting the long list of arguments required in a BASCommandProc
// All the "command procs" that implement your tasks must have the same signature
// This is the list of arguments for the "command procs".
// (Backslash causes #define to continue onto next line)

// This argument signature is required by BetterAuthorizationSample.  Don't change it.

#define COMMAND_PROC_ARGUMENTS                \
AuthorizationRef			auth,     \
const void *                userData, \
CFDictionaryRef				request,  \
CFMutableDictionaryRef      response, \
aslclient                   asl,      \
aslmsg                      aslMsg



#endif