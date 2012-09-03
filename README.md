SNReachability
==============
Network reachability check class for iOS
SNReachablityChecker class notifies an observer of changing network status.
The notification informs reachability and what kind of methods a device uses in order to reach the internet, local Wi-Fi or specified host.

License
=======
BSD License.

SNReachablityChecker Reference
=======

	+ (SNReachablityChecker*)reachabilityWithHostName:(NSString*)hostName;
###Parameters
####hostName
The name of host to check reachability to it.
###Discussion
Returned the instance to notify of information about reachability to the host you specified.

	+ (SNReachablityChecker*)reachabilityForInternetConnection;
###Discussion
Returned the instance to notify of information about reachability to the internet.


	+ (SNReachablityChecker*)reachabilityForLocalWiFi;
###Discussion
Returned the instance to notify of information about reachability to the local wireless network.

	- (BOOL)start;
###Discussion
Start notifying.

	- (void)stop;
###Discussion
Stop notifying.

Properties
======
###type
The receiver's type.

	@property (nonatomic, readonly) SNReachablityCheckerType type;
###Discussion
Return type of the reachability checer type, expressed "SNReachablityCheckerType".

###status
The receiver's status.

	@property (nonatomic, readonly) SNReachablityCheckerStatus status;
###Discussion
Return the status of current network, expressed "SNReachablityCheckerStatus".

Constants
======
	typedef enum SNReachablityCheckerType_ {
		SNReachablityCheckerHostConnectivity		= 0,
		SNReachablityCheckerInternetConnectivity	= 1,
		SNReachablityCheckerLocalWiFiConnectivity	= 2
	}SNReachablityCheckerType;

###SNReachablityCheckerHostConnectivity
Returned this vaue if you created the instance of SNReachabilityChecker using reachabilityWithHostName:.

###SNReachablityCheckerInternetConnectivity
Returned this vaue if you created the instance of SNReachabilityChecker using reachabilityForInternetConnection.

###SNReachablityCheckerLocalWiFiConnectivity
Returned this vaue if you created the instance of SNReachabilityChecker using reachabilityForLocalWiFi.

	typedef enum SNReachablityCheckerStatus_ {
		SNReachablityCheckerNotReachable			= 0,
		SNReachablityCheckerReachableViaWiFi		= 1,
		SNReachablityCheckerReachableViaWWAN		= 2
	}SNReachablityCheckerStatus;

###SNReachablityCheckerNotReachable
Returned this value when specified host or network is not reachable.

###SNReachablityCheckerReachableViaWiFi
Returned this value when specified host or network is reachable using Wi-Fi.

###SNReachablityCheckerReachableViaWWAN
Returned this value when specified host or network is reachable using WWAN.

Notifications
======
SNReachablityChecker notifies it when network status changes.

###SNReachablityDidChangeNotification
Posted when the network condition has been changed.

Blog
=======
 * [sonson.jp][]
Sorry, Japanese only....

Dependency
=======
 * none

[sonson.jp]: http://sonson.jp