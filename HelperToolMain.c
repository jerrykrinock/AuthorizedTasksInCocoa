#include "BetterAuthorizationSampleLib.h"

extern const BASCommandProc kCommandProcs[] ;
extern const BASCommandSpec kCommandSpecs[] ;

int main(int argc, char **argv)
{
    // Go directly into BetterAuthorizationSampleLib code.
	// It will call back to one of our procedures given in the command specs.
	
	return BASHelperToolMain(kCommandSpecs, kCommandProcs);
	
    // IMPORTANT: BASHelperToolMain doesn't clean up after itself,
	// so once it returns we must quit.
}
