#! /bin/sh

# This uninstalls the hidden references to AuthorizedTaskHelperTool installed when the demo runs.  It's necessary to run this as part of your "clean" cycle testing to ensure that an old version is not run.

# You must change the following line.  See Readme.rtf for instructions.
companyID=com.sheepsystems.BookMacster

echo Running script $0
echo      Real User ID is $UID
echo Effective User ID is $EUID
sudo launchctl unload -w /Library/LaunchDaemons/$companyID.plist
sudo rm /Library/LaunchDaemons/$companyID.plist
sudo rm /Library/PrivilegedHelperTools/$companyID
sudo rm /var/run/$companyID.socket
echo
echo Did unload or remove $companyID files from system
echo unless errors above indicated that some items did not exist.
echo To verify, repeat the process and see No Such file or directory.
