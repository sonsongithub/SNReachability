//
//  ViewController.m
//  SNReachabilityTest
//
//  Created by sonson on 2012/08/29.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import "ViewController.h"

#import "SNReachablityChecker.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.wifiChecker = [SNReachablityChecker reachabilityForLocalWiFi];
	[self.wifiChecker start];
	
	NSLog(@"%d", self.wifiChecker.status);
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

@end
