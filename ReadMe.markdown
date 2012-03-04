### Why you should Not Use This Code

Do not use this code.  This framework is based on Apple's BetterAuthorizationSample and is very complicated, even with this code to guide you.  There is an easier way, beginning with Mac OS X 10.6.

**Are you sandboxed?**  In turn, BetterAuthorizationSample uses the Authorization Services framework, in whose documentation it is now stated that the *authorization services API is not supported within an app sandbox because it allows privilege escalation*.

**Are you still supporting Mac OS X 10.5?**   For applications requiring Mac OS X 10.6 or later, the Service Management framework, function SMJobBless() in particular, should be used instead of this.

### Modern Alternatives

Nathan de Vries seems to have [figured it all out](http://atnan.com/blog/2012/02/29/modern-privileged-helper-tools-using-smjobbless-plus-xpc/
).