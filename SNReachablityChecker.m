//
//  SNReachablityChecker.m
//  SNReachabilityTest
//
//  Created by sonson on 2012/08/29.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import "SNReachablityChecker.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#define IsSCNetworkReachabilityFlagsReachable(p)			(p & kSCNetworkReachabilityFlagsReachable)
#define IsSCNetworkReachabilityFlagsIsDirect(p)				(p & kSCNetworkReachabilityFlagsIsDirect)
#define IsSCNetworkReachabilityFlagsConnectionRequired(p)	(p & kSCNetworkReachabilityFlagsConnectionRequired)
#define IsSCNetworkReachabilityFlagsConnectionOnDemand(p)	(p & kSCNetworkReachabilityFlagsConnectionOnDemand)
#define IsSCNetworkReachabilityFlagsConnectionOnTraffic(p)	(p & kSCNetworkReachabilityFlagsConnectionOnTraffic)
#define IsSCNetworkReachabilityFlagsInterventionRequired(p)	(p & kSCNetworkReachabilityFlagsInterventionRequired)
#define IsSCNetworkReachabilityFlagsIsWWAN(p)				(p & kSCNetworkReachabilityFlagsIsWWAN)

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {
	NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
	NSCAssert([(__bridge NSObject*)info isKindOfClass:[SNReachablityChecker class]], @"info was wrong class in ReachabilityCallback");
	SNReachablityChecker* noteObject = (__bridge SNReachablityChecker*)info;
	[[NSNotificationCenter defaultCenter] postNotificationName:SNReachablityDidChangeNotification object:noteObject];
}

@interface SNReachablityChecker(private)

@property (nonatomic, assign) SCNetworkReachabilityRef networkReachability;

+ (SNReachablityChecker*)reachabilityWithAddress:(const struct sockaddr_in*)hostAddress;

@end

NSString *SNReachablityDidChangeNotification = @"SNReachablityDidChangeNotification";

@implementation SNReachablityChecker

#pragma mark - Override

- (void)dealloc {
	if (self.networkReachability)
		CFRelease(self.networkReachability);
}

#pragma mark - Class method(Private)

+ (SNReachablityChecker*)reachabilityWithAddress:(const struct sockaddr_in*)hostAddress type:(SNReachablityCheckerType)type{
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)hostAddress);
	SNReachablityChecker* retVal = NULL;
	if (reachability != NULL) {
		retVal = [[self alloc] initWithType:type];
		if (retVal != NULL) {
			retVal.networkReachability = reachability;
		}
	}
	return retVal;
}

#pragma mark - Class method

+ (SNReachablityChecker*)reachabilityWithHostName:(NSString*)hostName {
	SNReachablityChecker* retVal = NULL;
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
	if(reachability!= NULL)
	{
		retVal= [[self alloc] initWithType:SNReachablityCheckerHostConnectivity];
		if (retVal != NULL) {
			retVal.networkReachability = reachability;
		}
	}
	return retVal;
}

+ (SNReachablityChecker*)reachabilityForInternetConnection {
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	return [self reachabilityWithAddress:&zeroAddress];
}

+ (SNReachablityChecker*)reachabilityForLocalWiFi {
	struct sockaddr_in localWifiAddress;
	bzero(&localWifiAddress, sizeof(localWifiAddress));
	localWifiAddress.sin_len = sizeof(localWifiAddress);
	localWifiAddress.sin_family = AF_INET;
	// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
	localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
	
	return [self reachabilityWithAddress:&localWifiAddress];
}

#pragma mark - Instance method

- (id)initWithType:(SNReachablityCheckerType)type {
	self = [super init];
	_type = type;
	return self;
}

- (BOOL)start {
	BOOL retVal = NO;
	SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
	if (SCNetworkReachabilitySetCallback(self.networkReachability, ReachabilityCallback, &context)) {
		if(SCNetworkReachabilityScheduleWithRunLoop(
													self.networkReachability,
													CFRunLoopGetCurrent(),
													kCFRunLoopDefaultMode)) {
			retVal = YES;
		}
	}
	return retVal;
}

- (void)stop {
	if(self.networkReachability != NULL) {
		SCNetworkReachabilityUnscheduleFromRunLoop(
												   self.networkReachability,
												   CFRunLoopGetCurrent(),
												   kCFRunLoopDefaultMode);
	}
}

- (SNReachablityCheckerStatus)status {
	NSAssert(self.networkReachability != NULL, @"currentNetworkStatus called with NULL reachabilityRef");
	
	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(self.networkReachability, &flags)) {
		if (self.type == SNReachablityCheckerLocalWiFiConnectivity) {
			if (IsSCNetworkReachabilityFlagsIsDirect(flags) && IsSCNetworkReachabilityFlagsReachable(flags))
				return SNReachablityCheckerReachableViaWiFi;
		}
		else {
			// if target host is not reachable
			if (!IsSCNetworkReachabilityFlagsReachable(flags))
				return SNReachablityCheckerNotReachable;
			
			// if target host is reachable and no connection is required then we'll assume (for now) that your on Wi-Fi
			if (!IsSCNetworkReachabilityFlagsConnectionRequired(flags))
				return SNReachablityCheckerReachableViaWiFi;
			
			// ... and the connection is on-demand (or on-traffic) if the
			// calling application is using the CFSocketStream or higher APIs
			if (IsSCNetworkReachabilityFlagsConnectionOnDemand(flags) || IsSCNetworkReachabilityFlagsConnectionOnTraffic(flags)) {
				
				// ... and no [user] intervention is needed
				if (!IsSCNetworkReachabilityFlagsInterventionRequired(flags))
					return SNReachablityCheckerReachableViaWiFi;
			}
			
			// ... but WWAN connections are OK if the calling application
			// is using the CFNetwork (CFSocketStream?) APIs.
			if (IsSCNetworkReachabilityFlagsIsWWAN(flags))
				return SNReachablityCheckerReachableViaWWAN;
		}
	}
	return SNReachablityCheckerNotReachable;
}

@end
